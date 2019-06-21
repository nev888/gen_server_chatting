%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Jun 2019 21:24
%%%-------------------------------------------------------------------
-module(client_interface).
-author("hi").

-behaviour(gen_server).
-include("records.hrl").
-include("macros.hrl").

-record(state, {username, node}).

-compile(export_all).

%% Starting
-export([
  start/0,
  stop/0
]).

%% API
-export([
  sign_up/4,
  sign_in/2,
  sign_out/0,
  delete/2,
  send_message/2,
  send_request/1,
  update_profile/2,
  setting/0
]).

%% callback functions
-export ([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).
%%-------------------------------------- Starting the client -----------------------------------------------------------
start() ->
  gen_server:start({local, ?CLIENT_NAME}, ?MODULE, [], []),
  io:format("Sign in with sign_in(Username, Password)~nSign up with sign_up(Username, Fullname, Password, Birthdate)~n",[]).

init(_) ->
  {ok, #state{username = not_logged_in}}.

stop() ->
  gen_server:stop(?CLIENT_NAME, exit, 30).

%%------------------------------------ User API ----------------------------------------------------------------------


sign_up(Username, Fullname, Password, Birthdate) ->
  case gen_server:call(?CLIENT_NAME, {signup, Username, Fullname, Password, Birthdate}) of
    successful -> io:format("Signed up successfully~ncheck settings and options by setting()~n",[]);
    Error -> Error
  end.

sign_in(Username, Password) ->
  case gen_server:call(?CLIENT_NAME, {signin, Username, Password}) of
    successful -> io:format("Signed in successfully~nCheck your setting and options by setting()~n",[]);
    Error -> Error
  end.

sign_out() ->
   gen_server:call(?CLIENT_NAME, signout).

setting()->
  User = gen_server:call(?CLIENT_NAME, {user_info}),
  io:format("~p~n",[User]),
  io:format("-------------------------- User Informations --------------------------~nUsername: ~p~nFullname: ~p~nBirthdate: ~p~nFriends: ~p~n",
                            [User#users.username, User#users.fullname, User#users.birthdate, User#users.friends]),
  io:format("-------------------------- Settings --------------------------~nSend message: send_message(User, Message)~nSend request: send_request(User)~n"++
   "Update profile: update_profile(What_to_update, New_Value)~nDelete account: delete(Username, Password)~n",[]).

delete(Username, Password) ->
  gen_server:call(?CLIENT_NAME, {delete, Username, Password}).

send_message(User, Message) ->
  gen_server:call(?CLIENT_NAME, {send_message, User, Message}).

send_request(User) ->
  gen_server:call(?CLIENT_NAME, {send_request, User}).

update_profile(What_to_Update, New_Value) ->
  gen_server:call(?CLIENT_NAME, {update, What_to_Update, New_Value}).

delete_request(User) ->
  gen_server:call(?CLIENT_NAME, {delete_request, User}).

%%------------------------------------- gen_server callback functions ------------------------------------------------

handle_call(Request={signup, Username, _Fullname, _Password, _Birthdate}, _From, State) ->
  if
    State#state.username == not_logged_in ->
    case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
          successful -> {reply, successful, #state{username = Username, node = node()}};
          Not_Valid -> {reply, Not_Valid, State}
    end;
    true ->  {reply, aready_logged_in, State}
  end;
handle_call(Request={signin, Username, _Password}, _From, State) ->
  if
    State#state.username == not_logged_in ->
    case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
          successful -> {reply, successful, #state{username = Username, node = node()}};
          Not_Valid ->  {reply, Not_Valid, State}
    end;
    true ->  {reply, aready_logged_in, State}
  end;
handle_call(signout, _From, State) ->
  if
    State#state.username /= not_logged_in ->
      case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, {signout,State#state.username}) of
           signed_out_successfully -> {reply, signed_out_successfully, #state{username = not_logged_in}};
           Err -> {reply, Err, State}
      end;
      true -> {reply, not_logged_in, State}
  end;
handle_call(Request={delete, _Username, _Password}, _From, State) ->
  if
    State#state.username /= not_logged_in ->
  case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
       successful -> {reply, deleted_successfully, #state{username = not_logged_in}};
       Not_Valid -> {reply, Not_Valid, State}
  end;
    true -> {reply, not_logged_in, State}
  end;
handle_call(Request, _From, State) ->
  case State#state.username /=  not_logged_in of
       true ->  {reply, gen_server:call({?SERVER_NAME, ?SERVER_NODE}, append_into_tuple(State#state.username, Request)), State};
       false -> {reply, not_logged_in, State}
  end.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(Info, State) ->
  io:format("~p~n",[Info]),
  {noreply, State}.
 %% {noreply,NewState,Timeout}
 %% {noreply,NewState,hibernate}
 %% {noreply,NewState,{continue,Continue}}
 %% {stop,Reason,NewState}

terminate(Reason, _State)->
  Reason.

code_change(_Oldversion, _State, _Extra) ->
  ok.

%% private methods

append_into_tuple(Atom, Tuple) ->
  [H|T]=tuple_to_list(Tuple),
  list_to_tuple([H,Atom|T]).

%% debugging printing the line
pr(L) -> io:format("Line ~p~n",[L]).