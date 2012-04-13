xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/rdf-interfaces/Graph.xqy";


let $graph as element(graph) := 
<graph>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Prisoner Of Azkaban</plainLiteral>
	</triple>
</graph>
let $action as element(action) := 
<action>
	<filter>
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
declare variable $rdfi:triple as element() external;

true()
	</filter>
	<callback><![CDATA[
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare variable $rdfi:triple as element() external;
declare variable $rdfi:graph as element() external;

element {xs:QName(name($rdfi:triple))} {
	subsequence($rdfi:triple/*, 1, 2),
	element {xs:QName(name($rdfi:triple/*[3]))} {
		attribute xml:lang {'en-gb'},
		string($rdfi:triple/*[3])
	}
}
	]]></callback>
</action>
return
	graph:add-action($graph, $action, true())

