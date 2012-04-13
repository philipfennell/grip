xquery version "1.0-ml";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" at 
		"/lib/lib-gsp.xqy";

gsp:select-graph-uri('http://localhost:8005/graphs?graph=http%3A//www.example.com/other/graph', 
		false(), 'http://www.example.com/other/graph') eq 'http://www.example.com/other/graph'

