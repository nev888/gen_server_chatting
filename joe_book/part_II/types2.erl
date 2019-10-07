%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Aug 2019 17:15
%%%-------------------------------------------------------------------
-module(types2).
-author("hi").

%% API
-export([]).

myand1(true, true) -> true;
myand1(false, _)   -> false;
myand1(_, false)   -> false.

bug1(X, Y) ->
  case myand1(X, Y) of
    true -> X + Y
  end.