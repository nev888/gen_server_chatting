%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Aug 2019 19:11
%%%-------------------------------------------------------------------
-module(scavenge_urls).
-author("hi").

%% API
-export([urls2htmlFile/2, bin2urls/1]).
-import(lists, [reverse/1, reverse/2, map/2]).

urls2htmlFile(Urls, File) ->
  file:write_file(File, urls2html(Urls)).

bin2urls(Bin) -> gather_urls(binary_to_list(Bin), []).

urls2html(Urls) -> [h1("Urls"),make_list(Urls)].

h1(Title) -> ["<h1>", Title, "<\/h1><br>"].

make_list(L) ->
  ["<ul><br>",
    map(fun(I) -> ["<li>",I,"</li><br>"] end, L),
    "</ul><br>"].

gather_urls("<a href" ++ T, L) ->
  {Url, T1} = collect_url_body(T, reverse("<a href")),
  gather_urls(T1, [Url|L]);
gather_urls([_|T], L) ->
  gather_urls(T, L);
gather_urls([], L) ->
  L.

collect_url_body("</a>" ++ T, L) -> {reverse(L, "</a>"), T};
collect_url_body([H|T], L) -> collect_url_body(T, [H|L]);
collect_url_body([], _) -> {[], []}.