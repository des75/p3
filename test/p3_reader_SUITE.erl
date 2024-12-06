-module(p3_reader_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

all() ->
    [{group, http}].

groups() ->
    BaseTests =
        [can_read_file,
         can_read_random_data,
         can_read_random_data_of_different_sizes,
         can_not_read_zero_size,
         can_not_read_negative],
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

can_read_file(_Config) ->
    {ok, Md5} = p3_reader:read_file("/1.jpg"),
    % we read known file, so md5 is always same
    ?assertEqual("345514c76fe70aea7b876562745abf86", Md5).

can_read_random_data(_Config) ->
    {ok, Md5_0} = p3_reader:read_random(100),
    {ok, Md5_1} = p3_reader:read_random(100),
    % 2 random blobs = 2 different md5
    ?assertNotEqual(Md5_0, Md5_1).

can_read_random_data_of_different_sizes(_Config) ->
    {ok, _Md5_0} = p3_reader:read_random(100),
    {ok, _Md5_1} = p3_reader:read_random(1000),
    {ok, _Md5_2} = p3_reader:read_random(10000).

can_not_read_zero_size(_Config) ->
    %  arg must be greater than 0
    {error, function_clause} =
        try
            p3_reader:read_random(0)
        catch
            E:T ->
                {E, T}
        end.

can_not_read_negative(_Config) ->
    {error, function_clause} =
        try
            p3_reader:read_random(-100)
        catch
            E2:T2 ->
                {E2, T2}
        end.
