xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/lib-graph.xqy";


(: The some of the objects should be a URI, and they are so this should pass. :)
declare function local:filter($triple as element()?)
		as xs:boolean
{
	deep-equal($triple/*[2], <uri>http://purl.org/dc/elements/1.1/title</uri>)
};


let $graph as element() := 
<graph xmlns="http://www.w3.org/2004/03/trix/trix-1/" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
	<uri>http://localhost:8005/graphs?default=</uri>
</graph>
return
	graph:filter($graph, xdmp:function(xs:QName('local:filter')))

