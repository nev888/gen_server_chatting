%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Aug 2019 9:59
%%%-------------------------------------------------------------------
-module(mixed_topics).
-author("hi").

%% API
-export([f/1, g/1, h/1, i/1, filter/2, filter1/2, my_tuple_to_list/1, my_time_func/1, my_date_string/0]).

f(X) when (X==0) or (1/X > 2) -> zero_or_not;
f(_X) -> guard_failed.

g(X) when (X == 0) orelse (1/X > 2) -> zero_or_not;
g(_X) -> guard_failed.

h(X) when (X==0) ; (1/X > 2) -> zero_or_not;
h(_X) -> guard_failed.

i(X) when (X rem 2 == 0) , X >= 0 , X < 101 -> x_is_even_0_100;
i(X) when X rem 2 /= 0 , X > 0 , X < 100 -> x_is_odd_0_100;
i(X) when X < 0 ; X > 100 -> x_is_out_of_range_0_100.

filter(P, [H|T]) ->
  case P(H) of
    true -> [H|filter(P, T)];
    false -> filter(P,T)
  end;
filter(_, []) ->
  [].

filter1(P, [H|T]) -> filter2(P(H), H, P, T);
filter1(_, []) -> [].

filter2(true, H, P, T) -> [H|filter1(P, T)];
filter2(false, _, P, T) -> filter1(P, T).

my_tuple_to_list(Tuple) -> my_tuple_to_list(Tuple, size(Tuple), []).
my_tuple_to_list(_,0, List) -> List;
my_tuple_to_list(Tuple, Size, List) -> my_tuple_to_list(Tuple, Size-1, [element(Size,Tuple)|List]).

my_time_func(F) ->
  Time1 = erlang:timestamp(),
  F(),
  Time2 = erlang:timestamp(),
  timer:now_diff(Time2, Time1).

my_date_string() ->
  {H,M,S} = time(),
  {Y,Mo,D} = date(),
  io:format("Today: ~p-~p-~p ~p:~p:~p~n",[D,Mo,Y,H,M,S]).