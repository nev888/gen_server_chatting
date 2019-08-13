%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 18:30
%%%-------------------------------------------------------------------
-module(shop2).
-author("hi").

%% API
-export([total/1]).
-import(lists, [map/2, sum/1]).

total(L) ->
  sum(map(fun({What, N}) -> shop:cost(What) * N end, L)).
