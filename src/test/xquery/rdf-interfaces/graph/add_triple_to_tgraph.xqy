xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/rdf-interfaces/Graph.xqy";


let $graph as element() := 
	<graph xmlns="http://www.w3.org/TR/rdf-interfaces" 
			xmlns:dc="http://purl.org/dc/elements/1.1/" 
			xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
		<rdfi:actions xmlns:rdfi="http://www.w3.org/TR/rdf-interfaces">
			<rdfi:action>
				<rdfi:test></rdfi:test>
				<rdfi:call-back></rdfi:call-back>
			</rdfi:action>
		</rdfi:actions>
		<uri>http://localhost:8005/graphs?default=</uri>
	</graph>
let $triple as element() := 
	<triple>
		<uri>http://example.org/book/book8</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the ha'penny chews</plainLiteral>
	</triple>
return
	graph:add($graph, $triple)
