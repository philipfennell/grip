xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/rdf-interfaces/PrefixMap.xqy";

let $prefixMap as element(prefix-map) := 
	<prefix-map>
		<entry xml:id="xs">http://www.w3.org/2001/XMLSchema#</entry>
	</prefix-map>
return
	prefixmap:shrink($prefixMap, 'http://purl.org/dc/elements/1.1/title') eq 'http://purl.org/dc/elements/1.1/title'

