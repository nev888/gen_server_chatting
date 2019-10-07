%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Aug 2019 10:15
%%%-------------------------------------------------------------------
-module(binary_exercise).
-author("hi").

%% API
-export([reverse_bytes/1, term_to_packet/1, packet_to_term/1, reverse_bits/1, triples_to_bin/1]).

reverse_bytes(Bytes) ->
  reverse_bytes(Bytes,<<>>).

reverse_bytes(<<>>,Acc) -> Acc;
reverse_bytes(Bytes,Acc) ->
  case split_binary(Bytes,1) of
    {Byte, Rest} ->
      reverse_bytes(Rest,<<Byte/binary,Acc/binary>>)
  end.

term_to_packet(Term) ->
  Bin = term_to_binary(Term),
  Length = byte_size(Bin),
  <<Length:4/integer,Bin/binary>>.

packet_to_term(<<L:4,Rest/binary>>) ->
  {L, binary_to_term(Rest)}.

reverse_bits(Bits) -> reverse_bits(Bits, <<>>).

reverse_bits(<<>>, Acc) -> Acc;
reverse_bits(<<F:1/bitstring,Rest/bitstring>>,Acc) ->
  reverse_bits(Rest,<<F:1/bitstring,Acc/bitstring>>).
  %% << <<X>> || <<X:1>> <= Byte>>.

triples_to_bin(T) ->
  triples_to_bin(T, <<>>).

triples_to_bin([{X,Y,Z} | T], Acc) ->
  triples_to_bin(T, <<Acc/binary,X:32,Y:32,Z:32>>);
triples_to_bin([], Acc) ->
  Acc.