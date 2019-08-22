%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Aug 2019 14:37
%%%-------------------------------------------------------------------
-module(lib_misc).
-author("hi").

%% API
-export([consult/1, unconsult/2, dump/2, ls/1, string2value/1, sleep/1, random_seed/0]).
-include_lib("kernel/include/file.hrl").

consult(File) ->
  case file:open(File, read) of
    {ok, S} ->
      Val = consult1(S),
      file:close(S),
      {ok, Val};
    {error, Why} ->
      {error, Why}
  end.

consult1(S) ->
  case io:read(S, '') of
    {ok, Term} -> [Term|consult1(S)];
    eof   -> [];
    Error -> Error
  end.

unconsult(File, L) ->
  {ok, S} = file:open(File, write),
  lists:foreach(fun(X) -> io:format(S, "~p.~n",[X]) end, L),
  file:close(S).

dump(File, Term) ->
  Out = File ++ ".tmp",
  io:format("** dumping to ~s~n",[Out]),
  {ok, S} = file:open(Out, [write]),
  io:format(S, "~p.~n",[Term]),
  file:close(S).

file_size_and_type(File) ->
  case file:read_file_info(File) of
    {ok, Facts} ->
      {Facts#file_info.type, Facts#file_info.size};
    _ -> error
  end.

ls(Dir) ->
  {ok, L} = file:list_dir(Dir),
  lists:map(fun(I) -> {I, file_size_and_type(I)} end, lists:sort(L)).

string2value(Str) ->
  {ok, Tokens, _} = erl_scan:string(Str ++ "."),
  {ok, Exprs} = erl_parse:parse_exprs(Tokens),
  Bindings = erl_eval:new_bindings(),
  {value, Value, _} = erl_eval:exprs(Exprs, Bindings),
  Value.

sleep(T) ->
  receive
    after T ->
    true
  end.

random_seed() ->
  {_,_,X} = erlang:now(),
  {H,M,S} = time(),
  H1 = H * X rem 32767,
  M1 = M * X rem 32767,
  S1 = S * X rem 32767,
  put(random_seed, {H1,M1,S1}).

