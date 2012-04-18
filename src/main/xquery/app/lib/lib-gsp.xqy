xquery version "1.0-ml" encoding "utf-8";

(:
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:~
 : Function library for implementing the W3C's Graph Store Protocol.
 : @see http://www.w3.org/TR/sparql11-http-rdf-update/
 : @author	Philip A. R. Fennell
 : @version 0.2
 :)

module namespace gsp = "http://www.w3.org/TR/sparql11-http-rdf-update/"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/rdf-interfaces/RDFEnvironment.xqy";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/rdf-interfaces/Graph.xqy";

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/rdf-interfaces/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";
	
import module namespace ntdp = "http://www.w3.org/TR/rdf-interfaces/NTriplesDataParser"
	at "/lib/rdf-interfaces/NTriplesDataParser.xqy";

import module namespace txds = "http://www.w3.org/TR/rdf-interfaces/TriXDataSerializer"
	at "/lib/rdf-interfaces/TriXDataSerializer.xqy";

import module namespace sem = "http://marklogic.com/semantic"
	at "/lib/semantic.xqy";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/"
	at "/lib/lib-trix.xqy";

declare namespace nt 	= "http://www.w3.org/ns/formats/N-Triples";
declare namespace rdf 	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace ttl 	= "http://www.w3.org/ns/formats/Turtle";

declare variable $DEFAULT_PERMISSIONS as xs:string* := ();
declare variable $DEFAULT_GRAPH_COLLECTION as xs:string := 
		"http://www.w3.org/TR/rdf-interfaces/Graph";



(:~
 : From the passed arguments, decide if the default graph was requested, if not 
 : use the passed graph URI, if neither of them then use the request URI.
 : If both default and graphURI are passed then throw an exception because you 
 : can't use both together. 
 : @param $requestURI the original request URI.
 : @param $default requested the default graph.
 : @param $graphURI the named graph.
 : @return the requested graph URI.
 : @throws err:GSP001 The default and graph parameters cannot be used together.
 :)
declare function gsp:select-graph-uri($requestURI as xs:string, 
		$default as xs:boolean, $graphURI as xs:string) 
	as xs:string? 
{
	if ($default and string-length($graphURI) gt 0) then
		error(
			xs:QName('err:GSP001'), 
			'The default and graph parameters cannot be used together.'
		)
	else if (xs:boolean($default)) then 
		concat($requestURI, '?default')
	else if (not($default) and string-length($graphURI) gt 0) then 
			$graphURI
	else
		()
}; 


(:~
 : Returns the context Graph's URI.
 : @param $graph the context Graph.
 : @return xs:anyURI
 :)
declare function gsp:get-graph-uri($graph as element(graph)) 
	as xs:anyURI
{
	xs:anyURI(string($graph/uri))
};


(:~
 : Calls the RDF Interfces parser appropriate for the content type.
 : @param $graphURI the Graph's URI.
 : @param $graphContent the graph to be inserted.
 : @param $mediaType graph serialisation media-type.
 : @return element(graph)
 : @throws err:REQ005 - Unsupported Media Type.
 :)
declare function gsp:parse-graph($graphURI as xs:string, $graphContent as item()?, 
		$mediaType as xs:string)
	as element(graph)
{
	let $addGraphURI as element(callback) := 
		<callback>
			import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
				at "/lib/rdf-interfaces/Implementation.xqy";	
			declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
			declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
			declare variable $rdfi:graph as element() external;
			
			impl:graph-add-uri($rdfi:graph, '{$graphURI}')
		</callback>
	return
		if ($mediaType eq $ntdp:MIME_TYPE) then 
			ntdp:parse($graphContent, $addGraphURI, (), (), ())
		else
			error(xs:QName('err:REQ005'), concat('Unsupported Media Type: ', $mediaType))
};


(:~
 : Attempt to create a new graph.
 : @param $graph the Graph to be inserted.
 : @return The new Graph's URI.
 :)
declare function gsp:create-graph($graph as element(graph))
	as xs:anyURI
{
	gsp:add-graph($graph, false())
};


(:~
 : Replace an existing graph.
 : @param $graph the Graph to be inserted.
 : @return an empty sequence.
 :)
declare function gsp:replace-graph($graph as element(graph))
	as empty-sequence()
{
	gsp:add-graph($graph, true())
};


(:~
 : Attempt to create a new graph, if the graph
 : URI already exists then this is an error.
 : @param $graph the Graph to be inserted.
 : @return The new graph's URI
 :)
