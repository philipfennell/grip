xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/Profile.xqy";


let $prefixMap as item() := profile:get-prefixes()
let $test := profile:set-default-prefix(map:map(), 'http://www.example.com/default/namespace#')
return
	map:get($prefixMap, '') eq 'http://www.example.com/default/namespace#'