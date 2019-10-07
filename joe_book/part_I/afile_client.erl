%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 16:05
%%%-------------------------------------------------------------------
-module(afile_client).
-author("hi").

%% API
-export([ls/1, get_file/2, put_file/2]).

ls(Server) ->
  Server ! {self(), list_dir},
  receive
    {Server, FileList} ->
      FileList
  end.

get_file(Server, File) ->
  Server ! {self(), {get_file, File}},
  receive
    {Server, Content} ->
      Content
  end.

put_file(Server, File) ->
  FileName = filename:basename(File),
  {ok, Content} = file:read_file(File),
  Server ! {self(), {put_file, FileName, Content}},
  receive
    {Server, done} -> done
  end.
