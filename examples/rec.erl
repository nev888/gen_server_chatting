%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Aug 2019 12:50
%%%-------------------------------------------------------------------
-module(rec).
-author("hi").

%% API
-export([ring/3,loop/1]).


ring(N,N,M) ->
  io:format("final message~n",[]),
  loop(N);
ring(I,N,M) ->
  ring(I+1,N,M),
  loop(M+I).

loop(M) ->
  io:format("loop called with ~p~n",[M]).