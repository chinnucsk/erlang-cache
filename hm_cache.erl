-module(hm_cache).
-export([start/1]).
-export([stop/0]).
-export([get/3, set/4,set/5, delete/3]).

start() ->
    hm_cache_sup:start_link([]).

start(Options) ->
    hm_cache_sup:start_link(Options).

stop()->
    ok.

set(PoolName,Prefix,Key,Val)->
    hm_cache_pool:call(PoolName, {set, Prefix, Key, Val}).

set(PoolName,Prefix, Key, Val, TTL) ->
    hm_cache_pool:call(PoolName, {set, Prefix, Key, Val, TTL}).

get(PoolName,Prefix, Key) ->
    hm_cache_pool:call(PoolName, {get, Prefix, Key}).

delete(PoolName,Prefix, Key) ->
    hm_cache_pool:call(PoolName, {delete, Prefix, Key}).