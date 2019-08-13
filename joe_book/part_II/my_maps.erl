%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Aug 2019 14:04
%%%-------------------------------------------------------------------
-module(my_maps).
-author("hi").

%% API
-export([count_characters/1, map_search_pred/2]).

count_characters(Str) -> count_characters(Str, #{}).

count_characters([], Map) -> Map;
count_characters([H|T], Map) ->
  case Map of
    #{H := OldCount} -> count_characters(T, Map#{H => OldCount+1});
    _ -> count_characters(T, Map#{H => 1})
  end.

map_search_pred(Map, Pred) ->
 [Value] = [{K, maps:get(K, Map)} || K <- maps:keys(Map), Pred(K,maps:get(K, Map))],
 Value.