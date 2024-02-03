%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 2月 2024 12:01
%%%-------------------------------------------------------------------
-author("Administrator").
-record(pool, {pool_id, size, user, password, host, port, database, encoding, available=queue:new(), locked=gb_trees:empty(), waiting=queue:new(), start_cmds=[], conn_test_period=0, connect_timeout=infinity}).
-record(emysql_connection, {id, pool_id, encoding, socket, version, thread_id, caps, language, prepared=gb_trees:empty(), locked_at, alive=true, test_period=0, last_test_time=0, monitor_ref}).
-record(greeting, {protocol_version, server_version, thread_id, salt1, salt2, caps, caps_high, language, status, seq_num, plugin}).
-record(field, {seq_num, catalog, db, table, org_table, name, org_name, type, default, charset_nr, length, flags, decimals, decoder}).
-record(packet, {size, seq_num, data}).
-record(ok_packet, {seq_num, affected_rows, insert_id, status, warning_count, msg}).
-record(error_packet, {seq_num, code, status, msg}).
-record(eof_packet, {seq_num, status, warning_count}). % extended to mySQL 4.1+ format
-record(result_packet, {seq_num, field_list, rows, extra}).