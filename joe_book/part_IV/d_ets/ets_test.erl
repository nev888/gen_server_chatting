%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Aug 2019 15:45
%%%-------------------------------------------------------------------
-module(ets_test).
-author("hi").

%% API
-export([start/0]).

start() ->
  lists:foreach(fun test_ets/1,
          [set, ordered_set, bag, duplicate_bag]).

test_ets(Mode) ->
  TableId = ets:new(test, [Mode]),
  ets:insert(TableId, {a,1}),
  ets:insert(TableId, {b,2}),
  ets:insert(TableId, {a,1}),
  ets:insert(TableId, {a,3}),
  List = ets:tab2list(TableId),
  io:format("~-13w => ~p~n",[Mode, List]),
  ets:delete(TableId).