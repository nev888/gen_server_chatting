%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 16:05
%%%-------------------------------------------------------------------
-module(afile_server).
-author("hi").

%% API
-export([start/1, loop/1]).

start(Dir) -> spawn(afile_server, loop, [Dir]).

loop(Dir) ->
  receive
    {Client, list_dir} ->
      Client ! {self(), file:list_dir(Dir)};
    {Client, {get_file, File}} ->
      Full = filename:join(Dir, File),
      Client ! {self(), file:read_file(Full)};
    {Client, {put_file, FileName, Content}} ->
      file:write_file(FileName, Content),
      Client ! {self(), done}
  end,
  loop(Dir).