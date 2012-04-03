xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";


let $prefixMap as element(prefix-map) := doc('http://localhost:8005/prefixes')/*
let $prefixes as element(prefix-map) := 
	<prefix-map>
		<entry xml:id="dc">http://purl.org/dc/elements/1.1/</entry>
		<entry xml:id="rdfi">http://www.example.com/test#</entry>
	</prefix-map>
return
	impl:map-add($prefixMap, $prefixes/entry, false());
	



xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/Common.xqy";


let $prefixMap as element(prefix-map) := doc('http://localhost:8005/prefixes')/*
return
	common:map-get($prefixMap, 'rdfi') eq 'http://www.w3.org/TR/rdf-interfaces'