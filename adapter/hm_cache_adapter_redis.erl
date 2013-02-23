-module(hm_cache_adapter_redis).
-behaviour(hm_cache_adapter).

-export([init/1, terminate/1]).
-export([get/3, set/4,set/5, delete/3]).

get_adapter_config(Options)->
    AdapterConfig = [
        {host,"127.0.0.1"},
        {port,6379},
        {database,0},
        {password,""},
        {reconnect_sleep,100}],
    proplists:get_value(adapter_config,Options,AdapterConfig).


init(Options) ->
    Config = get_adapter_config(Options), 
    eredis:start_link(Config).

terminate(Conn)->
    eredis:stop(Conn).

get(Conn, Prefix, Key) ->
    CacheKey = term_to_key(Prefix,Key),
    {ok,CacheValue} = eredis:q(Conn,["GET",CacheKey]),
    case CacheValue of
        undefined->
            undefined;
        Bin ->
            erlang:binary_to_term(Bin)
    end.

set(Conn, Prefix, Key, Val, TTL) ->
    CacheKey = term_to_key(Prefix,Key),
    CacheValue = erlang:term_to_binary(Val),
    eredis:q(Conn,["SET",CacheKey,CacheValue]),
    eredis:q(Conn,["EXPIRE",CacheKey,TTL]).

set(Conn, Prefix, Key, Val)->
    CacheKey = term_to_key(Prefix,Key),
    CacheValue = erlang:term_to_binary(Val),
    eredis:q(Conn,["SET",CacheKey,CacheValue]).

delete(Conn, Prefix, Key) ->
    CacheKey = term_to_key(Prefix,Key),
    eredis:q(Conn,["DELETE",CacheKey]).

% internal
term_to_key(Prefix, Term) ->
    MD5KeyBinary = erlang:md5(erlang:term_to_binary(Term)),
    MD5KeyList = hm_misc:to_hex(MD5KeyBinary),
    lists:concat([Prefix, "_", MD5KeyList]).