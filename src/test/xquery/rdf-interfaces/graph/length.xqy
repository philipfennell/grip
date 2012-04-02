xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/rdf-interfaces/Graph.xqy";

let $graph as element() := 
	<graph>
		<uri>http://localhost:8005/graphs?default=</uri>
		<triple>
			<uri>http://example.org/book/book3</uri>
			<uri>http://purl.org/dc/elements/1.1/title</uri>
			<plainLiteral>Harry Potter and the Prisoner Of Azkaban</plainLiteral>
		</triple>
		<triple>
			<uri>http://example.org/book/book3</uri>
			<uri>http://purl.org/dc/elements/1.1/creator</uri>
			<id>A0</id>
		</triple>
		<triple>
			<uri>http://example.org/book/book3</uri>
			<uri>http://purl.org/dc/elements/1.1/publisher</uri>
			<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
		</triple>
	</graph>

return
	graph:get-length($graph) eq 3