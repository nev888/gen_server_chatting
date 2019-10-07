
%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 17:51
%%%-------------------------------------------------------------------
-module(geometry1).
-author("hi").

%% API
-export([test/0, area/1]).

test() ->
  12 = area({rectangle, 3,4}),
  144 = area({square, 12}),
  tests_worked.

area({rectangle, Width, Heigth}) -> Width * Heigth;
area({square, Side}) -> Side * Side.
