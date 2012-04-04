xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace ntriples = "http://www.w3.org/TR/rdf-interfaces/NTriplesDataSerializer"
	at "/lib/rdf-interfaces/NTriplesDataSerializer.xqy";

let $graph as element(graph) := 
<graph xmlns="http://www.w3.org/TR/rdf-interfaces"
		xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#" 
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema#">
	<uri>#default</uri>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral xml:lang="en-gb">Harry Potter and the Prisoner Of Azkaban</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<id>A0</id>
	</triple>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">1999-07-08</typedLiteral>
	</triple>
	<triple>
		<id>A0</id>
		<uri>http://www.w3.org/2001/vcard-rdf/3.0#FN</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
</graph>
return
	ntriples:serialize($graph)