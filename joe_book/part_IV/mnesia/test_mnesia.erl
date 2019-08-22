%%%-------------------------------------------------------------------
%%% @author hi
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Aug 2019 14:47
%%%-------------------------------------------------------------------
-module(test_mnesia).
-author("hi").

%% API
-export([init_db/0, start/0, fill_tables/0, demo/1, do/1, add_shop_item/3, remove_shop_item/1,
  farmer/1, reset_tables/0, add_plans/0, get_plan/1]).
-include_lib("stdlib/include/qlc.hrl").
-import(lists,[foreach/2]).
-record(shop, {item, quantity, cost}).
-record(cost, {name, price}).
-record(design, {id, plan}).

init_db() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(shop, [{attributes, record_info(fields, shop)}]),
  mnesia:create_table(cost, [{attributes, record_info(fields, cost)}]),
  mnesia:create_table(design, [{attributes, record_info(fields, design)}]),
  mnesia:stop().

start() ->
  mnesia:start(),
  mnesia:wait_for_tables([shop, cost, design], 2000).

fill_tables() ->
  insert_into_table(shop_records()),
  insert_into_table(cost_records()),
  ok.

insert_into_table(Records) ->
  F = fun() ->
      foreach(fun(Re) ->
      mnesia:write(Re)
      end, Records) end,
    mnesia:transaction(F).

shop_records() ->
  [
    #shop{item = apple, quantity = 20, cost = 2.3},
    #shop{item = orange, quantity = 100, cost = 3.8},
    #shop{item = pear, quantity = 200, cost = 3.6},
    #shop{item = banana, quantity = 420, cost = 4.5},
    #shop{item = potato, quantity = 2456, cost = 1.2}
  ].

cost_records() ->
  [
    #cost{name = apple, price = 1.5},
    #cost{name = orange, price = 2.4},
    #cost{name = pear, price = 2.2},
    #cost{name = banana, price = 1.5},
    #cost{name = potato, price = 0.6}
  ].


demo(select_shop) ->
  do(qlc:q([X || X <- mnesia:table(shop)]));
demo(select_some) ->
  do(qlc:q([{X#shop.item, X#shop.quantity} || X <- mnesia:table(shop)]));
demo(reorder) ->
  do(qlc:q([X#shop.item || X <- mnesia:table(shop),
     X#shop.quantity < 250 ]));
demo(join) ->
  do(qlc:q([X#shop.item || X <- mnesia:table(shop), X#shop.quantity < 250,
    Y <- mnesia:table(cost), X#shop.item =:= Y#cost.name, Y#cost.price < 2]));
demo(_) -> ok.

do(Query) ->
    F = fun() -> qlc:e(Query) end,
    {atomic, Value} = mnesia:transaction(F),
    Value.

add_shop_item(Name, Quantity, Cost) ->
  Row = #shop{item=Name, quantity=Quantity, cost=Cost},
  F = fun() ->
    mnesia:write(Row)
      end,
  mnesia:transaction(F).

remove_shop_item(Item) ->
  Oid = {shop, Item},
  F = fun() ->
            mnesia:delete(Oid)
      end,
  mnesia:transaction(F).

farmer(Nwant) ->
  %% Nwant = Number of oranges the farmer wants to buy
  F = fun() ->
              %% find the number of apples
              [Apple] = mnesia:read({shop, apple}),
              Napples = Apple#shop.quantity,
              Apple1 = Apple#shop{quantity = Napples + 2*Nwant},
              %% update the database
              mnesia:write(Apple1),
              %% find the number of oranges
              [Orange] = mnesia:read({shop, orange}),
              NOrange = Orange#shop.quantity,
              if
                NOrange >= Nwant ->
                  N1 = NOrange - Nwant,
                  Orange1 = Orange#shop{quantity = N1},
                  %% update the database
                  mnesia:write(Orange1);
                true ->
                  %% Oops -- not enough oranges
                  mnesia:abort(oranges)
              end
        end,
  mnesia:transaction(F).

example_tables() ->
  [%% The shop table
    {shop, apple,   20,   2.3},
    {shop, orange,  100,  3.8},
    {shop, pear,    200,  3.6},
    {shop, banana,  420,  4.5},
    {shop, potato,  2456, 1.2},
    %% The cost table
    {cost, apple,   1.5},
    {cost, orange,  2.4},
    {cost, pear,    2.2},
    {cost, banana,  1.5},
    {cost, potato,  0.6}
  ].

reset_tables() ->
  mnesia:clear_table(shop),
  mnesia:clear_table(cost),
  F = fun() ->
    foreach(fun mnesia:write/1, example_tables())
      end,
  mnesia:transaction(F).

add_plans() ->
  D1 = #design{id = {joe, 1},
       plan = {circle, 10}},
  D2 = #design{id = fred,
       plan = {rectangle, 10, 5}},
  D3 = #design{id = {jane, {house, 23}},
       plan = {house,
              [{floor,1,
               [{doors, 3},
                {windows, 12},
                {rooms, 5}]},
               {floor, 2,
               [{doors, 2},
                {rooms, 4},
                {windows, 15}]}]}},
  F = fun() ->
            mnesia:write(D1),
            mnesia:write(D2),
            mnesia:write(D3)
      end,
  mnesia:transaction(F).

get_plan(PlanId) ->
  F = fun() -> mnesia:read({design, PlanId}) end,
  mnesia:transaction(F).