declare private function gsp:add-graph($graph as element(graph), $replace as xs:boolean)
	as xs:anyURI?
{
	let $graphURI as xs:string := string(gsp:get-graph-uri($graph))
	let $info := xdmp:log(concat('[XQuery][GRIP] ', 
			(if ($replace) then 'Replacing' else 'Creating'), ' New Graph: ', 
					$graphURI), 'info')
	return
		if (doc-available($graphURI) and not($replace)) then 
			gsp:graph-already-exists($graphURI)
		else
			let $defaultAction as element(action) := 
				rdfenv:create-action($rdfenv:DEFAULT_ENVIRONMENT,
					<filter>
						declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
						declare variable $rdfi:triple as element() external;
						
						true()
					</filter>,
					<callback>
						import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
							at "/lib/rdf-interfaces/Implementation.xqy";	
						declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
						declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
						declare variable $rdfi:triple as element() external;
						declare variable $rdfi:graph as element() external;
						
						impl:add-triple('{$graphURI}', $rdfi:triple)
					</callback>
				)
			let $actionedGraph as element(graph) := 
				graph:add-action($graph, $defaultAction, true())
			let $create := xdmp:document-insert($graphURI, $actionedGraph, 
					($DEFAULT_PERMISSIONS),	($DEFAULT_GRAPH_COLLECTION)
			)
			return
				if ($replace) then 
					()
				else
					xs:anyURI($graphURI)
};


(:~
 : Retrieves a graph from the database.
 : @param $graphURI the context graph URI.
 : @return a TriX graph is any triples are found.
 : @throws err:RES001 Graph Not Found.
 :)
declare function gsp:retrieve-graph($graphURI as xs:string) 
	as element(graph)
{
	let $info := xdmp:log(concat('[XQuery][GRIP] Retrieving Graph: ', $graphURI), 'info')
	let $graph as element(graph)? := doc($graphURI)/graph
	return
		if (exists($graph)) then 
			rdfenv:create-graph($rdfenv:DEFAULT_ENVIRONMENT,
				graph:to-array($graph))
		else
			gsp:graph-not-found($graphURI)
};


(:~
 : Create new or replace an existing Graph with the passed graph.
 : @param $graph
 : @return 
 :)
declare function gsp:update-graph($graph as element(graph)) 
	as xs:anyURI?
{
	let $graphURI as xs:string := string(gsp:get-graph-uri($graph))
	let $info := xdmp:log(concat('[XQuery][GRIP] Updating Graph: ', $graphURI), 'info')
	let $existingGraph as element(graph)? := doc($graphURI)/graph
	return
		if (exists($existingGraph)) then 
			( ( for $triple in graph:to-array($existingGraph)
			let $remove := graph:remove($existingGraph, $triple)
			return
				() ),
			gsp:replace-graph($graph) )
		else
			gsp:create-graph($graph)
};


(:~
 : Delete the graph from the database - both the triples and the graph document.
 : @param $graphURI the context graph URI.
 : @return empty-sequence()
 :)
declare function gsp:delete-graph($graphURI as xs:string) 
	as empty-sequence()
{
	let $info := xdmp:log(concat('[XQuery][GRIP] Deleting Graph: ', $graphURI), 'info')
	let $existingGraph as element(graph)? := doc($graphURI)/graph
	let $delete := 
		if (exists($existingGraph)) then 
			( xdmp:document-delete($graphURI),
			for $triple in graph:to-array($existingGraph)
			return
				graph:remove($existingGraph, $triple) )
		else
			gsp:graph-not-found($graphURI)
	return
		()
};














(:~
 : Merge the passed graph into an existing graph in the database.
 : @param $graph the graph to be merged.
 : @return empty-sequence()
 :)
declare function gsp:merge-graph($graph as element(graph))
	as xs:anyURI?
{
	let $graphURI as xs:string := string($graph/uri)
	let $info := xdmp:log(concat('[XQuery][GRIP] Merging Graph: ', $graphURI), 'info')
	let $debug := xdmp:log('[XQuery][GRIP] Graph Content: ', 'fine')
	let $debug := xdmp:log($graph, 'fine')
	return
		(: 
		 : If the incoming graph already exists, add the triples and return
		 : nothing. Otherwise, add the new graph and return its new graph URI. 
		 :)
		(:( gsp:insert-graph($graph), 
		gsp:merge-graph-docs($graph),:)
		if (doc-available($graphURI)) then () else xs:anyURI($graphURI) (: ) :)
};


(:~
 : Returns the graph store's Service Decription according to the SPARQL 1.1 
 : Service Description.
 : @see http://www.w3.org/TR/sparql11-service-description/
 : @param $requestURI the URI of the original request to the service.
 : @return element(trix:trix)
 :)
