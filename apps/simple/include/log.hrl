%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 1月 2024 15:24
%%%-------------------------------------------------------------------
-author("Administrator").

-ifndef(LOG_HRL).
-define(LOG_HRL, true).

-define(WARN(Msg), lager:warning(Msg, [])).
-define(WARN(Msg, Args), lager:warning(Msg, Args)).

-define(INFO(Msg), lager:info(Msg, [])).
-define(INFO(Msg, Args), lager:info(Msg, Args)).

-define(ERROR(Msg), lager:error(Msg, [])).
-define(ERROR(Msg, Args), lager:error(Msg, Args)).

-endif.