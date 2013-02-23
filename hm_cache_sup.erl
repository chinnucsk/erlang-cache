-module(hm_cache_sup).

-behaviour(supervisor).

-export([start_link/0, start_link/1]).

-export([init/1]).

start_link() ->
    start_link([]).

start_link(StartArgs) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, StartArgs).

init(StartArgs) ->
	RestartStrategy = {one_for_one, 10, 10},
	DefaultPoolArgs = [
		{worker_module, hm_cache_controller},
		{size, 20},
		{max_overflow, 40}
		],
	DefaultPool = {default_cache,DefaultPoolArgs,[]},
	Pools = [DefaultPool|StartArgs],
	PoolsSpecs = lists:map(fun({Name,OtherArgs,WorkerArgs})->
								PoolArgs = [{name,{local,Name}}] ++ OtherArgs,
                                poolboy:child_spec(Name,PoolArgs,WorkerArgs)
                            end,Pools),
    {ok, {RestartStrategy, PoolsSpecs}}.