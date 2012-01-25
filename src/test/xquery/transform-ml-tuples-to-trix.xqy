xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";

(: Tests transforming ML Tuples into RDF/XML. :)

gsp:tuples-to-trix(
	<graph uri="http://www.books.com/harry_potter">
		<t>
			<s>http://example.org/book/book3</s>
			<p>http://purl.org/dc/elements/1.1/title</p>
			<o>Harry Potter and the Prisoner Of Azkaban</o>
		</t>
	</graph>)