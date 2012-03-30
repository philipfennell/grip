xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/rdf-interfaces/RDFEnvironment.xqy";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/rdf-interfaces/Profile.xqy";

let $profile as element(profile) := 
<profile>
	<prefix-map>
		<entry xml:id="owl">http://www.w3.org/2002/07/owl#</entry>
		<entry xml:id="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</entry>
		<entry xml:id="rdfs">http://www.w3.org/2000/01/rdf-schema#</entry>
		<entry xml:id="rdfa">http://www.w3.org/ns/rdfa#</entry>
		<entry xml:id="xhv">http://www.w3.org/1999/xhtml/vocab#</entry>
		<entry xml:id="xml">http://www.w3.org/XML/1998/namespace</entry>
		<entry xml:id="xsd">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="xs">http://www.w3.org/2001/XMLSchema#</entry>
	</prefix-map>
	<term-map/>
</profile>
return
	profile:get-terms($profile) instance of element(term-map)