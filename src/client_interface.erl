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

%% Starting
-export([
  start/0
]).

%% API
-export([
  sign_up/4,
  sign_in/2,
  delete/2,
  send_message/2,
  send_request/1,
  update_profile/2
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
  gen_server:start({local, ?CLIENT_NAME}, ?MODULE, [], []).

init(_) ->
  {ok, #state{}}.

%%------------------------------------ User API ----------------------------------------------------------------------


sign_up(Username, Fullname, Password, Birthdate) ->
  gen_server:call(?CLIENT_NAME, {signup, Username, Fullname, Password, Birthdate}).

sign_in(Username, Password) ->
  gen_server:cast(?CLIENT_NAME, {signin, Username, Password}).

delete(Username, Password) ->
  gen_server:call(?CLIENT_NAME, {delete, Username, Password}).

send_message(User, Message) ->
  gen_server:call(?CLIENT_NAME, {send_message, User, Message}).

send_request(User) ->
  gen_server:call(?CLIENT_NAME, {send_request, User}).

update_profile(What_to_Update, New_Value) ->
  gen_server:call(?CLIENT_NAME, {update, What_to_Update, New_Value}).

%%------------------------------------- gen_server callback functions ------------------------------------------------

handle_call(Request={signup, Username, _Fullname, _Password, _Birthdate}, _From, State) ->
 case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
      successful -> {reply, signup_successful, #state{username = Username, node = node()}};
      Not_Valid -> {reply, Not_Valid, State}
 end;
handle_call(Request={signin, Username, _Passwrd}, _From, State) ->
  case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
    successful -> {reply, signed_in_successfully, #state{username = Username, node = node()}};
    Not_Valid -> {reply, Not_Valid, State}
  end;
handle_call(Request={send_message, _User, _Message}, _From, State) ->
  case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
    successful -> {reply, sent, State};
    Not_Valid -> {reply, Not_Valid, State}
  end;
handle_call(Request={delete, _Username, _Password}, _From, State) ->
  case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
    successful -> {reply, deleted_successfully, #state{}};
    Not_Valid -> {reply, Not_Valid, State}
  end;
handle_call(Request={send_request, _User}, _From, State) ->
  case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
    successful -> {reply, sent, State};
    Not_Valid -> {reply, Not_Valid, State}
  end;
handle_call(Request={update, What_to_update, _New_Value}, _From, State) ->
  case gen_server:call({?SERVER_NAME, ?SERVER_NODE}, Request) of
    successful -> {reply, {What_to_update, updated_successfully}, State};
    Not_Valid -> {reply, Not_Valid, State}
  end.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(Info, State) ->
  io:format("Info: ~p,          State: ~p",[Info, State]),
  {noreply, State}.
 %% {noreply,NewState,Timeout}
 %% {noreply,NewState,hibernate}
 %% {noreply,NewState,{continue,Continue}}
 %% {stop,Reason,NewState}

terminate(Reason, _State)->
  Reason.

code_change(_Oldversion, _State, _Extra) ->
  ok.
