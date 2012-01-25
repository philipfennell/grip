xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";

(: Tests the parsing of well-formed and valid RDF/XML. :)

gsp:parse-graph(
	'&lt;rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"&gt;
		&lt;rdf:Description rdf:about="http://example.org/book/book3"&gt;
			&lt;dc:title&gt;Harry Potter and the Prisoner Of Azkaban&lt;/dc:title&gt;
		&lt;/rdf:Description&gt;
	&lt;/rdf:RDF&gt;', '/foo')