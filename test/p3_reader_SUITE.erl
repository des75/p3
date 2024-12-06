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
         can_not_read_negative,
         respect_timeout,
         can_be_stopped],
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

respect_timeout(_Config) ->
    % cache old timer value and replace it with a need by test
    application:stop(p3),

    {ok, OldTimeout} = application:get_env(p3, timeout),
    NewTimeout = 10,
    ok = application:set_env(p3, timeout, NewTimeout),

    application:load(p3),
    application:start(p3),

    % ======================

    % The test itself
    {ok, Pid} =
        p3_reader:start_reader([{type, random},
                                {size, 10000000}]), % using big number to make sure it will timeout
    ?assert(is_process_alive(Pid)),

    timer:sleep(NewTimeout + 50),
    ?assertNot(is_process_alive(Pid)),

    % ======================

    % restore values
    application:stop(p3),
    application:unload(p3),

    application:set_env(p3, timeout, OldTimeout),

    application:load(p3),
    application:start(p3).

can_be_stopped(_Config) ->
    {ok, Pid} =
        p3_reader:start_reader([{type, random},
                                {size,
                                 10000000}]), % using big number to make sure it will live long enough to stop itmanually
    ?assert(is_process_alive(Pid)),

    p3_reader:stop_reader(Pid),
    timer:sleep(50),
    ?assertNot(is_process_alive(Pid)).
