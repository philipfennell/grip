xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/rdf-interfaces/PrefixMap.xqy";

let $prefixMap as element(prefix-map) := 
	<prefix-map>
		<entry xml:id="first">http://www.example.com/test/one#</entry>
		<entry xml:id="last">http://www.example.com/test/three#</entry>
	</prefix-map>
let $prefixes as element(prefix-map) := 
	<prefix-map>
		<entry xml:id="first">http://www.example.com/test/two#</entry>
		<entry xml:id="middle">http://www.example.com/test/four#</entry>
	</prefix-map>
return
	prefixmap:get(prefixmap:add-all($prefixMap, $prefixes, true()), 'first') eq 'http://www.example.com/test/two#'