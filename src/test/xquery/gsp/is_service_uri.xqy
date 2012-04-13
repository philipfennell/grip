xquery version "1.0-ml";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";


gsp:select-graph-uri('http://localhost:8005/graphs', false(), '') instance of empty-sequence()

