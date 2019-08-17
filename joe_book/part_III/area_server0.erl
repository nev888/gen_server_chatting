%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 9:17
%%%-------------------------------------------------------------------
-module(area_server0).
-author("hi").

%% API
-export([loop/0]).

loop() ->
  receive
    {rectangle, Width, Ht} ->
     io:format("Area of rectangle is ~p~n",[Width * Ht]),
      loop();
    {square, Side} ->
      io:format("Area of square is ~p~n",[Side * Side]),
      loop()
  end.