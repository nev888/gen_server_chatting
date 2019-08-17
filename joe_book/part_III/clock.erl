%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 10:44
%%%-------------------------------------------------------------------
-module(clock).
-author("hi").

%% API
-export([start/2, stop/0]).

start(Time, Fun) ->
  register(clock, spawn(fun() -> tick(Time, Fun) end )).

stop() -> clock ! stop.

tick(Time, Fun) ->
  receive
    stop ->
      void
  after Time ->
    Fun(),
    tick(Time, Fun)
  end.