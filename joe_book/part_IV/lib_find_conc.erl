
%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Aug 2019 15:33
%%%-------------------------------------------------------------------
-module(lib_find_conc).
-author("hi").

%% API
-export([files/4, files/6, contain/2]).
-import(lists, [reverse/1, map/2, filter/2, foldl/3]).
-compile(export_all).
-include_lib("kernel/include/file.hrl").

-define(DEBUG(X), io:format("~p: DEBUG ~p:~p ~p~n",[self(), ?MODULE, ?LINE, X])).



files(Dir, Re, Flag, Main_process) ->
  Re1 = xmerl_regexp:sh_to_awk(Re),
  reverse(files(Dir, Re1, Flag, fun(File, Acc) -> [File|Acc] end, [], Main_process)).
files(Files, Dir, Re, Flag, Main_process) ->
  Rel = xmerl_regexp:sh_to_awk(Re),
  Main_process ! {self(), result, find_files(Files, Dir, Rel, Flag, fun(File, Acc) -> [File|Acc] end, [], Main_process)}.
files(Dir, Reg, Recursive, Fun, Acc, Main_process) ->
  case file:list_dir(Dir) of
    {ok, Files} -> find_files(Files, Dir, Reg, Recursive, Fun, Acc, Main_process);
    {error, _} -> Main_process ! {self(), result, Acc}
  end.


handle_worker(Dir, Re, Flag) ->
    case file:list_dir(Dir) of
    {ok, Items} ->   {Dirs, Files}= foldl(fun(Item, {D,F}) ->
                     case filelib:is_dir(filename:join(Dir, Item)) of
                       false -> {D, [Item|F]};
                       true ->  {[filename:join(Dir, Item)|D], F}
                     end end, {[], []}, Items),
                     Main_process = self(),
                     Processes = map(fun(Item) ->
                     spawn(fun() -> files(Item, Re, Flag, Main_process) end) end, Dirs) ++
                     [spawn(fun() -> files(Files, Dir, Re, Flag, Main_process)  end)],
                     handle_result(Processes, []);
    {error, Reason} -> Reason
  end.

handle_result(Processes, Acc) ->
  receive
    {From, result, Result} -> Acc1 = Result ++ Acc,
                              Processes1 = lists:delete(From, Processes),
                              case Processes1 of
                                [] -> {final_result, length(Acc1), Acc1};
                                _ -> handle_result(Processes1, Acc1)
                              end;
    Other -> Other
  end.

find_files([File|T], Dir, Reg, Recursive, Fun, Acc0, Main_process) ->
  FullName = filename:join([Dir, File]),
  ?DEBUG({Dir, File}),
  case contain(FullName, "hi") of
    true -> find_files(T, Dir, Reg, Recursive, Fun, Acc0, Main_process);
    _ ->
      case file_type(FullName) of
        regular ->
          case re:run(FullName, Reg, [{capture, none}]) of
            match ->
              Acc = Fun(FullName, Acc0),
              find_files(T, Dir, Reg, Recursive, Fun, Acc, Main_process);
            nomatch ->
              find_files(T, Dir, Reg, Recursive, Fun, Acc0, Main_process)
          end;
        directory ->
          case Recursive of
            true ->
              Acc1 = files(FullName, Reg, Recursive, Fun, Acc0, Main_process),
              find_files(T, Dir, Reg, Recursive, Fun, Acc1, Main_process);
            false ->
              find_files(T, Dir, Reg, Recursive, Fun, Acc0, Main_process)
          end;
        error ->
          find_files(T, Dir, Reg, Recursive, Fun, Acc0, Main_process)
      end
  end;
find_files([], _,_,_,_, A, _) -> A.

file_type(File) ->
  case file:read_file_info(File) of
    {ok, Facts} ->
      case Facts#file_info.type of
        regular -> regular;
        directory -> directory;
        _ -> error
      end;
    _ -> error
  end.

contain([], _) -> false;
contain([H|T],Sublist) ->
  case lists:sublist([H|T],length(Sublist)) =:= Sublist of
    true -> true;
    _ -> contain(T, Sublist)
  end.