xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";

(: Tests the adding of the default graph. :)

let $graph as element(graph) := 
<graph>
	<uri>/test?default</uri>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Prisoner Of Azkaban</plainLiteral>
	</triple>
</graph>
return
	gsp:update-graph($graph)
