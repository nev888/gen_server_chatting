%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Aug 2019 21:54
%%%-------------------------------------------------------------------
-module(exercise).
-author("hi").

%% API
-export([init/0, start/0, create_tables/0]).

-record(users, {name, email, password}).
-record(tips, {url, description, date_of_review}).
-record(abuse, {ip, number_of_vist}).

init() ->
  mnesia:create_schema([node()]).

start() ->
  mnesia:start().

create_tables() ->
  mnesia:create_table(users, [{attributes, record_info(fields, users)}, {disc_copies, [node()]}]),
  mnesia:create_table(tips, [{attributes, record_info(fields, tips)}, {disc_copies, [node()]}]),
  mnesia:create_table(abuse, [{attributes, record_info(fields, abuse)}, {disc_copies, [node()]}]),
  ok.

