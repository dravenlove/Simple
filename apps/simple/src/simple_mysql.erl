%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 1月 2024 17:21
%%%-------------------------------------------------------------------
-module(simple_mysql).
-author("Administrator").
-include("emysql.hrl").
-include("../include/log.hrl").


%% API
-export([
    start/7,
    start/8,
    execute/1,
    execute/3
%%    insert/1,
%%    insert/3
]).

-define(POOL_NAME, 'database').

start(Host, Port, User, Password, DataBase, Encode, Size) ->
    application:start(emysql),
    start(?POOL_NAME, Host, Port, User, Password, DataBase, Encode, Size).

start(PoolID, Host, Port, User, Password, DataBase, Encode, Size) ->
    emysql:add_pool(PoolID, Size, User, Password, Host, Port, DataBase, Encode),
    ok.

execute(Sql) ->
    execute(?POOL_NAME, Sql, 10000).

execute(PoolID, Sql, Timeout) ->
    case emysql:execute(PoolID, Sql, Timeout) of
        #result_packet{rows = Rows} ->
            Rows;
        #ok_packet{affected_rows = R} ->
            R;
        #error_packet{code = Code, msg = Msg} ->
            ?ERROR("emysql_halt:Sql ~p, Code ~p Msg ~p", [Sql, Code, Msg])
    end.
%%
%%insert(Sql) ->
%%    insert(?POOL_NAME, Sql).
