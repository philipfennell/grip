xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/Graph.xqy";


(: The some of the predicates should be a plain literal (but know are so this should fail. :)
declare function local:test($triple as element()?)
		as xs:boolean
{
	$triple/*[2] instance of element(trix:plainLiteral)
};


let $graph as element() := 
<graph xmlns="http://www.w3.org/2004/03/trix/trix-1/" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
	<uri>http://localhost:8005/graphs?default=</uri>
</graph>
return
	graph:some($graph, xdmp:function(xs:QName('local:test')))

