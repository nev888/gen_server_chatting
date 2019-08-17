%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 15:56
%%%-------------------------------------------------------------------
-module(ch13_exec).
-author("hi").

%% API
-export([my_spawn/3, test_fun/2, my_spawn1/4,
  create_register_process/0, start_workers/1, start_workers2/1]).

my_spawn(Mod, Func, Args) ->
  statistics(runtime),
  statistics(wall_clock),
  %% process_flag(trap_exit, true),
  {Pid, Ref} = spawn_monitor(Mod, Func, Args),
  Pid ! divide,
  receive
    {'DOWN', Ref, process, Pid, Why} ->
      io:format("process ~p deid because: ~p~n",[Pid, Why])
  end,
  {_, Time1} = statistics(runtime),
  io:format("The process ~p lived for ~p second(s)~n",[Pid, Time1]).

test_fun(Param1, Param2) ->
  io:format("spawned: ~p~n",[self()]),
  receive
    divide -> Result = Param1 / Param2,
              test_fun(Result, Param2);
    die -> ok;
    Other -> Other,
             test_fun(Param1, Param2)
  end.

my_spawn1(Mod, Func, Args, Time) ->
  Pid = spawn(Mod, Func, Args),
  monitor(process, Pid),
  kill_pid_after(Pid, Time).

kill_pid_after(Pid, Time) ->
  receive
    {'DOWN', _, process, Pid, Why} ->
      io:format("process ~p died becuase: ~p~n",[Pid, Why])
  after Time -> exit(Pid, kill), kill_pid_after(Pid, Time)
  end.

create_register_process() ->
  {Pid, Ref} = spawn_monitor(fun() -> global_process() end),
  register(global_pro, Pid),
  receive
    kill -> exit(whereis(global_pro), kill);
    {'DOWN', Ref, process, Pid, Why} ->
      io:format("process ~p died due to: ~p~n
       And will be restarted again!~n",[Pid, Why]),
      create_register_process()
  end.

global_process() ->
  receive
    after 5000 ->
    io:format("I\'m still running~n"), global_process()
  end.

start_workers(N) -> start_workers(N, []).

start_workers(0, Processes) -> monitor_workers(Processes);
start_workers(N, Processes) ->
  process_flag(trap_exit, true),
  Pid = spawn_link(fun() -> worker(N) end),
  start_workers(N-1,[{N, Pid}|Processes]).

monitor_workers(Processes) ->
  receive
    {'EXIT', Pid, normal} ->
      io:format("process ~p ended normaly~n",[Pid]),
      {N, Pid} = lists:keyfind(Pid, 2, Processes),
      monitor_workers(lists:delete({N, Pid},Processes));
    {'EXIT', Pid, Why} ->
      io:format("process ~p died due to: ~p~n",[Pid, Why]),
      {N, Pid} = lists:keyfind(Pid, 2, Processes),
      New_Pid = spawn_link(fun() -> worker(N) end),
      monitor_workers([{N, New_Pid}|lists:delete({N, Pid},Processes)]);
    finish -> void
  end.

worker(N) ->
  io:format("process ~p(~p) started!~n", [N,self()]),
  receive
    Do -> io:format("process ~p(~p) doing ~p ~n",[N,self(), Do])
  end.

start_workers2(N) ->   process_flag(trap_exit, true),
                       start_workers2(N, []).

start_workers2(0, Processes) -> monitor_workers2(Processes);
start_workers2(N, Processes) ->
  Pid = spawn_link(fun() -> worker(N) end),
  start_workers2(N-1,[{N, Pid}|Processes]).

monitor_workers2(Processes) ->
  receive
    {'EXIT', Pid, normal} ->
      io:format("process ~p ended normaly~n",[Pid]),
      {N, Pid} = lists:keyfind(Pid, 2, Processes),
      monitor_workers2(lists:delete({N, Pid},Processes));
    {'EXIT', Pid, Why} ->
      io:format("process ~p died due to: ~p~n
                Kill all the other processes~n~n",[Pid, Why]),
                kill([Pid2 || {_, Pid2} <- Processes]),
                start_workers2(length(Processes), []);
    finish -> void
  end.

kill([]) -> done;
kill([H|T]) -> unlink(H), exit(H, kill), kill(T).