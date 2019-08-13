%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 17:48
%%%-------------------------------------------------------------------
-module(geometry).
-author("hi").

%% API
-export([area/1, perimeter/1]).

area({rectangle, Width, Height}) -> Width * Height;
area({square, Side}) -> Side * Side;
area({circle, Radius}) -> 3.14159 * Radius * Radius;
area({right_angled_triangle, A, B}) -> (A*B)/2.

perimeter({rectangle, Width, Height}) -> (Width + Height)*2;
perimeter({square, Side}) -> Side * 4;
perimeter({circle, Radius}) -> 2 * 3.14159 * Radius;
perimeter({triangle, A, B, C}) -> A+B+C.