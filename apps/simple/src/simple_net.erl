%%%-------------------------------------------------------------------
%%% @author 78892
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 3月 2024 11:46
%%%-------------------------------------------------------------------
-module(simple_net).
-include("log.hrl").
-behaviour(gen_server).

%% API
-export([
	start_link/0,
	start_link/4
]).

%% gen_server callbacks
-export([
	init/0,
	init/1,
	init/4,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3
]).

-record(net_state, {
	rec_time = 0
}).

-record(simple_net_state, {
	socket :: port(),
	transport = undefined :: atom(),
	handler = undefined :: atom(),
	recv_res = <<>> :: binary(),
	stat = #net_state{},
	sends = [] :: list(),
	udata = [] :: list()
}).

-define(TCP_OPTIONS, [
	{packet, 0},
	{nodelay, true},
	{delay_send, false},
	{send_timeout, 15000},
	{send_timeout_close, true},
	{keepalive, false},
	{exit_on_close, true}]).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Spawns the server and registers the local name (unique)
-spec(start_link() ->
	{ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start_link(Ref, Socket, Transport, Opts) ->
	?INFO("server Socket:~p~n", [Socket]),
	Pid = proc_lib:spawn_link(?MODULE, init, [[Ref, Socket, Transport, Opts]]),
%%	register(test, Pid),
	{ok, Pid}.

%%	proc_lib:start_link(?MODULE, init, [[Ref, Socket, Transport, Opts]]).


%%	gen_server:start_link({local, ?MODULE}, ?MODULE, [Ref, Socket, Transport, Opts], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: term()) ->
	{ok, State :: #simple_net_state{}} | {ok, State :: #simple_net_state{}, timeout() | hibernate} |
	{stop, Reason :: term()} | ignore).
init() ->
	State = #simple_net_state{},
	gen_server:enter_loop(?MODULE, [], State).
init([]) ->
	{ok, #simple_net_state{}};


init([Ref, Socket, Transport, Handler]) ->
	Handler1 =
		case Handler of
			[H] ->
				H;
			_ -> undefined
		end,
%%	{ok, Socket} = ranch:handshake(Ref),
	ok = ranch:accept_ack(Ref),


	ok = Transport:setopts(Socket, [{active, true} | ?TCP_OPTIONS]),
	erlang:put(fg_net_tcp_socket, Socket),
	Stat =
		#net_state{
			rec_time = 0
		},
	State =
		#simple_net_state{
			socket = Socket,
			transport = Transport,
			handler = Handler1,
			recv_res = <<>>,
			stat = Stat,
			sends = [],
			udata = []
		},
	gen_server:enter_loop(?MODULE, [], State).

init(_Ref, Socket, Transport, [Handler]) ->
	ok = Transport:setopts(Socket, [{active, true} | ?TCP_OPTIONS]),
	erlang:put(fg_net_tcp_socket, Socket),
	Stat =
		#net_state{
			rec_time = 0
		},
	State =
		#simple_net_state{
			socket = Socket,
			transport = Transport,
			handler = Handler,
			recv_res = <<>>,
			stat = Stat,
			sends = [],
			udata = []
		},
	gen_server:enter_loop(?MODULE, [], State).

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
	State :: #simple_net_state{}) ->
	{reply, Reply :: term(), NewState :: #simple_net_state{}} |
	{reply, Reply :: term(), NewState :: #simple_net_state{}, timeout() | hibernate} |
	{noreply, NewState :: #simple_net_state{}} |
	{noreply, NewState :: #simple_net_state{}, timeout() | hibernate} |
	{stop, Reason :: term(), Reply :: term(), NewState :: #simple_net_state{}} |
	{stop, Reason :: term(), NewState :: #simple_net_state{}}).
handle_call(Request, _From, State = #simple_net_state{}) ->
	?ERROR("Tcp Call Request:~p~n", [Request]),
	{reply, ok, State}.

%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #simple_net_state{}) ->
	{noreply, NewState :: #simple_net_state{}} |
	{noreply, NewState :: #simple_net_state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #simple_net_state{}}).
handle_cast(Request, State = #simple_net_state{}) ->
	?ERROR("Tcp Cast Request:~p~n", [Request]),
	{noreply, State}.

%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #simple_net_state{}) ->
	{noreply, NewState :: #simple_net_state{}} |
	{noreply, NewState :: #simple_net_state{}, timeout() | hibernate} |
	{stop, Reason :: term(), NewState :: #simple_net_state{}}).
handle_info({tcp, _Socket, Data}, State = #simple_net_state{}) ->
	?ERROR("tcp ~p~n", [Data]),
	{noreply, State};
handle_info(Info, State) ->
	?ERROR("Tcp info Request:~p~n", [Info]),
	{noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
	State :: #simple_net_state{}) -> term()).
terminate(Reason, _State = #simple_net_state{}) ->
	io:format("terminate ~p~n", [Reason]),
	ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #simple_net_state{},
	Extra :: term()) ->
	{ok, NewState :: #simple_net_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #simple_net_state{}, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
