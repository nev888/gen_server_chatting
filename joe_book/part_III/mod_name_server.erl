%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Aug 2019 8:38
%%%-------------------------------------------------------------------
-module(mod_name_server).
-author("hi").

%% API
-export([start_me_up/3]).

start_me_up(MM, _ArgsC, _ArgS) ->
  loop(MM).

loop(MM) ->
  receive
    {chan, MM, {store, K, V}} ->
      kvs:store(K, V),
      loop(MM);
    {chan, MM, {lookup, K}} ->
      MM ! {send, kvs:lookup(K)},
      loop(MM);
    {chan_closed, MM} ->
      true
  end.