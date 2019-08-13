%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Aug 2019 11:17
%%%-------------------------------------------------------------------
-module(math_functions).
-author("hi").

%% API
-export([even/1, odd/1, filter/2, split/1, split1/1]).

even(X) when X rem 2 =:= 0 -> true;
even(_) -> false.

odd(X) when X rem 2 =/= 0 -> true;
odd(_) -> false.

filter(F,[H|T]) ->
  case F(H) of
    true -> [H|filter(F,T)];
    false -> filter(F, T)
  end;
filter(_, []) -> [].

split(L) ->
  Even = filter(fun(X) -> X rem 2 =:= 0 end, L),
  Odd  = filter(fun(X) -> X rem 2 =/= 0 end, L),
  {Even, Odd}.

split1(L) -> split1(L,{[], []}).

split1([], {Even, Odd}) -> {lists:reverse(Even), lists:reverse(Odd)};
split1([H|T],{Even, Odd}) when H rem 2 =:= 0 -> split1(T,{[H|Even], Odd});
split1([H|T],{Even, Odd}) -> split1(T,{Even, [H|Odd]}).