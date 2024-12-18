%% ===================================================================
% @doc File reader handler.
% @copyright ED 2024
% @version 1.0.0
%% ===================================================================

-module(p3_file_h).

-export([init/2]).
-export([terminate/3]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
%
-export([read_file_v1/2]).

init(Req, _) ->
  {cowboy_rest, Req, #{}}.

terminate(_, _, _) ->
  % lager:debug("Handler stopped"),
  ok.

allowed_methods(Req, State) ->
  {[<<"HEAD">>, <<"GET">>, <<"OPTIONS">>], Req, State}.

content_types_provided(Req, State) ->
  {[{<<"text/plain">>, read_file_v1}], Req, State}.

read_file_v1(Req0, State) ->
  Path = cowboy_req:path(Req0),
  PathToFile = erlang:binary_to_list(Path),
  Launch = p3_reader:start_reader([{type, file}, {path, PathToFile}]),
  Timeout = p3_reader:get_timeout(),

  Req =
    case Launch of
      {ok, WorkerPid} ->
        receive
          {file_read_result, {ok, Md5}} ->
            cowboy_req:reply(204, #{<<"etag">> => Md5}, Req0);
          {file_read_result, _} ->
            p3_reader:stop_reader(WorkerPid),
            cowboy_req:reply(500, Req0)
        after Timeout ->
          p3_reader:stop_reader(WorkerPid),
          cowboy_req:reply(500, Req0)
        end;
      _ ->
        lager:debug("Unable to start file reader worker"),
        cowboy_req:reply(500, Req0)
    end,

  {stop, Req, State}.
