xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/rdf-interfaces/TermMap.xqy";

let $termMap as element(term-map) := 
	<term-map>
		<entry xml:id="string">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="boolean">http://www.w3.org/2001/XMLSchema#</entry>
	</term-map>
let $test := termmap:remove($termMap, 'string')
return
	termmap:get($test, 'string') instance of empty-sequence()
