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
    CacheKey = get_cache_key(Prefix,Key),
    {ok,CacheValue} = eredis:q(Conn,["GET",CacheKey]),
    case CacheValue of
        undefined->
            {ok,undefined};
        Bin ->
            {ok,Bin}
    end.

set(Conn, Prefix, Key, Val, TTL) ->
    CacheKey = get_cache_key(Prefix,Key),
    eredis:q(Conn,["SET",CacheKey,Val]),
    eredis:q(Conn,["EXPIRE",CacheKey,TTL]).

set(Conn, Prefix, Key, Val)->
    CacheKey = get_cache_key(Prefix,Key),
    eredis:q(Conn,["SET",CacheKey,Val]).

delete(Conn, Prefix, Key) ->
    CacheKey = get_cache_key(Prefix,Key),
    eredis:q(Conn,["DEL",CacheKey]).

% internal
get_cache_key(Prefix, Key) ->
    MD5KeyBinary = erlang:md5(Key),
    MD5KeyList = hm_string:to_hex(MD5KeyBinary),
    lists:concat([Prefix, ":", MD5KeyList]).
