%%%-------------------------------------------------------------------
%% @doc p3 public API
%% @end
%%%-------------------------------------------------------------------

-module(p3_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    lager:start(),
    application:ensure_all_started(cowboy),

    p3_webserver:start(),
    p3_reader:setup(),

    p3_sup:start_link().

stop(_State) ->
    p3_webserver:stop().

%% internal functions
