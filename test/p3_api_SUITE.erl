-module(p3_api_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

all() ->
    [{group, http}].

groups() ->
    BaseTests =
        [can_do_get_file,
         can_do_head_file,
         can_do_get_random,
         fail_if_invalid_number,
         fail_if_non_existing_file],
    [{http, [], BaseTests}].

init_per_suite(Config) ->
    ct:pal("Path: ~p~n", [code:get_path()]),
    application:load(p3),
    application:start(p3),
    inets:start(),
    Config.

end_per_suite(_Config) ->
    application:stop(p3),
    application:unload(p3),
    ok.

init_per_group(_Group, Config) ->
    Config;
init_per_group(_, Config) ->
    Config.

end_per_group(_Group, Config) ->
    Config.

%

can_do_get_file(_Config) ->
    {ok, {{_Version, 204, _ReasonPhrase}, Headers, _Body}} =
        httpc:request(get, {"http://localhost:12080/1.jpg", []}, [], []),
    ?assertEqual("345514c76fe70aea7b876562745abf86", proplists:get_value("etag", Headers)).

can_do_head_file(_Config) ->
    {ok, {{_Version, 204, _ReasonPhrase}, Headers, _Body}} =
        httpc:request(head, {"http://localhost:12080/1.jpg", []}, [], []),
    ?assertEqual("345514c76fe70aea7b876562745abf86", proplists:get_value("etag", Headers)).

can_do_get_random(_Config) ->
    {ok, {{_Version, 204, _ReasonPhrase}, _Headers, _Body}} =
        httpc:request(get, {"http://localhost:12080/random/100", []}, [], []).

fail_if_invalid_number(_Config) ->
    {ok, {{_Version, 500, _ReasonPhrase}, _Headers, _Body}} =
        httpc:request(get, {"http://localhost:12080/random/qwerty", []}, [], []).

fail_if_non_existing_file(_Config) ->
    {ok, {{_Version, 500, _ReasonPhrase}, _Headers, _Body}} =
        httpc:request(get, {"http://localhost:12080/random/qwerty", []}, [], []).
