%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 10:48
%%%-------------------------------------------------------------------
-module(master_slave).
-author("hi").

%% API
-export([start/1, to_slave/2, list_slaves/0]).


start(N) ->
  Pid = spawn(fun() -> master(N) end),
  register(master, Pid).

master(N) ->
  process_flag(trap_exit, true),
  Processes = start_slaves(N),
  master_loop(Processes).

start_slaves(N) -> start_slaves(N, []).

start_slaves(0, L) -> L;
start_slaves(N, L) ->
  Pid = spawn(fun() -> slave(N) end),
  link(Pid),
  start_slaves(N-1, [{N, Pid}|L]).


master_loop(Processes) ->
  receive
    list_slaves -> io:format("Slaves: ~p ~n",[Processes]),
                   master_loop(Processes);
    {to_slave, Message, N} ->
                  {_, Pid} =lists:keyfind(N, 1, Processes),
                  Pid ! Message,
                  master_loop(Processes);
    {'EXIT', Pid, _} -> {N, _} = lists:keyfind(Pid, 2, Processes),
                New_Pid = spawn_link(fun() -> slave(N) end),
                io:format("master restarting dead slave ~p~n",[N]), master_loop([{N, New_Pid}|lists:keydelete(Pid, 2, Processes)])
  end.

to_slave(Message, N) ->
  master ! {to_slave, Message, N}.

list_slaves() ->
  master ! list_slaves.

slave(N) ->
  receive
    die -> io:format("process ~p(~p) died~n",[N, self()]), exit(self(), died);
    Message -> io:format("slave ~p(~p) got: ~p~n",[N, self(), Message]),
               slave(N)
  end.