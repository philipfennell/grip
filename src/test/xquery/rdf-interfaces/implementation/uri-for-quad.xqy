xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";

let $graph as element() := doc('http://localhost:8005/graphs?default=')/*
return
	impl:uri-for-quad('http://example.org/book/book3', 
			'http://purl.org/dc/elements/1.1/title',
					'Harry Potter and the Prisoner Of Azkaban',
							'http://localhost:8005/graphs?default=') eq 
									'67597bb906a8db45'