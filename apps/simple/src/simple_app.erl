%%%-------------------------------------------------------------------
%% @doc simple public API
%% @end
%%%-------------------------------------------------------------------

-module(simple_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    init_ets(),
    init_dets(),
    init_mysql(),
    simple_sup:start_link().

stop(_State) ->
    ok.

init_mysql() ->

    {ok, Host} = application:get_env(mysql, host, "127.0.0.1"),
    {ok, Port} = application:get_env(mysql, port, 3306),
    {ok, User} = application:get_env(mysql, user, "root"),
    {ok, Password} = application:get_env(mysql, password, "123456"),
    {ok, Database} = application:get_env(mysql, database, "game1"),
    {ok, Size} = application:get_env(mysql, size, 10),
    {ok, Encode} = application:get_env(mysql, encode, 'utf8'),
    simple_mysql:start(Host, Port, User, Password, Database, Encode, Size),
    ok.

init_ets() ->
    ets:new(test, [{keypos, 1}, named_table, public, set]),
    ok.

init_dets() ->
    ok.


%% internal functions
