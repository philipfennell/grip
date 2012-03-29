xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/TermMap.xqy";

let $termMap as item() := map:map()
let $_put := map:put($termMap, 'integer', 'http://www.w3.org/2001/XMLSchema#')
let $terms as item() := map:map()
let $_put := map:put($terms, 'integer', 'http://www.w3.org/2012/XMLSchema#')
return
	map:get(prefixmap:add-all($termMap, $terms, false()), 'integer') eq 'http://www.w3.org/2001/XMLSchema#'
