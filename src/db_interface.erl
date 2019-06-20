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
-export([create_user/1, delete_user/1, update_user/3, return_user/1, return_friends/1]).
%% Message API
-export ([put_message/4, delete_message/2, return_all_messages/1, return_messages_specific_person/2, return_message_at_time/2]).

-include("macros.hrl").
-include("records.hrl").

-compile(export_all).

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
create_user({Username, Fullname, Password, Birthdate}) ->
  create_table(Username, record_info(fields, messages), [{record_name, messages}, {type, bag}]),
  User = #users{username = Username, fullname = Fullname, status = online, password = Password, birthdate = Birthdate, date = calendar:local_time()},
  insert(User).

return_user(Username) ->
  mnesia:dirty_read({users, Username}).

return_friends(Username) ->
  [Record] = mnesia:dirty_read({users, Username}),
  Record#users.friends.

return_all_users() ->
  Users = #users{username = '$1', fullname = '$2', status = '$3', birthdate = '$4', password = '$5', date = '$6', friends = '$7'},
  F = fun() ->
           mnesia:select(users, [{Users, [], ['$$']}])
      end,
  case mnesia:transaction(F) of
    {atomic, User_List} -> flattener(User_List);
    Error -> Error
  end.

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
put_message(send, Sender, Receiver, Content) ->
  Message = #messages{sender = self, receiver = Receiver, content = Content, date = calendar:local_time()},
  insert(Sender, Message);
put_message(reseive, Sender, Receiver, Content) ->
  Message = #messages{sender = Sender, receiver = self, content = Content, date = calendar:local_time()},
  insert(Receiver, Message).

delete_message(Tablename, Timestamp) ->
  mnesia:dirty_delete({Tablename, Timestamp}).

return_all_messages(Username) ->
Record = #messages{sender = '$1', receiver = '$2', date = '$3', content = '$4'},
F = fun() ->
         mnesia:select(Username, [{Record, [], ['$$']}])
    end,
  case  mnesia:transaction(F) of
    {atomic, List_Messages} -> flattener(List_Messages);
    Error ->  Error
  end.

return_messages_specific_person(Username, Specific_Person) ->
  Record = #messages{sender = '$1', receiver = '$2', date = '$3', content = '$4'},
  F = fun() ->
       mnesia:select(Username, [{Record, [{'or',{'==','$1',Specific_Person} ,{'==', '$2', Specific_Person}}], ['$$']}])
      end,
  case mnesia:transaction(F) of
    {atomic, List_Messages} -> flattener(List_Messages);
    Error -> Error
  end.

return_message_at_time(Username, Time) ->
  mnesia:dirty_read({Username, Time}).

%% private API
create_table(Name, Attributes, Options) ->
  mnesia:create_table(Name,
                     [{attributes, Attributes},
                      {disc_copies, [?SERVER_NODE]} | Options]).

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


flattener([H]) -> [list_to_tuple(H)];
flattener([H|T]) ->
  [list_to_tuple(H)|flattener(T)].