declare function gsp:retrieve-service-description($requestURI as xs:string) 
	as element(trix:trix)
{
let $serviceURI as xs:string := $requestURI
let $defaultGraphURI as xs:string := concat($serviceURI, '?default=')
let $serviceDescription as element(rdf:RDF) := 
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:sd="http://www.w3.org/ns/sparql-service-description#"
			xmlns:void="http://rdfs.org/ns/void#">{
		
		(: Basic service details. :)
		<rdf:Description rdf:nodeID="SD1">
			<rdf:type rdf:resource="http://www.w3.org/ns/sparql-service-description#Service"/>
			<sd:inputFormat rdf:resource="http://www.w3.org/ns/formats/N-Triples"/>
			<sd:inputFormat rdf:resource="http://www.w3.org/ns/formats/RDF_XML"/>
			<sd:inputFormat rdf:resource="http://www.w3.org/ns/formats/Turtle"/>
			<sd:endpoint rdf:resource="{$serviceURI}"/>
			<sd:availableGraphs rdf:nodeID="AG1"/>
		</rdf:Description>,
		
		(: Available Graphs. :)
		<rdf:Description rdf:nodeID="AG1">{
			( <rdf:type rdf:resource="http://www.w3.org/ns/sparql-service-description#Dataset"/>,
				
				(: Default Graph - if present. :)
				( if (doc-available($defaultGraphURI)) then 
					<sd:defaultGraph rdf:nodeID="DG1"/>
				else 
					() ),
				
				(: Named Graphs. :)
				for $namedGraph in (element graphs {//graph except (doc($defaultGraphURI)/graph)})/graph
				return
					<sd:namedGraph rdf:nodeID="NG{count($namedGraph/preceding-sibling::graph) + 1}"/> )
		}</rdf:Description>,
		
		(: Default Graph details. :)
		( if (doc-available($defaultGraphURI)) then 
			<rdf:Description rdf:nodeID="DG1">
				<void:triples rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{graph:get-length(doc($defaultGraphURI)/graph)}</void:triples>
				<rdf:type rdf:resource="http://www.w3.org/ns/sparql-service-description#Graph"/>
			</rdf:Description>
		else 
			() ),
		
		(: Named Graphs details. :)
		( for $namedGraph in (element graphs {//graph except (doc($defaultGraphURI)/graph)})/graph
		let $n as xs:integer := count($namedGraph/preceding-sibling::graph) + 1
		let $graphURI as xs:string := string($namedGraph/@uri)
		return
			( <rdf:Description rdf:nodeID="NG{$n}">
				<sd:graph rdf:nodeID="G{$n}"/>
				<sd:name rdf:resource="{$graphURI}"/>
				<rdf:type rdf:resource="http://www.w3.org/ns/sparql-service-description#NamedGraph"/>
			</rdf:Description>,
			
			<rdf:Description rdf:nodeID="G{$n}">
				<void:triples rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{graph:get-length(doc($graphURI))}</void:triples>
				<rdf:type rdf:resource="http://www.w3.org/ns/sparql-service-description#Graph"/>
			</rdf:Description> )
	)}</rdf:RDF>
return
	trix:rdf-xml-to-trix($serviceDescription, '')
}; 


(:~
 : Takes the baseURI and a normalised string (the slug) and joins them together 
 : to for a new URI.
 : @param $baseURI then URI's base
 : @param $slug the text to be used in creating the new portion of the URI.
 : @return xs:string
 :)
declare function gsp:create-new-uri($baseURI as xs:string, $slug as xs:string) 
	as xs:string
{
	concat($baseURI, if (ends-with($baseURI, '/')) then '' else '/', translate(normalize-space($slug), ' ', '-'))
}; 


(:~
 : Check if a graph already exists for the passed graph URI.
 : @param $graphURI the graph URI to be tested for.
 : @return xs:boolean.
 :)
declare function gsp:graph-exists($graphURI as xs:string) 
	as xs:boolean 
{
	if (doc-available($graphURI)) then 
			true()
		else
			false()
}; 


(:~
 : Throws an error because the graph URI does not exist.
 : @param $graphURI the graph URI to be tested for.
 : @throws err:RES001 - 'Graph Not Found'.
 :)
declare function gsp:graph-not-found($graphURI as xs:string) 
{
	error(xs:QName('err:RES001'), 'Graph Not Found', $graphURI)
}; 


(:~
 : Throws an error because the graph URI already exist.
 : @param $graphURI the graph URI to be tested for.
 : @throws err:REQ004 - 'Graph already exists'.
 :)
declare function gsp:graph-already-exists($graphURI as xs:string) 
{
	error(xs:QName('err:REQ004'), 'Graph already exists.', $graphURI)
};

