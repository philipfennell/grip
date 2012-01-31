xquery version "1.0-ml" encoding "utf-8";

(:
 : Implements the 'get' action for the identified resource.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";
      
import module namespace resource = "http://www.marklogic.com/grip/graphs" at 
		"/root/graphs/resource.xqy";


if ($resource:default) then 
	gsp:get-graph($resource:REQUEST_URI)
else if (string-length($resource:graph) gt 0) then 
	gsp:get-graph($resource:graph)
else 
	gsp:get-service-description($resource:REQUEST_URI)
	

