xquery version "1.0-ml" encoding "utf-8";

(:
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:
 : The URL re-writer forwards all requests to the request 'handler'.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace core="http://www.marklogic.com/rig/core" at 
		"/framework/core.xqy";

    if (matches(xdmp:get-request-url(), '^/resources/.*') or 
    		matches(xdmp:get-request-url(), '^/favicon')) then
    	xdmp:get-request-url()
    else
    	(xdmp:log(concat('[XQuery][RIG] Original Request Path: &lt;', 
    			xdmp:get-request-url(), '&gt;'), 'debug'),
    		
    	core:handle-request(xdmp:get-request-protocol(), 
    			xdmp:get-request-header('Host'), 
    					xdmp:get-request-path(),
			    				(for $paramName in xdmp:get-request-field-names()
								return concat($paramName, '=', 
										encode-for-uri(xdmp:get-request-field($paramName)))),
												'/framework/handler.xqy'))
