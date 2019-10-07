%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Aug 2019 18:00
%%%-------------------------------------------------------------------
-module(debug_m1).
-author("hi").

%% API
-export([loop/1]).
-ifdef(debug_flag).
-define(DEBUG(X), io:format("DEBUG ~p:~p ~p~n",[?MODULE, ?LINE, X])).
-else.
-define(DEBUG(X), void).
-endif.
loop(0) ->
  done;
loop(N) ->
  ?DEBUG(N),
  loop(N-1).