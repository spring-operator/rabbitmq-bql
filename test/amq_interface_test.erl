%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is the RabbitMQ BQL Module.
%%
%%   The Initial Developers of the Original Code are LShift Ltd.,
%%   Cohesive Financial Technologies LLC., and Rabbit Technologies Ltd.
%%
%%   Portions created by LShift Ltd., Cohesive Financial
%%   Technologies LLC., and Rabbit Technologies Ltd. are Copyright (C)
%%   2009 LShift Ltd., Cohesive Financial Technologies LLC., and Rabbit
%%   Technologies Ltd.;
%%
%%   All Rights Reserved.
%%
%%   Contributor(s): ___________________________
%%
-module(amq_interface_test).

-include("rabbit.hrl").
-include("rabbit_framing.hrl").
-include_lib("eunit/include/eunit.hrl").

submit_create_command_test() ->
    Response = send_request("create exchange myexchange;"),
    ?assertEqual("{\"success\":true,\"messages\":[\"ok\"]}", Response).

submit_query_test() ->
    Response = send_request("select * from vhosts where name='/';"),
    ?assertEqual("{\"success\":true,\"messages\":[[{\"name\":\"/\"}]]}", Response).

submit_badly_formatted_query_test() ->
    Response = send_request("create invalidexchange myexchange;"),
    ?assertEqual("{\"success\":false,\"message\":\"syntax error before: \\\"invalidexchange\\\" on line 1\"}", Response).

submit_query_against_non_existant_object_test() ->
    Response = send_request("select * from something;"),
    ?assertEqual("{\"success\":true,\"messages\":[\"Unknown entity something specified to query\"]}", Response).

send_request(Content) ->
    Connection = Connection = lib_amqp:start_connection(),
    Client = bql_amqp_rpc_client:start(Connection, <<>>),
    Res = bql_amqp_rpc_client:call(Client, <<"bql.query">>, <<"application/json">>,
                                   list_to_binary("{\"query\":\"" ++ Content ++ "\"}"), 500),
    lib_amqp:close_connection(Connection),
    Res.
