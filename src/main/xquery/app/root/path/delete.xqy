xquery version "1.0-ml" encoding "utf-8";

(:~
 : Implements the 'delete' action for the identified resource.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace core = "http://www.marklogic.com/rig/core" 
		at "/framework/core.xqy";
import module namespace service = "http://www.marklogic.com/rig/service" 
		at "/framework/service.xqy";
      
import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";
import module namespace resource = "http://www.grip.com/path" 
		at "/root/path/resource.xqy"; 


document {gsp:delete-graph(
		gsp:select-graph-uri($resource:default, $resource:graph, $resource:REQUEST_URI))}
