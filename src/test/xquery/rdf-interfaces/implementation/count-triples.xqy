xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";

let $graph as element() := doc('http://localhost:8005/graphs?default=')/*
return
	impl:count-triples($graph) eq 30