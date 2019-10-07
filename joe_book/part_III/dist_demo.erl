%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 22:59
%%%-------------------------------------------------------------------
-module(dist_demo).
-author("hi").

%% API
-export([rpc/4, start/1]).


start(Node) ->
  spawn(Node, fun() -> loop() end).

rpc(Pid, M, F, A)  ->
  Pid ! {rpc, self(), M, F, A},
  receive
    {Pid, Response} ->
      Response
  end.

loop() ->
  receive
    {rpc, Pid, M, F, A} ->
      Pid ! {self(), (catch apply(M, F, A))},
      loop()
  end.