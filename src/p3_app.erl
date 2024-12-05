%%%-------------------------------------------------------------------
%% @doc p3 public API
%% @end
%%%-------------------------------------------------------------------

-module(p3_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    p3_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
