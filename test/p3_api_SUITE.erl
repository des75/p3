-module(p3_api_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

all() ->
    [{group, http}].

groups() ->
    BaseTests = [hello_world],
    [{http, [parallel], BaseTests}].

init_per_suite(Config) ->
    ct:pal("Path: ~p~n", [code:get_path()]),
    Config.

end_per_suite(_Config) ->
    application:stop(p3),
    ok.

init_per_group(_Group, Config) ->
    Config;
init_per_group(_, Config) ->
    Config.

end_per_group(_Group, Config) ->
    Config.

%

hello_world(_Config) ->
    ok.
