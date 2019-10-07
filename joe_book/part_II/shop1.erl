%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 18:01
%%%-------------------------------------------------------------------
-module(shop1).
-author("hi").

%% API
-export([total/1]).

total([{What, N}|T]) -> shop:cost(What) * N + total(T);
total([]) -> 0.
