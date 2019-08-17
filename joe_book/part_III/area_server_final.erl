%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 9:47
%%%-------------------------------------------------------------------
-module(area_server_final).
-author("hi").

%% API
-export([start/0, area/2, loop/0]).

start() -> spawn(area_server_final, loop, []).

area(Pid, What) ->
  rpc(Pid, What).
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