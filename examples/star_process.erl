%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Aug 2019 15:15
%%%-------------------------------------------------------------------
%% Write a function which starts N processes in a star, and sends a message to each of them M times. After the messages have been sent the processes should terminate gracefully.
-module(star_process).
-author("hi").

%% API
-export([start/2]).

start(N, M) ->
  Main_process = self(),
  %%spawn(fun() -> worker(N,M, Main_process) end),
  lists:foreach(fun(X) ->
    spawn(fun() -> loop(M, X, N,Main_process) end) ! {M, the_message} end, lists:seq(1,N)),
  worker(N).

worker(N) ->
  receive
    ended -> the_end;
    {X, Pid, Message} -> io:format("main process got the message ~p from  ~p(~p)~n",[Message, X, Pid]),Pid ! Message, worker(N)
  end.

loop(0, N, N, Main_process) ->
  io:format("process ~p(~p) finished~n",[N, self()]),
  Main_process ! ended;
loop(0, I, _, _) ->
  io:format("process ~p(~p) finished~n",[I, self()]),
  {I, self(), ended};
loop(M, X, N, Main_process) ->
  receive
    {_, Message} -> io:format("process ~p(~p) got the message ~p from main process ~p~n",[X, self(), {M, Message}, Main_process]),
      Main_process ! {X, self(), {M, Message}},
      loop(M-1, X, N, Main_process)
  end.