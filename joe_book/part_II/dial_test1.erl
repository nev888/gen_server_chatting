%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Aug 2019 16:06
%%%-------------------------------------------------------------------
-module(dial_test1).
-author("hi").

%% API
-export([f1/0, f2/0, test/0, factorial/1]).

f1() ->
  X = erlang:time(),
  seconds(X).


seconds({_Year, _Month, _Day, Hour, Min, Sec}) ->
  (Hour * 60 + Min) * 60 + Sec.

f2() ->
  tuple_size(list_to_tuple({a,b,c})).


test() -> factorial(-5).

factorial(0) -> 1;
factorial(N) -> N*factorial(N-1).

