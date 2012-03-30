xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/rdf-interfaces/Profile.xqy";


let $prefixMap as item() := profile:get-prefixes(map:map())
let $test := profile:set-default-prefix(map:map(), 'http://www.example.com/default/namespace#')
return
	map:get($prefixMap, '') eq 'http://www.example.com/default/namespace#'