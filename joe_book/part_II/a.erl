%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Aug 2019 17:14
%%%-------------------------------------------------------------------
-module(a).
-author("hi").

-compile(export_all).

-define(NAME, "full_name").
-define(DB, "age").

start(Tag) ->
  spawn(fun() -> loop(Tag) end).

loop(Tag) ->
  sleep(),
  Val = b:x(),
  %% io:format("Vsn1 (~p) b:x() = ~p~n",[Tag, Val]),
  %% io:format("Vsn2 (~p) b:x() = ~p~n",[Tag, Val]),
  io:format("Vsn3 (~p) b:x() = ~p~n",[Tag, Val]),
  loop(Tag).

sleep() ->
  receive
    after 3000 -> true
  end.

dummy_name(Name) ->
  ?NAME.

dummy_age(Age) ->
  ?DB.


