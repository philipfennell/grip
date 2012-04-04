xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/rdf-interfaces/RDFEnvironment.xqy";


let $graph as element() := 
<graph>
	<uri>#default</uri>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral xml:lang="en-GB">Harry Potter and the Philosopher's Stone</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>
	</triple>
</graph>

return
	rdfenv:create-graph($rdfenv:DEFAULT_ENVIRONMENT, $graph/rdfi:triple) instance of element(graph)

