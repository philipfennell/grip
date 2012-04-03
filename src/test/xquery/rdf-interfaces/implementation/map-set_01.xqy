xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";


let $prefixMap as element(prefix-map) := doc('http://localhost:8005/prefixes')/*
return
	impl:map-set($prefixMap, 'rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
