
-module(twt_stats2).

-behaviour(een_comp).

-compile(export_all).

-include_lib("erleen.hrl").

-record(state, {total_tweets = 0,
                user_tweets = orddict:new()}).

reinit(twt_stats, {state, TotalTweets}, []) ->
    {ok,
     #een_interface_spec{ext_in  = [#een_port_spec{name = tweet,
                                                   msg_type = cast,
                                                   arrity = 2}]},
     #state{total_tweets = TotalTweets}}.

handle_in(tweet, {User, _Tweet}, _From,
          State = #state{total_tweets = TotalTweets,
                         user_tweets = UserTweets}) ->
    NewUserTweets = orddict:update_counter(User, 1, UserTweets),
    if
        (TotalTweets + 1) rem 1000 =:= 0 ->
            io:format("~nTotal tweets: ~p~nUser tweets: ~p~n~n",
                      [TotalTweets + 1, NewUserTweets]);
        true ->
            ok
    end,
    {ok, State#state{total_tweets = TotalTweets + 1,
                     user_tweets = NewUserTweets}}.

handle_reply(_, _, _) ->
    unexpected.

terminate(Reason, _State) ->
    Reason.
