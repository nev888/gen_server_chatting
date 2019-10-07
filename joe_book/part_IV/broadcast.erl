%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Aug 2019 16:54
%%%-------------------------------------------------------------------
-module(broadcast).
-author("hi").
-compile(export_all).
%% API

send(IoList) ->
  case inet:ifget("eth0", [broadaddr]) of
    {ok, [{broadaddr, Ip}]} ->
      {ok, S} = gen_udp:open(5010, [{broadcast, true}]),
      gen_udp:send(S, Ip, 6000, IoList),
      gen_udp:close(S);
    _ ->
        io:format("Bad interface name, or\n"
                  "broadcasting not supported\n")
  end.

listen() ->
  {ok, _} = gen_udp:open(6000),
  loop().

loop() ->
  receive
    Any -> io:format("received:~p~n", [Any]),
      loop()
  end.