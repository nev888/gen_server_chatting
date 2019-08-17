%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 10:22
%%%-------------------------------------------------------------------
-module(lib_misc).
-author("hi").

%% API
-export([sleep/1, flush_buffer/0, priority_receive/0, on_exit/2, keep_alive/2]).

sleep(T) ->
  receive
    after T ->
    true
  end.

flush_buffer() ->
  receive
    _Any -> flush_buffer()
  after 0 ->
    true
  end.

priority_receive() ->
  receive
    {alarm, X} ->
      {alarm, X}
  after 0 ->
    receive
      Any -> Any
    end
  end.

on_exit(Pid, Fun) ->
  spawn(fun() ->
              Ref = monitor(process, Pid),
              receive
                {'DOWN', Ref, process, Pid, Why} ->
                      Fun(Why)
              end
              end).

keep_alive(Name, Fun) ->
  register(Name, Pid = spawn(Fun)),
  on_exit(Pid, fun(_Why) -> keep_alive(Name, Fun) end).

