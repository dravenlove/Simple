%%%-------------------------------------------------------------------
%%% @author 78892
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 3月 2024 12:48
%%%-------------------------------------------------------------------
-module(tcp_client).

%% API
-export([
	start/1
]).

start(Port) ->
	{ok, Socket} = ranch_tcp:connect("127.0.0.1", Port, [{active, true}, {packet, 4}]),
	io:format("Connected to port ~p~n", [Port]),
	io:format("Connected to socket ~p~n", [Socket]),
	spawn(fun() -> loop(Socket) end).

loop(Socket) ->
	receive
		{send, Pack} ->
			ranch_tcp:send(Socket, Pack),
			loop(Socket);
		{tcp, Socket, Data} ->
			handle_data(Socket, Data),
			loop(Socket);
		{tcp_closed, Socket} ->
			handle_close(Socket);
		{error, Socket, Reason} ->
			io:format("Error on socket ~p: ~p~n", [Socket, Reason]),
			handle_close(Socket)
		after 10000 ->
			io:format("tcp client timeout!~n"),
			ranch_tcp:send(Socket, <<"timeout">>),
			loop(Socket)
	end.

handle_data(_Socket, Data) ->
	io:format("Received data: ~p~n", [Data]).

handle_close(Socket) ->
	io:format("Closing connection to ~p~n", [Socket]),
	gen_tcp:close(Socket).