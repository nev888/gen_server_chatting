%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Aug 2019 17:09
%%%-------------------------------------------------------------------
-module(types_bug).
-author("hi").

%% API
-export([f4/1]).

f4({H,M,S}) when is_float(H) ->
  print(H,M,S),
  (H+M*60)*60+S.

print(H,M,S) ->
  Str = integer_to_list(H) ++ ":" ++ integer_to_list(M) ++ ":" ++ integer_to_list(S),
  io:format("~s",[Str]).
