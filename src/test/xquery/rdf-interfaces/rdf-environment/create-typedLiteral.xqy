xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/RDFEnvironment.xqy";

let $graph as element() := 
<graph xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:xs="http://www.w3.org/2001/XMLSchema#">
	<uri>#default</uri>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>
	</triple>
</graph>

return
	deep-equal(rdfenv:create-literal('2001-11-04', <uri>http://www.w3.org/2001/XMLSchema#date</uri>), <typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>)

