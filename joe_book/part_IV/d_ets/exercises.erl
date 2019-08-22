%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Aug 2019 22:25
%%%-------------------------------------------------------------------
-module(exercises).
-author("hi").

%% API
-export([extract_lib_name/0, extract_modules/0, create_table/0, create_table/0, populate_table/1]).
-export([remove_version_from_name_test/0, strip_beam_extension_test/0]).
-import(lists, [reverse/1, map/2, flatten/1]).

-define(DEBUG(X), io:format("DEBUG ~p:~p ~p~n",[?MODULE, ?LINE, X])).


create_table() ->
  ets:new(module_info, [set]).

populate_table(Table) ->
  Modules = extract_modules(),
  lists:foreach(fun(I) -> insert_module_functions_into_ets(Table, I) end, Modules),
  ok.

insert_module_functions_into_ets(Table, Module) ->
  lists:foreach(fun(Key) ->
  ets:insert(Table, {Key, Module}) end, Module:module_info(exports)),
  ok.

extract_modules() ->
  Libs = extract_lib_name(),
  flatten(map(fun(I) ->
                       {ok, M} = file:list_dir(code:lib_dir(I)++"/ebin"),
                        strip_beam_extension(M, [])
                       end, Libs)).

extract_lib_name() ->
  {ok, Libs0}=file:list_dir(code:lib_dir()),
  remove_version_from_name(Libs0, []).

strip_beam_extension([], Acc) -> reverse(Acc);
strip_beam_extension([H|T], Acc) ->
  case string:split(H,".beam") of
    [Module_name, _] -> strip_beam_extension(T,[list_to_atom(Module_name)|Acc]);
    [_] ->  strip_beam_extension(T, Acc)
  end.

remove_version_from_name([], Acc) -> reverse(Acc);
remove_version_from_name([H|T], Acc) ->
  [Name, _] = string:split(H, "-"),
  remove_version_from_name(T, [Name|Acc]).




%% Test
strip_beam_extension_test() ->
  ["shell_default","erl_parse"] = strip_beam_extension(["shell_default.beam","erl_parse.beam"],[]),
  ["lists"] = strip_beam_extension(["lists.beam_any"],[]),
  [] = strip_beam_extension([],[]),
  ok.

remove_version_from_name_test() ->
  ["name"] = remove_version_from_name(["name-1-atom"],[]),
  [] = remove_version_from_name([], []),
  ["odbc","snmp","wx","stdlib"]=remove_version_from_name(["odbc-2.12.2","snmp-5.2.12","wx-1.8.6","stdlib-3.7.1"],[]),
  ok.

