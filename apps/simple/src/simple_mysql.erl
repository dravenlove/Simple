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
-include("simple_mysql.hrl").
-include("log.hrl").


%% API
-export([
    start/7,
    start/8,
    execute/1,
    execute/3,
    insert/3,
    update/5,
    delete/3,
    select/3
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

%%create table user (uuid int(10), name varchar(255), PRIMARY KEY(uuid));
%%"insert into user(uuid) value (1)"
%%simple_mysql:insert("user", ["uuid", "name"], ["123345", <<"'test'">>]).
insert(Table, Keys, Values) ->
    KeysString = string:join(Keys, ","),
    ValuesString = string:join(Values, ","),
    Sql = io_lib:format("INSERT INTO ~s (~s) values (~s);", [Table, KeysString, ValuesString]),
    io:format("Sql:~ts~n", [Sql]),
    execute(Sql).

update(Table, Keys, Values, MainKey, MainValues) ->
    % 生成 "column = value" 形式的字符串列表
    KvString = lists:zipwith(
        fun(Key, Value) ->
            io_lib:format("~s = ~s", [Key, Value])
        end, Keys, Values),
    MainKvString = lists:zipwith(
        fun(Key, Value) ->
            io_lib:format("~s = ~s", [Key, Value])
        end, MainKey, MainValues),
    % 将所有 "column = value" 字符串连接成一个由逗号分隔的字符串
    KvString1 = string:join(KvString, ", "),
    KvString2 = string:join(MainKvString, ", "),
    Sql = io_lib:format("UPDATE ~s SET ~s WHERE ~s;", [Table, KvString1, KvString2]),
    execute(Sql).

delete(Table, Keys, Values) ->
    % 生成 "column = value" 形式的字符串列表
    KvString = lists:zipwith(
        fun(Key, Value) ->
            io_lib:format("~s = ~s", [Key, Value])
        end, Keys, Values),
    % 将所有 "column = value" 字符串连接成一个由逗号分隔的字符串
    KvString1 = string:join(KvString, ", "),
    Sql = io_lib:format("DELETE FROM ~s WHERE ~s;", [Table, KvString1]),
    io:format("Sql:~ts~n", [Sql]),
    execute(Sql).

select(Table, Keys, Values) ->
    % 生成 "column = value" 形式的字符串列表
    KvString = lists:zipwith(
        fun(Key, Value) ->
            io_lib:format("~s = ~s", [Key, Value])
        end, Keys, Values),
    % 将所有 "column = value" 字符串连接成一个由逗号分隔的字符串
    KvString1 = string:join(KvString, ", "),
    Sql = io_lib:format("SELECT * FROM ~s WHERE ~s;", [Table, KvString1]),
    io:format("Sql:~ts~n", [Sql]),
    execute(Sql).
