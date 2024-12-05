-module(p3_webserver).

-export([routes/0, start/0]).

%% Routes
routes() ->
  [{'_', [{"/[...]", p3_file_h, []}]}].

start() ->
  Routes = routes(),
  Dispatch = cowboy_router:compile(Routes),
  {ok, _} =
    cowboy:start_clear(p3_webserver, [{port, 12080}], #{env => #{dispatch => Dispatch}}).
