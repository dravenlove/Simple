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
    init_net(),
    simple_sup:start_link().

stop(_State) ->
    ok.

init_net() ->
    application:start(ranch),
    TcpAcceptor = application:get_env(simple, tcp_acceptor_num, 10),
    TcpPort = application:get_env(simple, tcp_port, 9999),
    {ok, _} = ranch:start_listener(simple_app, TcpAcceptor, ranch_tcp, [{port, TcpPort}], simple_net, []),
    ok.

init_mysql() ->
    Host = application:get_env(simple, mysql_host, "127.0.0.1"),
    Port = application:get_env(simple, mysql_port, 3306),
    User = application:get_env(simple, mysql_user, "root"),
    Password = application:get_env(simple, mysql_password, "123456"),
    Database = application:get_env(simple, mysql_database, "game1"),
    Size = application:get_env(simple, mysql_size, 10),
    Encode = application:get_env(simple, mysql_encode, 'utf8'),
    simple_mysql:start(Host, Port, User, Password, Database, Encode, Size),
    ok.

init_ets() ->
    ets:new(test, [{keypos, 1}, named_table, public, set]),
    ok.

init_dets() ->
    ok.


%% internal functions
