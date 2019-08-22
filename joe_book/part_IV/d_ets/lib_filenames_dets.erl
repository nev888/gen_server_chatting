%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Aug 2019 21:09
%%%-------------------------------------------------------------------
-module(lib_filenames_dets).
-author("hi").

%% API
-export([open/1, close/0, filename2index/1]).

open(File) ->
  io:format("dets opened:~p~n", [File]),
  Bool = filelib:is_file(File),
  case dets:open_file(?MODULE, [{file, File}]) of
    {ok, ?MODULE} ->
      case Bool of
        true -> void;
        false -> ok=dets:insert(?MODULE, {free, 1})
      end,
      true;
    {error, Reason} ->
      io:format("cannot open dets table~n"),
      exit({eDetsOpen, File, Reason})
  end.

close() -> dets:close(?MODULE).

filename2index(FileName) when is_binary(FileName) ->
  case dets:lookup(?MODULE, FileName) of
    [] ->
      [{_, Free}] = dets:lookup(?MODULE, free),
      ok = dets:insert(?MODULE,
        [{free, FileName}, {FileName, Free}, {free, Free+1}]),
      Free;
    [{_, N}] -> N
  end.

index2filename(Index) when is_integer(Index) ->
  case dets:lookup(?MODULE, Index) of
    []      ->  error;
    [{_, Bin}] -> Bin
  end.

