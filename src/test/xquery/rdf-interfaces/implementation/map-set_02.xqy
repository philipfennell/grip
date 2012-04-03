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
	impl:map-set($prefixMap, 'xs', 'http://www.w3.org/2001/XMLSchema#');
	

xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";


let $prefixMap as element(prefix-map) := doc('http://localhost:8005/prefixes')/*
return
	impl:map-set($prefixMap, 'xs', 'http://www.w3.org/2012/XMLSchema#');
	

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
	common:map-get($prefixMap, 'xs') eq 'http://www.w3.org/2012/XMLSchema#'

