xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";

let $triple as element() := 
<triple>
	<uri>http://example.org/book/book1</uri>
	<uri>http://purl.org/dc/elements/1.1/date</uri>
	<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>
</triple>
let $expectedResult as xs:string := 'Literal'

return
	rdfnode:get-interface-name(<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>) eq $expectedResult