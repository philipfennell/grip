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


let $graphURI := gsp:select-graph-uri($resource:REQUEST_PATH, $resource:default, 
		$resource:graph)
return
	(: Merge the graph data. :)
	if (exists($graphURI)) then 
		gsp:merge-graph(
			gsp:parse-graph($graphURI, $resource:CONTENT, $resource:MEDIA_TYPE)
		)
	(: Otherwise create a new graph. :)
	else
		gsp:create-graph(
			gsp:parse-graph(
				gsp:create-new-uri($resource:REQUEST_PATH, $resource:SLUG), 
						$resource:CONTENT, $resource:MEDIA_TYPE
			)
		)
