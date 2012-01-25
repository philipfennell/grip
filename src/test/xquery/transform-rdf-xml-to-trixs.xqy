xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";

(: Tests transforming RDF/XML in ML Tuples. :)

gsp:rdf-xml-to-trix(
	<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
		<rdf:Description rdf:about="http://example.org/book/book3">
			<dc:title xml:lang="en-GB">Harry Potter and the Prisoner Of Azkaban</dc:title>
			<dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">2012-01-20</dc:date>
		</rdf:Description>
	</rdf:RDF>,
	'http://www.books.com/harry_potter')