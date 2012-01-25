xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";

(: Tests the retrieval of a named graph. :)

gsp:get-graph('http://www.books.com/harry_potter')