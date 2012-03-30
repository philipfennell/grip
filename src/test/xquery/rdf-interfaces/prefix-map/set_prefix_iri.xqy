xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/rdf-interfaces/PrefixMap.xqy";

let $prefixMap as element(prefix-map) := <prefix-map/>
let $test := prefixmap:set($prefixMap, 'rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
return
	prefixmap:get($test, 'rdf') eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
