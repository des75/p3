-module(p3_reader_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([start_reader/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    p3_reader:setup(), % add cache switcher
    p3_reader:cache_init([]), % add cache switcher

    {ok,
     {{simple_one_for_one, 10, 60},
      [#{id => p3_reader,
         start => {p3_reader, start_link, []},
         restart => temporary,
         type => worker}]}}.

start_reader(Args) ->
    StartedAt = erlang:monotonic_time(millisecond),
    add_child([Args ++ [{parent_pid, self()}, {started_at, StartedAt}]]).

add_child(Args) ->
    ClientsLimit = application:get_env(p3, clients_limit, 100000),
    [_, {active, ActiveCount}, _, _] = supervisor:count_children(?MODULE),

    case ClientsLimit > ActiveCount of
        true ->
            supervisor:start_child(?MODULE, Args);
        _ ->
            lager:debug("Reached limit of worker processes"),
            {error, reached_clients_limit}
    end.
