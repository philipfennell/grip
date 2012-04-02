xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/Common.xqy";

let $map as element() := <map/>
let $test := common:map-set($map, 'rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
return
	common:map-get($test, 'rdf') eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
