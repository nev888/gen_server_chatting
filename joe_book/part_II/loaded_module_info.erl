%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Aug 2019 11:28
%%%-------------------------------------------------------------------
-module(loaded_module_info).
-author("hi").

%% API
-export([export_most/0, unambiguous_func/0, most_common_func/0]).

export_most() ->
  Modules = code:all_loaded(),
  get_most_export(Modules, {none, 0}).


get_most_export([], Max) -> Max;
get_most_export([{Module_name,_}|T], {_, Exported_func}=Max) ->
  Number_of_exported_func = length(list_of_exported_functions(Module_name)),
  case Number_of_exported_func > Exported_func of
    true -> get_most_export(T, {Module_name, Number_of_exported_func});
    _ -> get_most_export(T, Max)
  end.
most_common_func() ->
  Modules = code:all_loaded(),
  All_funcs = lists:flatten([list_of_exported_functions(Module) || {Module, _} <- Modules]),
  most_common_func(All_funcs).

most_common_func(Func) ->
  Func_name_occur = name_with_occurence(Func),
  hd(lists:sort(fun({_, Freq1}, {_, Freq2}) ->
    Freq1 > Freq2
  end, Func_name_occur)).

name_with_occurence(Func) ->
    lists:foldl(fun({Func_name, _}, Acc) ->
    case lists:keyfind(Func_name, 1, Acc) of
         {Func_name, N} -> [{Func_name, N+1}|lists:delete({Func_name, N}, Acc)];
         false -> [{Func_name, 1}|Acc]
    end
    end, [], Func).


list_of_exported_functions(Module) ->
  {_, List_of_exported_functions} = lists:keyfind(exports, 1, Module:module_info()),
  List_of_exported_functions.

unambiguous_func() ->
  Modules = code:all_loaded(),
  Sorted_list_func = lists:sort(get_all_unambiguous_func(Modules, [])),
  %% Sorted_list_func.
  io:format("~p",[Sorted_list_func]).

get_all_unambiguous_func([], Acc) -> Acc;
get_all_unambiguous_func([{Module,_}|T], Acc) ->
  New_Acc = compare_functions(list_of_exported_functions(Module), Acc),
  get_all_unambiguous_func(T, New_Acc).

compare_functions([], Acc) -> Acc;
compare_functions([H|T], Old_func) ->
  case lists:member(H, Old_func) of
    true -> compare_functions(T,lists:delete(H, Old_func));
    _    -> compare_functions(T, [H|Old_func])
  end.
