%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Jun 2019 21:24
%%%-------------------------------------------------------------------
-module(server_interface).
-author("hi").

-behaviour(gen_server).

%% API
-export([
  start/0,
  stop/0
  ]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-compile(export_all).

-include("records.hrl").
-include("macros.hrl").

-record(state, {started, users}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------

start() ->
  db_interface:start(),
  gen_server:start({local, ?SERVER_NAME}, ?MODULE, [], []).

stop() ->
  gen_server:stop(?SERVER_NAME, exit, 30).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {ok, #state{started = calendar:local_time(), users=[]}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(default, _From, State) ->
  {reply, successful, State};
%%   handling client gen_server requests
handle_call({signup, Username, Fullname, Password, Birthdate}, {Pid, _}, State) ->
       io:format("Username ~p tries to sign up!~n~p~n",[Username,Pid]),
       case is_username_taken(Username) of
         true ->   case db_interface:create_user({Username, Fullname, Password, Birthdate}) of
                        ok -> io:format("User ~p signed up successfully~n",[Username]),
                              {reply, successful, update_state({Username, Pid},State)};
                        Error -> io:format("failed sign up attempt~n",[]),
                                 {reply, Error, State}
                    end;
         false ->  {reply, username_taken, State}
       end;
handle_call({signin, Username, Password}, {Pid, _}, State) ->
  io:format("Username ~p tries to sign in!~n~p",[Username,Pid]),
  case db_interface:return_user(Username) of
    [] -> {reply, username_not_found, State};
    [User] -> case  User#users.password == Password of
              true -> io:format("User ~p signed in successfully~n",[Username]),
                      {reply, successful, update_state({Username, Pid},State)};
              _ ->    io:format("incorrect password attempt~n",[]),
                      {reply, incorrect_password, State}
            end
  end;
handle_call({delete, Username, Password}, _From, State) ->
  io:format("Username ~p tries to delete the account~n",[Username]),
  case db_interface:return_friends(Username) of
    [] -> {reply, username_not_found, State};
    [User] ->  case  User#users.password == Password of
                     true -> io:format("User ~p deleted successfully~n",[Username]),
                             {reply, db_interface:delete_user(Username), update_state({delete, Username}, State)};
                     _ ->    io:format("incorrect password attempt~n",[]),
                             {reply, incorrect_password, State}
               end
  end;
handle_call({send_message, Sender, Receiver, Message}, _From, State) ->
  io:format("Username ~p tries to send message to ~p~n",[Sender, Receiver]),
  case {db_interface:return_user(Sender), db_interface:return_user(Receiver)} of
    {[], _} -> {reply, your_username_not_registered, State};
    {_, []} -> {reply, receiver_not_exist, State};
    {_, [User2]} -> db_interface:put_message(send, Sender, Receiver, Message),
         db_interface:put_message(reseive, Sender, Receiver, Message),
         io:format("~p ------send------> ~p~n",[Sender, Receiver]),
         User2#users.status == online andalso fetch_user_pid(Receiver, State) ! Sender ++ " sent: " ++ Message
  end;
handle_call({}, _From, State) ->
  {reply, sent, State}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
is_username_taken(Username) ->
  Username == not_logged_in andalso db_interface:return_user(Username) == [].

update_state({delete, Username}, State) ->
  Users = State#state.users,
  State#state{users = lists:keydelete(Username, 1,Users)};
update_state(User, State) ->
  Old_users = State#state.users,
  State#state{users = User++Old_users}.

fetch_user_pid(Receiver, State) ->
  Users = State#state.users,
  lists:keyfind(Receiver, 1, Users).