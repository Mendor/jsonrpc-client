-module (jsonrpcc_srv).
-behaviour (gen_server).

-export ([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2,
          terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% gen_server functions definitions

init(_Args) ->
    {ok, {url, <<"http://localhost/">>}}.

%% URL setting handler
handle_call({url, Url}, _From, _State) when is_binary(Url) ->
    {reply, ok, {url, Url}};
handle_call({url, Url}, _From, _State) when is_list(Url) ->
    {reply, ok, {url, list_to_binary(Url)}};
%% 2.0 request handler
handle_call({call_20, Method, Params, Id}, _From, {url, Url}) when is_binary(Method) ->
    Reply = call_20(Url, Method, Params, Id),
    {reply, Reply, {url, Url}};
%% 1.0 request handler
handle_call({call_10, Method, Params, Id}, _From, {url, Url}) when is_binary(Method) ->
    Reply = call_10(Url, Method, Params, Id),
    {reply, Reply, {url, Url}};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions definitions

-spec call_20(Url :: binary(), Method :: binary(), Params :: list(), Id :: binary() | number() | null) ->
    any().
call_20(Url, Method, Params, Id) when Id =:= null ->
    call_20(Url, [{jsonrpc, <<"2.0">>}, {method, Method}, {params, Params}]);
call_20(Url, Method, Params, Id) ->
    call_20(Url, [{jsonrpc, <<"2.0">>}, {method, Method}, {params, Params}, {id, Id}]).

-spec call_20(Url :: binary(), RawQuery :: list()) ->
    {result, list(), any(), integer()} | {error, list(), integer()} | {http_error, atom()}.
call_20(Url, RawQuery) ->
    case http(Url, jsonx:encode(RawQuery)) of
        {ok, SCode, Reply} ->
            case proplists:get_value(<<"result">>, Reply) of
                undefined -> {error, proplists:get_value(<<"error">>, Reply), SCode};
                Defined   -> {result, Defined, proplists:get_value(<<"id">>, Reply), SCode}
            end;
        Other -> Other
    end.

-spec call_10(Url :: binary(), Method :: binary(), Params :: list(), Id :: binary() | number() | null) ->
    {result, list(), any(), integer()} | {error, list(), integer()} | {http_error, atom()}.
call_10(Url, Method, Params, Id) ->
    Query = jsonx:encode([{method, Method}, {params, Params}, {id, Id}]),
    case http(Url, Query) of
        {ok, SCode, Reply} ->
            case proplists:get_value(<<"error">>, Reply) of
                null -> {result, proplists:get_value(<<"result">>, Reply), proplists:get_value(<<"id">>, Reply), SCode};
                Else -> {error, proplists:get_value(<<"error">>, Else), SCode}
            end;
        Other -> Other
    end.

-spec http(Url :: binary(), Query :: binary()) -> {ok, integer(), list()} | {http_error, atom()}.
http(Url, Query) ->
    Headers = [{<<"Content-Type">>, <<"application/json">>}],
    Resp = hackney:request(post, Url, Headers, Query, []),
    case Resp of
        {ok, SCode, _RHeaders, Response} ->
            {ok, Body, _R} = hackney:body(Response),
            {ok, SCode, jsonx:decode(Body, [{format, proplist}])};
        {error, Reason} -> {http_error, Reason}
    end.
