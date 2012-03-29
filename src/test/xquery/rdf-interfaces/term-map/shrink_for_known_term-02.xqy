xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/TermMap.xqy";

let $termMap as item() := map:map()
let $_put := map:put($termMap, 'title', 'http://purl.org/dc/elements/1.1/')
return
	termmap:shrink($termMap, 'http://purl.org/dc/elements/1.1/title') eq 'title'

