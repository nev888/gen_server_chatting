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
   Pid1 = spawn(?MODULE, worker, [self(), M]),
          spawn(?MODULE, worker, [Pid1, M]).

worker(Pid, M) ->
  Pid ! {M, self()},
  receive
  {0, _} -> stoped;
  {N, Pid2} -> io:format("result: ~p~n",[N]), Pid2 ! {N-1, self()}, worker(Pid, N-1)
  end.

start_ring(Pro, Mess) ->
   lists:map(fun(_) ->
      spawn(.
  

