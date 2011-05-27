
-module(t1_b).

-behaviour(een_comp).

-compile(export_all).

-include_lib("erleen.hrl").

-record(state, {got_ping = false}).

start() ->
    een_comp:start(?MODULE, []).

reinit(_, _, []) ->
    {ok, #een_interface_spec{ext_in  = [#een_port_spec{name = ping_b,
                                                       msg_type = call,
                                                       arrity = 0}],
                             ext_out = [#een_port_spec{name = pong1_b,
                                                       msg_type = cast,
                                                       arrity = 0},
                                        #een_port_spec{name = pong2_b,
                                                       msg_type = cast,
                                                       arrity = 0}]},
     #state{}}.

handle_in(ping_b, {}, _From, State = #state{got_ping = false}) ->
    een:out(pong1_b, {}),
    een:out(pong2_b, {}),
    {reply, pong_reply, State#state{got_ping = true}}.

handle_reply(_, _, State) ->
    {stop, unexpected_reply, State}.

terminate(Reason, #state{got_ping = true}) ->
    Reason;
terminate(Reason, State) ->
    {fail_state, Reason, State}.
