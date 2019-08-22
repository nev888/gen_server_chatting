%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Aug 2019 10:37
%%%-------------------------------------------------------------------
-module(socket_examples).
-author("hi").
-import(lists, [reverse/1]).
%% API
-export([nano_get_url/0, start_nano_server/0, nano_client_eval/1,
  start_seq_server/0, start_parallel_server/0, error_test/0, nano_client_eval/3]).

nano_get_url() ->
  nano_get_url("www.google.com").

nano_get_url(Host) ->
  {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
  ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
  receive_data(Socket, []).

receive_data(Socket, SoFar) ->
  receive
    {tcp, Socket, Bin} ->
      receive_data(Socket, [Bin|SoFar]);
    {tcp_closed, Socket} ->
      list_to_binary(reverse(SoFar))
  end.

start_nano_server() ->
  {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
    {reuseaddr, true},
    {active, true}]),
  {ok, Socket} = gen_tcp:accept(Listen),
  loop(Socket).

loop(Socket) ->
  receive
     {tcp, Socket, Bin} ->
        io:format("Server received binary = ~p~nFrom client:~p~n",[Bin, inet:peername(Socket)]),
        case binary_to_term(Bin) of
           {Mod, Fun, Args} ->
              Reply = apply(Mod, Fun, Args),
              io:format("Server replying = ~p~n",[Reply]),
              gen_tcp:send(Socket, term_to_binary(Reply));
           Value ->
              %% Str = binary_to_term(Value),
              io:format("Server (unpacked) ~p~n",[Value]),
              Reply = lib_misc:string2value(Value),
              io:format("Server replying = ~p~n",[Reply]),
              gen_tcp:send(Socket, term_to_binary(Reply))
        end,
        loop(Socket);
    {tcp_closed, Socket} ->
      io:format("Server socket closed~n")
  end.

start_seq_server() ->
  {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
    {reuseaddr, true}, {active, true}]),
  seq_loop(Listen).

seq_loop(Listen) ->
  {ok, Socket} = gen_tcp:accept(Listen),
  loop(Socket),
  seq_loop(Listen).

start_parallel_server() ->
  {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
    {reuseaddr, true}, {active, true}]),
  spawn(fun() -> par_connect(Listen) end).

par_connect(Listen) ->
  {ok, Socket} = gen_tcp:accept(Listen),
  io:format("server ~p got new request on ~p with socket value: ~p ~n",[self(), Listen, Socket]),
  spawn(fun() -> par_connect(Listen) end),
  loop(Socket).

nano_client_eval(Str) ->
  {ok, Socket} =
        gen_tcp:connect("localhost", 2345, [binary, {packet, 4}]),
  ok = gen_tcp:send(Socket, term_to_binary(Str)),
  receive
    {tcp, Socket, Bin} ->
      io:format("Client received binary = ~p~n",[Bin]),
      Val = binary_to_term(Bin),
      io:format("Client result = ~p~n", [Val]),
      gen_tcp:close(Socket)
  end.
nano_client_eval(Mod, Fun, Args) ->
  {ok, Socket} = gen_tcp:connect("localhost", 2345, [binary, {packet, 4}]),
  ok = gen_tcp:send(Socket, term_to_binary({Mod, Fun, Args})),
  receive
    {tcp, Socket, Response} ->
      io:format("Client result = ~p~n", [binary_to_term(Response)]),
      gen_tcp:close(Socket)
  end.

error_test() ->
  spawn(fun() -> error_test_server() end),
  lib_misc:sleep(2000),
  {ok, Socket} = gen_tcp:connect("localhost", 4321, [binary, {packet, 2}]),
  io:format("connected to:~p~n", [Socket]),
  gen_tcp:send(Socket, <<"123">>),
  receive
    Any ->
      io:format("Any=~p~n",[Any])
  end.

error_test_server() ->
  {ok, Listen} = gen_tcp:listen(4321, [binary, {packet, 2}]),
  {ok, Socket} = gen_tcp:accept(Listen),
  error_test_server_loop(Socket).

error_test_server_loop(Socket) ->
  receive
    {tcp, Socket, Data} ->
      io:format("received:~p~n",[Data]),
      _ = atom_to_list(Data),
      error_test_server_loop(Socket)
  end.