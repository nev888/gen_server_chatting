%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Aug 2019 19:49
%%%-------------------------------------------------------------------
-module(fac1).
-author("hi").

%% API
-export([main/1]).

main([A]) ->
  I = list_to_integer(atom_to_list(A)),
  F = fac(I),
  io:format("factorial ~w = ~w~n",[I, F]),
  init:stop().

fac(0) -> 1;
fac(N) -> N*fac(N-1).
