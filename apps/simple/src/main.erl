%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 1月 2024 15:57
%%%-------------------------------------------------------------------
-module(main).
-author("Administrator").

%% API
-export([
    start/0,
    stop/0,
    exec/0
]).

start() ->
    %% error log , application event, app upgrade (code hot up), report and monitor
    application:start(sasl),
    %% random and encrypt
    application:start(crypto),
    %% cpu and memory and disk use info,process and port info, warning and notice, node monitor
    application:start(os_mon),
    %% process register and search
    {ok, _} = application:ensure_all_started(gproc),
    application:start(jiffy),
    application:start(lager),
    application:start(simple).

%% todo
stop() ->
    application:stop(simple),
    application:stop(lager),
    application:stop(jiffy),
    application:stop(gproc),
    application:stop(os_mon),
    application:stop(crypto),
    application:stop(sasl).

exec() ->
    [Node, Mod, Func] = init:get_plain_arguments(),
    Node1 = list_to_atom(Node),
    Mod1 = list_to_atom(Mod),
    Func1 = list_to_atom(Func),
    erlang:monitor_node(Node1, true),
    Code =
        case rpc:call(Node1, Mod1, Func1, [], 180000) of
            {badrpc, _Reason} ->
                300;
            Ret ->
                Ret
        end,
    init:stop(Code).
