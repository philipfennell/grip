xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/rdf-interfaces/Graph.xqy";

let $graph as element() := 
	<graph>
		<uri>http://localhost:8005/graphs?default=</uri>
	</graph>

return
	graph:get-length($graph)