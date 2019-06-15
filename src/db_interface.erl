%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2019 15:53
%%%-------------------------------------------------------------------
-module(db_interface).
-author("hi").

%% General API
-export([start/0, install/0, reset/0]).
%% User API
-export([create_user/1, delete_user/1, update_user/3]).
%% Message API
-export ([put_message/3, delete_message/2, return_all_message/1]).

-include("macros.hrl").
-include("records.hrl").


%% public API
start() ->
  mnesia:start().

install() ->
  ok = mnesia:create_schema([node()]),
  mnesia:start(),
  create_table(users, record_info(fields, users), [{type, set}]).

reset() ->
  Users = mnesia:dirty_all_keys(users),
  [mnesia:delete_table(User) || User <- Users],
  mnesia:delete_table(users),
  mnesia:stop(),
  mnesia:delete_schema([node()]).

%%--------------------------------------------------- User API ------------------------------------------------------------
create_user({Username, Fullname, Birthdate, Password}) ->
  create_table(Username, record_info(fields, messages), [{record_name, messages}, {type, bag}]),
  User = #users{username = Username, fullname = Fullname, status = online, birthdate = Birthdate, password = Password, date = calendar:local_time()},
  insert(User).

delete_user(Username) ->
  mnesia:delete_table(Username),
  F = fun() ->
    mnesia:delete({users, Username})
      end,
  mnesia:activity(transaction, F).

update_user(Username, What_To_Update, New_Value) ->
  F = fun() ->
    [User] = mnesia:wread({users, Username}),
    case What_To_Update of
      fullname   ->     mnesia:write(User#users{ fullname = New_Value});
      password   ->     mnesia:write(User#users{ password = New_Value});
      status     ->     mnesia:write(User#users{ status = New_Value});
      birthdate  ->     mnesia:write(User#users{ birthdate = New_Value});
      friends    ->     mnesia:write(User#users{ friends = New_Value})
    end
      end,
  mnesia:activity(transaction, F).

%%----------------------------- Message API -----------------------------------------------------------------------------------
put_message(Sender, Receiver, Content) ->
  Message = #messages{sender = Sender, receiver = [Receiver], content = Content, date = calendar:local_time()},
  insert(Sender, Message),
  insert(Receiver, Message).

delete_message(Tablename, Timestamp) ->
  mnesia:dirty_delete({Tablename, Timestamp}).

return_all_message(Username) ->
Message = #messages{sender = '$1', receiver = '$2', date = '$3', content = '$4'},
F = fun() ->
         mnesia:select(Username, [{Message, [], ['$$']}])
    end,
  case  mnesia:transaction(F) of
    {atomic, Message} -> Message;
    Error -> Error
  end.


%% private API
create_table(Name, Attributes, Options) ->
  mnesia:create_table(Name,
                     [{attributes, Attributes},
                      {disc_copies, [?SERVER]} | Options]).

insert(Record) ->
  F = fun() ->
    mnesia:write(Record)
      end,
  mnesia:activity(transaction, F).


insert(Table, Record) ->
  F = fun() ->
    mnesia:write(Table, Record,write)
      end,
  mnesia:activity(transaction, F).
