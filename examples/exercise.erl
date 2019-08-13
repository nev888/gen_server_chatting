-module(exercise).
-compile(export_all).

min(L) -> min(L, 0).

min([], Min) -> Min;
min([H|T], Min) when H =< Min -> min(T, H);
min([_|T], Min) -> min(T, Min).

%% tell_sign(_) when is_positive(N) -> positive;
tell_sign(N) -> 
  case is_positive(N) of
   true  -> positive;
   false -> negative
  end.

is_positive(N) when N >= 0 -> true;
is_positive(_) -> false.

start2(M) ->
  Pid1 = spawn(?MODULE, worker1, []),
  Pid2 = spawn(?MODULE, worker2, [Pid1, M]).

worker1() ->
   receive
   {Pid, M} -> io:format("got: ~p~n",[M]), 
               Pid ! M-1,
               worker1();
   _ -> io:format("someing wrong~n",[])
   end.

worker2(Pid1, M) ->
  Pid1 ! {self(), M},
  receive
   0 -> io:format("Stopped!~n",[]);
   N -> io:format("result: ~p~n",[N]), worker2(Pid1, N)
  end.

start22(M) ->
      spawn(?MODULE, worker,[M, self()]),
      receive
        Any -> Any
      end.

worker(M, MainProcess) when is_integer(M)->
  Next_process = spawn(?MODULE, worker, [MainProcess, M]),
  Next_process ! {M, self()},
  loop(M, MainProcess);
worker(Pid, M) ->
  loop(M, Pid).

loop(M, MainProcess) ->
  receive
  {0, _} -> MainProcess ! stoped;
  {N, Pid2} -> io:format("~p sent result: ~p to ~p~n",[Pid2, N, self()]), Pid2 ! {N-1, self()}, loop(N-1, MainProcess)
  end.

start_ring(Pro, Mess) ->
   lists:map(fun(_) ->
      ok end).
