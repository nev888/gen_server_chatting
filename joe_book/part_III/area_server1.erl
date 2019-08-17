%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 9:27
%%%-------------------------------------------------------------------
-module(area_server1).
-author("hi").

%% API
-export([loop/0, rpc/2]).

rpc(Pid, Request) ->
  Pid ! {self(), Request},
  receive
    {Pid, Response} -> Response
  end.

loop() ->
  receive
    {From, {rectangle, Width, Ht}} ->
      From ! {self(), Width * Ht},
      loop();
    {From, {square, Side}} ->
      From ! {self(), Side * Side},
      loop();
    {From, {circle, R}} ->
      From ! {self(), 3.14159 * R * R},
      loop();
    {From, Other} ->
      From ! {self(), {error, Other}},
      loop()
  end.