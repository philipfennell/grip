xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/rdf-interfaces/RDFEnvironment.xqy";

let $rdfEnvironment as element(rdf-environment) := 
<rdf-environment>
	<prefix-map/>
	<term-map/>
</rdf-environment>
return
	rdfenv:create-prefix-map($rdfEnvironment, true()) instance of element(prefix-map)

