xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/"
	at "/lib/lib-trix.xqy";

let $graphURI as xs:string := 'http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test002.rdf'
return
	gsp:tuples-for-context($graphURI)