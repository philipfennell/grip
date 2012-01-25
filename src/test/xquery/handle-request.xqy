xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace core = "http://www.marklogic.com/rig/core" 
		at "/framework/core.xqy";
import module namespace service = "http://www.marklogic.com/rig/service" 
		at "/framework/service.xqy";


core:handle-request('http', 'localhost:8005', '/test/data.rdf', 
			('graph=http%3A%2F%2Fexample.com%2Frdf-graphs%2Femployees'),
							'/framework/handler.xqy')
