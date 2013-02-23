-module(hm_cache_controller).

-behaviour(gen_server).
-behaviour(poolboy_worker).
-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
        adapter,
        connection
    }).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Config) ->
    AdapterName = proplists:get_value(adapter_name, redis),
    AdapterConfig = proplists:get_value(adapter_config,[]),
    Adapter = list_to_atom(lists:concat(["hm_cache_adapter_", AdapterName])),
    {ok, Conn} = Adapter:init(AdapterConfig),
    {ok, #state{ adapter = Adapter, connection = Conn}}.

handle_call({get, Prefix, Key}, _From, State) ->
    Adapter = State#state.adapter,
    Conn = State#state.connection,
    {reply, Adapter:get(Conn, Prefix, Key), State};

handle_call({set, Prefix, Key, Value}, _From, State) ->
    Adapter = State#state.adapter,
    Conn = State#state.connection,
    {reply, Adapter:set(Conn, Prefix, Key, Value), State};

handle_call({set, Prefix, Key, Value, TTL}, _From, State) ->
    Adapter = State#state.adapter,
    Conn = State#state.connection,
    {reply, Adapter:set(Conn, Prefix, Key, Value, TTL), State};

handle_call({delete, Prefix, Key}, _From, State) ->
    Adapter = State#state.adapter,
    Conn = State#state.connection,
    {reply, Adapter:delete(Conn, Prefix, Key), State}.

handle_cast(_Request, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    Adapter = State#state.adapter,
    Conn = State#state.connection,
    Adapter:terminate(Conn).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_info(_Info, State) ->
    {noreply, State}.