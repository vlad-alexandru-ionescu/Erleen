
-module(twt_random_twtr).

-behaviour(een_comp).

-compile(export_all).

-include_lib("erleen.hrl").

-record(state, {started = false,
                user,
                new_user_call,
                tweet_call}).

reinit(_, _, [User]) ->
    {ok,
     #een_interface_spec{ext_in  = [#een_port_spec{name = start,
                                                   msg_type = cast}],
                         ext_out = [#een_port_spec{name = new_user,
                                                   msg_type = call,
                                                   arrity = 1},
                                    #een_port_spec{name = tweet,
                                                   msg_type = call,
                                                   arrity = 2}]},
     #state{user = User}}.

handle_in(start, {}, _From, State = #state{started = false,
                                           user = User}) ->
    {ok, MsgId} = een:out(new_user, {User}),
    {ok, State#state{started = true,
                     new_user_call = MsgId}};
handle_in(start, {}, _From, State = #state{started = true}) ->
    {ok, State}.

handle_reply(MsgId, {reply, ok}, State = #state{new_user_call = MsgId,
                                                user = User}) ->
    NewMsgId = tweet(User),
    {ok, State#state{new_user_call = undefined,
                     tweet_call = NewMsgId}};
handle_reply(MsgId, _, State = #state{tweet_call = MsgId,
                                      user = User}) ->
    NewMsgId = tweet(User),
    {ok, State#state{tweet_call = NewMsgId}}.

tweet(User) ->
    case een:out(tweet, {User, random_tweet()}) of
        {ok, MsgId} -> MsgId;
        _           -> undefined
    end.

random_tweet() ->
    Tweets = ["a", "b", "c", "d"],
    lists:nth(random:uniform(length(Tweets)), Tweets).