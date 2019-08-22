%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Aug 2019 21:55
%%%-------------------------------------------------------------------
-module(ch16_exec).
-author("hi").

%% API
-export([last_time_file_changed/2, do_erl_mod_need_recompile/1, to_md5_large/1]).
-include_lib("kernel/include/file.hrl").

do_erl_mod_need_recompile(File) ->
  case {last_time_file_changed(File,".erl"), last_time_file_changed(File, ".beam")} of
      {{{Y,M,D},{H,Mo,_}}=T1, {{Y,M,D},{H,Mo,_}}=T2} ->
      {T1, T2, no_need_to_recompile};
    {{{_Y,_M,_D},{_H,_Mo,_}}=T1, {{_Y1,_M1,_D1},{_H1,_Mo1,_}}=T2} -> {T1, T2, need_recompile};
    Other -> Other
  end.

last_time_file_changed(File, Extension) ->
  case file:read_file_info(atom_to_list(File)++Extension) of
    {ok, Facts} ->
      %% last time the file was create
       Facts#file_info.ctime;
    Other -> Other
  end.

to_md5_large(File) ->
  case file:read_file(File) of
    {ok, <<A:4/binary,B/binary>>} -> md5_helper(B,erlang:md5_update(erlang:md5_init(), A));
    {error,Reason} -> exit(Reason)
  end.

md5_helper(<<A:4/binary,B>>,Acc) -> md5_helper(B,erlang:md5_update(Acc,A));
md5_helper(A,Acc) ->
  B =     erlang:md5_update(Acc,A),
  erlang:md5_final(B).

