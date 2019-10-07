%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Aug 2019 12:13
%%%-------------------------------------------------------------------
-module(talk_erl).
-author("hi").

%% API
-export([start/0]).

start() ->
  Node = list_to_atom(io:get_line("Enter the node you want to communicate with:")--"\n"),
  register(receiver,spawn(fun() -> receive_message() end)),
  register(sender,spawn(fun() -> send_message(Node) end)).

receive_message() ->
  receive
    Message -> io:format("Message: ~p~n",[Message]),
                receive_message()
  end.

send_message(Node) ->
    receive
      Message ->  {receiver, Node} ! Message, send_message(Node)
    end.