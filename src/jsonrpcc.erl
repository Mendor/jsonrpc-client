-module (jsonrpcc).
-behaviour (application).

%% Application behaviour exports
-export ([start/2, stop/1]).
%% API functions exports
-export ([start/1, set_url/1, call/2, call/3, call_10/3, call_20/3]).

start(Url) ->
    hackney:start(),
    ok = application:start(jsonrpcc),
    set_url(Url).
    
start(_StartType, _StartArgs) ->
    jsonrpcc_srv:start_link().

stop(_State) ->
    ok.

%% Set JSON-RPC API URL
set_url(Url) ->
    gen_server:call(jsonrpcc_srv, {url, Url}).

%% Just a shortcut
call(Method, Params) ->
    call_20(Method, Params, null).

%% And this too
call(Method, Params, Id) ->
    call_20(Method, Params, Id).

%% Send JSON-RPC 2.0 request
call_20(Method, Params, Id) ->
    gen_server:call(jsonrpcc_srv, {call_20, Method, Params, Id}).

%% Send JSON-RPC 1.0 request
call_10(Method, Params, Id) ->
    gen_server:call(jsonrpcc_srv, {call_10, Method, Params, Id}).
