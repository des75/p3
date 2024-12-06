%% ===================================================================
% @doc Functions library, providing tools to read real files or
% random data blobs, and calculate Md5 sum for them
% @copyright ED 2024
% @version 1.0.0
%% ===================================================================

-module(p3_reader).

-export([setup/0]).
-export([start_link/1]).
-export([start_reader/1]).
-export([stop_reader/1]).
%
-export([random_binary/1]).
-export([read_file/1]).
-export([read_random/1]).
%
-define(DEFAULT_BUFFER_SIZE, 50).
-define(DEFAULT_TIMEOUT, 5000).

%%--------------------------------------------------------------------
%% @doc
%% Spawns a process to read a file by path or a random binary data to simulate huge files (not for production usage).
%% Result is returned as message to 'parent_pid' passed as Argument
%% @end
%%--------------------------------------------------------------------
-spec start_link(list()) -> {ok, pid()}.
start_link(Args) ->
  Type = proplists:get_value(type, Args, undefined),
  Size = proplists:get_value(size, Args, 0),
  Path = proplists:get_value(path, Args, undefined),

  ParentPid = proplists:get_value(parent_pid, Args),
  StartedAt = proplists:get_value(started_at, Args),

  Pid =
    spawn_link(fun() ->
                  put(started_at, StartedAt),

                  Result =
                    case Type of
                      file -> p3_reader:read_file(Path);
                      random -> p3_reader:read_random(Size)
                    end,

                  ParentPid ! {file_read_result, Result}
               end),
  {ok, Pid}.

%%--------------------------------------------------------------------
%% @doc
%% Start a new reader worker.
%% Adds a beginning timestamp and a parent pid(caller process) to the arguments
%% @end
%%--------------------------------------------------------------------
-spec start_reader(pid()) -> {ok, pid()}.
start_reader(Args) ->
    StartedAt = erlang:monotonic_time(millisecond),
    p3_reader_sup:add_child([Args ++ [{parent_pid, self()}, {started_at, StartedAt}]]).

%%--------------------------------------------------------------------
%% @doc
%% Sends a 'stop' message to the given pid
%% @end
%%--------------------------------------------------------------------
-spec stop_reader(pid()) -> ok.
stop_reader(WorkerPid) ->
  WorkerPid ! stop.

%%--------------------------------------------------------------------
%% @doc
%% Prepares configurration values and stores it to persistent term storage.
%% Should be called once on app startup.
%% @end
%%--------------------------------------------------------------------
setup() ->
  cache_init([]),

  BufferSize = application:get_env(p3, buffer_size, ?DEFAULT_BUFFER_SIZE),
  Timeout = application:get_env(p3, timeout, ?DEFAULT_TIMEOUT),
  persistent_term:put(p3_reader_buffer_size, BufferSize),
  persistent_term:put(p3_reader_timeout, Timeout).

%%--------------------------------------------------------------------
%% @doc
%% Getter for buffer size value
%% @end
%%--------------------------------------------------------------------
get_buffer_size() ->
  persistent_term:get(p3_reader_buffer_size, ?DEFAULT_BUFFER_SIZE).

%%--------------------------------------------------------------------
%% @doc
%% Getter for buffer size value
%% @end
%%--------------------------------------------------------------------
get_timeout() ->
  persistent_term:get(p3_reader_timeout, ?DEFAULT_TIMEOUT).

%%--------------------------------------------------------------------
%% @doc
%% Read desired amount of random data and calculate md5
%% @end
%%--------------------------------------------------------------------
-spec read_random(integer()) -> {ok, list()} | error.
read_random(Size) when Size > 0 ->
  Md5Context = erlang:md5_init(),
  case read_random(Size, 0, Md5Context) of
    {ok, Md5Result} ->
      {ok, get_md5_hex_str(erlang:md5_final(Md5Result))};
    _ ->
      error
  end.

-spec read_random(integer(), integer(), any()) -> {ok, binary()} | stopped.
read_random(TotalSize, ReadySize, Md5Context) when ReadySize == TotalSize ->
  {ok, Md5Context};
read_random(TotalSize, ReadySize, Md5Context) ->
  BytesLeft = TotalSize - ReadySize,
  BytesToRead =
    case BytesLeft > get_buffer_size() of
      true ->
        get_buffer_size();
      false ->
        BytesLeft
    end,

  Data = p3_reader:random_binary(BytesToRead),
  UpdatedContext = erlang:md5_update(Md5Context, Data),

  case should_continue() of
    stop ->
      lager:debug("Reader stopped externally"),
      stopped;
    _ ->
      read_random(TotalSize, ReadySize + BytesToRead, UpdatedContext)
  end.

%%--------------------------------------------------------------------
%% @doc
%% Produce a random binary whose size is Size.
%% Data of the binary is read from /dev/urandom.
%% @end
%%--------------------------------------------------------------------
-spec random_binary(integer()) -> binary().
random_binary(Size) ->
  Flag = process_flag(trap_exit, true),
  Cmd =
    lists:flatten(
      io_lib:format("head -c ~p /dev/urandom~n", [Size])),
  Port = open_port({spawn, Cmd}, [binary]),
  Data = random_binary(Port, []),
  process_flag(trap_exit, Flag),
  Data.

