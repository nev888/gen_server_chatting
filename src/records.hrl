%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2019 15:54
%%%-------------------------------------------------------------------
-author("hi").

-record(users, {username, fullname, status,  birthdate, password, date, friends=[]}).

-record(messages, {date, sender, receiver, content}).
