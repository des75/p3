%% ===================================================================
% @doc Simple behaviour for cache component
% @copyright ED 2024
% @version 1.0.0
%% ===================================================================

-module(p3_reader_cache_b).

-callback init(Args :: list()) -> ok.
-callback get(Key :: atom()) -> {ok, Value :: any()} | {error, Error :: atom()}.
-callback set(Key :: atom(), Value :: any()) -> ok.
