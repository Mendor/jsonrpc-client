jsonrpc-client
==============

Erlang JSON-RPC HTTP client application. Supports both 1.0 and 2.0 API implementations.

Usage
-----

1. Start application with mentioning API URL as the parameter (string or binary):

```erlang
1> jsonrpcc:start("http://your-awesome-api.com/jsonrpc/").
ok
```

2. Send requests to the API using ``call/2``, ``call_10/3`` or ``call_20/3`` functions:

```erlang
2> jsonrpcc:call(<<"createUser">>, [{<<"name">>, <<"John Doe">>}, {<<"registered">>, 1378567275}]).
{result,[{<<"state">>,<<"ok">>}],0,200}.
```

or, e.g.:

```erlang
{error, [{<<"message">>,<<"Method not allowed">>}],405}.
```

``call_10`` and ``call_20`` functions' parameters are: RPC method (binary string), method parameters (list of any structures) and request ID (number typically, may be ``null``). ``call`` is just a short-cut to ``call_20`` function with null ID.

License
-------
[WTFPL](http://www.wtfpl.net/)
