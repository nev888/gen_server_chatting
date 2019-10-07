-module(macro).
-compile(export_all).


-define(debug(Format, Args), debug(?FILE, ?LINE, Format, Args)).

debug(File, Line, Format, Args) ->
  io:format("~s:~b: "++ Format, [File, Line] ++ Args).

deb() -> ?debug("~p tried ~p",[adam, run]).
