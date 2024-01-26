%%%-------------------------------------------------------------------
%% @doc simple public API
%% @end
%%%-------------------------------------------------------------------

-module(simple_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    simple_sup:start_link(),
    application:start(large).

stop(_State) ->
    ok.

%% internal functions
