xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/lib-graph.xqy";


let $graph as element() := 
<graph xmlns="http://www.w3.org/2004/03/trix/trix-1/" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
	<uri>http://localhost:8005/graphs?default=</uri>
</graph>
let $triple as element() := 
<triple>
	<uri>http://example.org/book/book8</uri>
	<uri>http://purl.org/dc/elements/1.1/date</uri>
	<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2012-03-26</typedLiteral>
</triple>
return
	graph:add($graph, $triple)

