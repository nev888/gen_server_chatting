%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Aug 2019 8:58
%%%-------------------------------------------------------------------
-module(varScope).
-author("hi").

%% API
-export([f/1, g/1, foo/1, start_server/1, ask/2, server/1, hello/0]).

f(X) ->
  case g(X) of
    true -> A = hd(X), B = 7;
    false -> B = 6
  end,
  io:format("~p~n",["p"]).

g(List) ->
  length(List) rem 2 =:= 0.

foo(1) -> hello;
foo(2) -> throw({myerror, abc});
foo(3) -> tuple_to_list(a);
foo(4) -> exit({myExit, 222}).

start_server(D) ->
  spawn(fun() -> server(D) end).

ask(Server, Question) ->
  Ref = make_ref(),
  Server ! {self(), Ref, Question},
  receive
    {Ref, Answer} ->
      Answer
  end.

server(Data) ->
  receive
    {From, Ref, Question} ->
      From ! {Ref, Data},
      server(Data);
    Anything -> Anything
end.

hello() ->
  io:format("Hellow world~n").