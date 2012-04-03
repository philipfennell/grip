xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";


let $graph as element() := 
<graph>
	<uri>http://localhost:8005/test?default=</uri>
</graph>
let $triple as element() := 
<triple>
	<uri>http://example.org/book/book8</uri>
	<uri>http://purl.org/dc/elements/1.1/title</uri>
	<plainLiteral>Harry Potter and the ha'penny chews</plainLiteral>
</triple>
let $add := impl:add-triple($graph, $triple)
return
	();

xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";


let $graph as element() := 
<graph>
	<uri>http://localhost:8005/test?default=</uri>
</graph>
return
	impl:get-triples($graph)/*[3]/text() eq 'Harry Potter and the ha''penny chews'

