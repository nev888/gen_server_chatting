%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 10:28
%%%-------------------------------------------------------------------
-module(stimer).
-author("hi").

%% API
-export([start/2, cancel/1]).

start(Time, Fun) -> spawn(fun() -> timer1(Time, Fun) end).

cancel(Pid) -> Pid ! cancel.

timer1(Time, Fun) ->
  receive
    cancel -> void
  after Time ->
    Fun()
  end.