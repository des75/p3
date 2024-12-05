%% ===================================================================
% @todo This code is a temporary duplicate of es_mr_ids_h.
% We may want to move everything to es_webserver later but
% we don't know yet how this will impact other work-in-progress
% changes.
%
% @doc Ids handler.
% @@tag ids
% @copyright 2016-2017 KOBIL systems / Germany
% @version 1.0.0
%% ===================================================================

-module(p3_file_h).

-export([init/2]).
-export([terminate/3]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
%
-export([read_file_v1/2]).

init(Req, _) ->
  _Method = cowboy_req:method(Req),
  _Uri = iolist_to_binary(cowboy_req:uri(Req)),
  {cowboy_rest, Req, #{}}.

terminate(_, _, _) ->
  % lager:debug("Handler stopped"),
  ok.

allowed_methods(Req, State) ->
  {[<<"HEAD">>, <<"GET">>, <<"OPTIONS">>], Req, State}.

content_types_provided(Req, State) ->
  {[{<<"text/plain">>, read_file_v1}], Req, State}.

read_file_v1(Req0, State) ->
  Launch =
    case cowboy_req:path(Req0) of
      <<"/random/", DesiredSize0/binary>> ->
        DesiredSize = erlang:binary_to_integer(DesiredSize0),
        p3_reader_sup:start_reader([{type, random}, {size, DesiredSize}]);
      <<"/", Path/binary>> ->
        PathToFile = erlang:binary_to_list(Path),
        p3_reader_sup:start_reader([{type, file}, {path, PathToFile}])
    end,

  Req =
    case Launch of
      {ok, WorkerPid} ->
        receive
          {file_read_result, {ok, Md5}} ->
            % {Md5, Req0, State};
            cowboy_req:reply(204, #{<<"etag">> => Md5}, Req0);
          {file_read_result, _} ->
            p3_reader:stop_reader(WorkerPid),
            cowboy_req:reply(500, Req0)
        % {<<"nok">>, Req0, State}
        after 5000 ->
          p3_reader:stop_reader(WorkerPid),
          cowboy_req:reply(500, Req0)
        end;
      _ ->
        lager:debug("Unable to start file reader worker"),
        cowboy_req:reply(500, Req0)
    end,

  {stop, Req, State}.
