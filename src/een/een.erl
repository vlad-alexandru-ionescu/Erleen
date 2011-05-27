
-module(een).

-export([spawn_config/1, out/2, reply/2]).

%% ----------------------------------------------------------------------------
%% Interface
%% ----------------------------------------------------------------------------

spawn_config(Config) ->
    een_config:spawn(Config).

out(PortName, Msg) ->
    een_out:send(PortName, Msg).

reply(From, Msg) ->
    een_comp:reply(From, Msg).