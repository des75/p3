-module(p3_reader_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([add_child/1]).

% Standart callbacks
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    {ok,
     {{simple_one_for_one, 10, 60},
      [#{id => p3_reader,
         start => {p3_reader, start_link, []},
         restart => temporary,
         type => worker}]}}.

%%--------------------------------------------------------------------
%% @doc
%% Adds a new worker, if limit is not yet reached
%% @end
%%--------------------------------------------------------------------
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
