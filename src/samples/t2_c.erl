
-module(t2_c).

-behaviour(een_comp).

-include_lib("erleen.hrl").

-export([reinit/3, handle_in/4, handle_reply/3, terminate/2]).

-record(state, {sent_pong = false,
                n}).

reinit(_, _, [N]) ->
    {ok,
     #een_interface_spec{ext_in = [#een_port_spec{name = ping_c,
                                                  type = multi,
                                                  msg_type = cast,
                                                  arrity = 0}],
                         ext_out = [#een_port_spec{name = pong_c,
                                                   type = multi,
                                                   msg_type = cast,
                                                   arrity = 0}]},
     #state{n = N}}.

handle_in(ping_c, Params, _From, State = #state{sent_pong = false,
                                                n = N}) ->
    N = length(Params), %% assertion
    een:out(pong_c, {}),
    {ok, State#state{sent_pong = true}}.

handle_reply(_, _, _) ->
    unexpected.

terminate(Reason, #state{sent_pong = true}) ->
    Reason;
terminate(_, State) ->
    {failed_state, State}.
