%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Aug 2019 17:25
%%%-------------------------------------------------------------------
-module(importants).
-author("hi").

%% API
-export([init/0]).

init() -> init:get_argument(home).

%% when shell halts:
%% Ctrl + G
%% to start new job (shell) type the following:
%% s
%% j #to see the jobs
%% c 2 # to choose the second job

%% code:which(file).


%% Format                               Result
%% ======                              ========
%% io:format("|~10s|",["abc"])          |       abc|
%% io:format("|~-10s|",["abc"])         |abc       |
%% io:format("|~10.3.+s|",["abc"])      |+++++++abc|
%% io:format("|~-10.10.+s|",["abc"])    |abc+++++++|
%% io:format("|~10.7.+s|",["abc"])      |+++abc++++|