random_binary(Port, Sofar) ->
  receive
    {Port, {data, Data}} ->
      random_binary(Port, [Data | Sofar]);
    {'EXIT', Port, _Reason} ->
      list_to_binary(lists:reverse(Sofar))
  end.

%%--------------------------------------------------------------------
%% @doc
%% Read file by path and calculates an md5 sum
%% If there is a cached result, it will be returned immediately
%% @end
%%--------------------------------------------------------------------
-spec read_file(string()) -> {ok, string()} | error.
read_file(Path) ->
  {ok, Handler} = file:open(code:priv_dir(p3) ++ Path, [raw, read_ahead]),

  FileKey = get_file_md5_key(Handler),

  case cache_get(FileKey) of
    {ok, Cached} ->
      lager:debug("Found cached md5 ~p for file ~p", [Cached, Path]),
      {ok, Cached};
    _ ->
      lager:debug("No cached data for file ~p, proceeding normally", [Path]),

      Md5Context = erlang:md5_init(),

      lager:debug("Starting to read file ~p", [Path]),
      Result =
        try
          do_read_file(Handler, Md5Context)
        after
          file:close(Handler)
        end,

      case Result of
        {_Handler, Md5Context1} ->
          lager:debug("Finished reading file ~p", [Path]),
          Md5Hex = get_md5_hex_str(erlang:md5_final(Md5Context1)),

          lager:debug("Calculated MD5 for ~p: ~p", [Path, Md5Hex]),

          cache_set(FileKey, Md5Hex),

          {ok, Md5Hex};
        _ ->
          error
      end
  end.

do_read_file(IoDevice, Md5Context) ->
  case file:read(IoDevice, get_buffer_size()) of
    {ok, Data} ->
      Md5Context1 = erlang:md5_update(Md5Context, Data),

      case should_continue() of
        stop ->
          ok;
        _ ->
          do_read_file(IoDevice, Md5Context1)
      end;
    eof ->
      {IoDevice, Md5Context};
    {error, Reason} ->
      lager:error(Reason),
      ok
  end.

%%--------------------------------------------------------------------
%% @doc
%% Checks if reader should continue reading iteration, or should stop.
%% Reasons to stop may ba a timeout or an explicit signal ('stop' message)
%% @end
%%--------------------------------------------------------------------
should_continue() ->
  StartedAt = get(started_at),
  Now = erlang:monotonic_time(millisecond),

  % integer is always less then atom, by this we can skip timer check (perhaps not needed, but it's handy for unit tests)
  case Now - get_timeout() < StartedAt of
    true ->
      receive
        stop ->
          lager:debug("Reader has been stopped externally"),
          stop
      after 0 ->
        ok
      end;
    _ ->
      lager:debug("Reader has timed out"),
      stop
  end.

%%--------------------------------------------------------------------
%% @doc
%% Transform binary data returned by erlang:md5() to a familiar HEX string value
%% @end
%%--------------------------------------------------------------------
get_md5_hex_str(Str) ->
  [begin
     if N < 10 ->
          48 + N;
        true ->
          87 + N
     end
   end
   || <<N:4>> <= Str].

%%--------------------------------------------------------------------
%% @doc
%% Generates key for file to store an md5 in cache
%% In this implementation we use md5 sum from file size and last modified date,
%% so it will be updated when the file is somehow changed
%% @end
%%--------------------------------------------------------------------
get_file_md5_key(Handler) ->
  FileKey =
    io_lib:format("~p-~p", [filelib:last_modified(Handler), filelib:file_size(Handler)]),
  get_md5_hex_str(erlang:md5(FileKey)).

%
%  Cache
%
%%--------------------------------------------------------------------
%% @doc
%% Prepares everything to use cache (read and store values from config), and triggersan 'init/1' callback
%% @end
%%--------------------------------------------------------------------
cache_init(Args) ->
  CacheEnabled = application:get_env(p3, cache_enabled, true),
  CacheModule = application:get_env(p3, cache_module, p3_reader_cache_ets),

  persistent_term:put(cache_enabled, CacheEnabled),
  persistent_term:put(cache_module, CacheModule),

  CacheModule:init(Args).

%%--------------------------------------------------------------------
%% @doc
%% Take value from cache if cache is enabled and the Key is known
%% 'Cache' module should be an implementation of 'p3_reader_cache_b' behaviour and defined in the configuration
%% @end
%%--------------------------------------------------------------------
cache_get(Key) ->
  CacheModule = persistent_term:get(cache_module),
  CacheEnabled = persistent_term:get(cache_enabled),

  case CacheEnabled of
    true ->
      CacheModule:get(Key);
    _ ->
      {error, cache_disabled}
  end.

%%--------------------------------------------------------------------
%% @doc
%% Set value into cache if cache is enabled
%% 'Cache' module should be an implementation of 'p3_reader_cache_b' behaviour and defined in the configuration
%% @end
%%--------------------------------------------------------------------
cache_set(Key, Value) ->
  CacheModule = persistent_term:get(cache_module),
  CacheEnabled = persistent_term:get(cache_enabled),

  case CacheEnabled of
    true ->
      CacheModule:set(Key, Value);
    _ ->
      ok
  end.
