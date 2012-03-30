xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/rdf-interfaces/PrefixMap.xqy";

let $prefixMap as element(prefix-map) := 
	<prefix-map>
		<entry xml:id="test">http://www.example.com/test/one#</entry>
	</prefix-map>
let $prefixes as element(prefix-map) := 
	<prefix-map>
		<entry xml:id="test">http://www.example.com/test/two#</entry>
	</prefix-map>
return
	prefixmap:get(prefixmap:add-all($prefixMap, $prefixes, false()), 'test') eq 'http://www.example.com/test/one#'