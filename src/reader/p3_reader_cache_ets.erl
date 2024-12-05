-module(p3_reader_cache_ets).

-behaviour(p3_reader_cache_b).

-export([init/1, get/1, set/2]).

-define(TABLE_NAME, p3_md5_cache).

init(_Args) ->
  ets:new(?TABLE_NAME, [named_table, public]),
  ok.

get(Key) ->
  case ets:lookup(?TABLE_NAME, Key) of
    [{Key, Value} | _] ->
      {ok, Value};
    _ ->
      {error, not_found}
  end.

set(Key, Value) ->
  ets:insert(?TABLE_NAME, {Key, Value}),
  ok.
