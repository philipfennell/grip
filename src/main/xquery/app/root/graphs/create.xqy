xquery version "1.0-ml" encoding "utf-8";

(:~
 : Implements the 'post' action for the identified resource.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace service = "http://www.marklogic.com/rig/service" 
		at "/framework/service.xqy";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";
		
import module namespace resource = "http://www.marklogic.com/grip/graphs" 
		at "/root/graphs/resource.xqy";


let $newGraphURI as xs:string := gsp:create-new-uri($resource:REQUEST_URI, $resource:SLUG)
return
	(: Cannot create to an existing graph at the collection level. :)
	if (gsp:graph-exists($newGraphURI)) then 
		error(xs:QName('err:REQ004'), 'Graph already exists.', $newGraphURI)
	(: If the default graph is identified, create that. :)
	else if ($resource:default) then
		gsp:merge-graph(gsp:parse-graph($resource:REQUEST_URI, $resource:CONTENT, $resource:MEDIA_TYPE))
	(: If a named graph is identified, create that. :)
	else if (string-length($resource:graph) gt 0) then 
		gsp:merge-graph(gsp:parse-graph($resource:graph, $resource:CONTENT, $resource:MEDIA_TYPE))
	(: Otherwise create a new graph. :)
	else
		gsp:create-graph(gsp:parse-graph($newGraphURI, $resource:CONTENT, $resource:MEDIA_TYPE))
