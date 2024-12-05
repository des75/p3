%%%-------------------------------------------------------------------
%% @doc p3 top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(p3_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    lager:start(),
    application:ensure_all_started(cowboy),

    p3_webserver:start(),

    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags =
        #{strategy => one_for_all,
          intensity => 0,
          period => 1},
    ChildSpecs = [#{
        id => p3_reader_sup,
        start => {p3_reader_sup, start_link, []},
        restart => permanent,
        type => supervisor
    }],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
