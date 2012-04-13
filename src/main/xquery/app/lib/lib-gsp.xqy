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
		$requestURI
	else if (not($default) and string-length($graphURI) gt 0) then 
			$graphURI
	else
		()
}; 


(:~
 : Currently an incredibly simplistic parsing process. Deserialises the passed
 : graph which is assumed to be RDF/XML.
 : @param $graphURI the graph URI.
 : @param $graphContent the graph to be inserted.
 : @param $mediaType graph serialisation media-type.
 : @return element(graph)
 : @throws err:REQ005 - Unsupported Media Type.
 :)
declare function gsp:parse-graph($graphURI as xs:string, $graphContent as item()?, 
		$mediaType as xs:string)
	as element(trix:trix)
{
	(: 
	 : If it's a text based graph representation, take it as is, else if it's
	 : XML then parse it as XML, otherwise it's not supported.
	 :)
	let $source as element() := 
		if (starts-with($mediaType, 'text/')) then 
			<nt:RDF>{$graphContent}</nt:RDF>
		else if (ends-with($mediaType, '+xml')) then 
			xdmp:unquote($graphContent)/*
		else
			error(xs:QName('err:REQ005'), concat('Unsupported Media Type: ', $mediaType))
	let $info := xdmp:log(concat('[XQuery][GRIP] Parsing Graph: ', $graphURI, ' as ', $mediaType), 'info')
	return
		typeswitch ($source) 
			case element(trix:trix) 
				return trix:trix-set-graph-uri($source, $graphURI)
			case element(nt:RDF) 
				return trix:ntriples-to-trix($source, $graphURI)
			(: case element(ttl:RDF) 
				return trix:turtle-to-trix($source, $graphURI) :)
			case element() 
				return trix:rdf-xml-to-trix($source, $graphURI)
			default 
				return error(xs:QName('err:REQ005'), concat('Unsupported Media Type: ', name($source)))
};


(:~
 : TODO - Make this dynamic.
 : Retrieves a set of all the namespaces and their prefixes that are used in the
 : context graph.
 : @param $graphDoc the context graph
 : @return element(namespaces)
 :)
declare function gsp:get-graph-namespace($graphDoc as element(graph)) 
	as element(gsp:namespaces)
{
	<gsp:namespaces>{
		for $ns in $graphDoc/namespace::* return
			<gsp:namespace prefix="{name($ns)}" uri="{$ns}"/>
	}</gsp:namespaces>
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
 : Inserts the passed graph into the database with the given graph URI.
 : @param $graphContent the graph to be inserted.
 : @return empty-sequence()
 :)
declare function gsp:insert-graph($graphContent as element(trix:graph))
	as empty-sequence()
{
	for $triple in $graphContent/trix:triple 
	return
		gsp:tuple-insert($triple, string($graphContent/trix:uri)) 
};


(:~
 : Inserts the graph document, a record of the graph URI and the namespaces 
 : it uses along with their prefixes. This enables more effective graph 
 : round-tripping by allowing original namespace prefixed to be returned when 
 : the graph is retrieved.
 : @param $graphContent the graph to be inserted.
 : @return empty-sequence()
 :)
declare function gsp:add-graph-doc($graphContent as element(trix:graph)) 
	as empty-sequence() 
{
	let $graphURI as xs:string := string($graphContent/trix:uri)
	let $graphDoc as element(graph) := 
		element graph {
			( attribute uri {$graphURI},
			$graphContent/namespace::* )
		}
	return
		xdmp:document-insert($graphURI, $graphDoc)
};


(:~
 : If the graph document exists then add the new namespaces, otherewise create 
 : a new graph document.
 : @param $graphContent the graph to be inserted.
 : @return empty-sequence()
 :)
declare function gsp:merge-graph-docs($graphContent as element(trix:graph)) 
	as empty-sequence() 
{
	let $graphURI as xs:string := string($graphContent/trix:uri)
	let $graphDoc as element(graph)? := 
		if (doc-available($graphURI)) then doc($graphURI)/graph else ()
	return
		if (exists($graphDoc)) then 
			xdmp:document-insert(
				$graphURI,
				element graph {
					( $graphDoc/namespace::*,
					$graphContent/namespace::*,
					$graphDoc/@* )
				}
			)
		else
			gsp:add-graph-doc($graphContent)
}; 


(:~
 : Takes a TriX triple and inserts it into MarkLogic in the ml-tuples format.
 : In reality it's an extended version of ml-tuples because the original didn't
 : allow for xml:lang and datatype annotations.
 : @param $triple
 :)
declare function gsp:tuple-insert($triple as element(trix:triple), $graphURI as xs:string)
	as empty-sequence()
{
	let $subject as xs:string := trix:subject-from-triple($triple)
	let $predicate as xs:string := trix:predicate-from-triple($triple)
	let $object as item()* := trix:object-from-triple($triple)
	return
		xdmp:document-insert(
			sem:uri-for-tuple($subject, $predicate, gsp:string($object), $graphURI),
			element t {
				( element s {
				( typeswitch ($triple/*[1])
					case $sub as element(trix:id) 
						return $subject
					default 
						return $subject ) },
				element p {$predicate},
				element o {
				(: Add the language annotation if present. :)
				( $triple/*[3]/@xml:lang,
				(: 
				 : When the subject is a URI reference mark it as such with 
				 : xs:anyURI, otherwise copy the datatype, if any.
				 :)
				( typeswitch ($triple/*[3]) 
					case element(trix:uri) 
						return ( attribute datatype {'http://www.w3.org/2001/XMLSchema#anyURI'}, $object )
					case element(trix:id) 
						return $object
					default 
						return ( $triple/*[3]/@datatype, $object ) ) )},
				element c {$graphURI} )
	    	} )
};


(:~
 : Takes a possible sequence of nodes (element and text()) and serialises them
 : to a string.
 : @param $items items to be serialised as a string.
 : @return xs:string
 :)
declare function gsp:string($items as item()*) 
	as xs:string 
{
	xdmp:quote(<item>{$items}</item>)
}; 


(:~
 : Generates a new blank node id that's tied to the graph URI.
 : @param $id the original blank node id.
 : @param $graphURI
 : @return xs:string 
 :)
declare function gsp:generate-blank-node-id($id as xs:string, $graphURI as xs:string) 
	as xs:string 
{
	concat('_:', 'A', string(xdmp:hash64(concat($id, $graphURI))))
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
	return
		( xdmp:document-delete($graphURI),
		for $t in gsp:tuples-for-context($graphURI)
		return
			xdmp:document-delete(base-uri($t)) )
};


(:~
 : When POSTed to the service URI, attempt to create a new graph, if the graph
 : URI already exists then this is an error.
 : @param $graphURI the Graph's URI.
 : @param $graph the Graph to be inserted.
 : @return empty-sequence()
 : @throws 
 :)
declare function gsp:create-graph($graphURI as xs:string, $graph as element(graph))
	as xs:anyURI
{
	let $info := xdmp:log(concat('[XQuery][GRIP] Creating New Graph: ', $graphURI), 'info')
	return
		if (doc-available($graphURI)) then 
			gsp:graph-already-exists($graphURI)
		else
			let $defaultAction as element(action) := 
				rdfenv:create-action($rdfenv:DEFAULT_ENVIRONMENT,
					<filter><![CDATA[
						declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
						declare variable $rdfi:triple as element() external;
						
						true()
					]]></filter>,
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
				xs:anyURI($graphURI)
};


(:~
 : Inserts the passed graph into the database replacing one if it already exists.
 : To get around conflicting updates this function finds those tuples that 
 : already exist and eliminates those that won't be replaced by the incoming 
 : graph and inserts the new graph as a whole.
 : @param $trix the TriX graph to be inserted.
 : @return empty-sequence()
 :)
declare function gsp:add-graph($trix as element(trix:trix))
	as xs:anyURI?
{
	let $graphURI as xs:string := string($trix/trix:graph/trix:uri)
	let $info := xdmp:log(concat('[XQuery][GRIP] Adding Graph: ', $graphURI), 'info')
	let $result as xs:anyURI? := 
		(: 
		 : If the incoming graph already exists, replace the original and return
		 : nothing. Otherwise, insert the new graph and return its new graph URI. 
		 :)
		if (doc-available($graphURI)) then 
			(: The tuples that belong to the context graph URI. :)
			let $existingTuples as element(t)* := gsp:tuples-for-context($graphURI)
			(: Find all existing tuples that match the incoming graph triples. :)
			let $tuplesToBeReplaced as element(t)* := 
				for $triple in $trix/trix:graph/trix:triple
				let $subject as xs:string := trix:subject-from-triple($triple)
				let $predicate as xs:string := trix:predicate-from-triple($triple)
				let $object as item()* := trix:object-from-triple($triple)
				let $tupleURI as xs:string := 
						sem:uri-for-tuple($subject, $predicate, gsp:string($object), $graphURI)
				where doc-available($tupleURI)
				return
					doc($tupleURI)/*
			(: By exclusion, identify those tuples that exist but are not in the incoming graph. :)
			let $tuplesToBeDeleted as element(t)* := $existingTuples except $tuplesToBeReplaced
			return
				( (: Remove any remainder tuples that belong to the context graph but weren't replaced. :)
				for $tupleToDelete in $tuplesToBeDeleted
				return
					xdmp:document-delete(base-uri($tupleToDelete)) )
		else
			xs:anyURI($graphURI)
	return
		( gsp:insert-graph($trix/trix:graph), 
		gsp:add-graph-doc($trix/trix:graph), 
		$result )
};


(:~
 : Merge the passed graph into an existing graph in the database.
 : @param $graph the graph to be merged.
 : @return empty-sequence()
 :)
declare function gsp:merge-graph($trix as element(trix:trix))
	as xs:anyURI?
{
	let $graphURI as xs:string := string($trix/trix:graph/trix:uri)
	let $info := xdmp:log(concat('[XQuery][GRIP] Merging Graph: ', $graphURI), 'info')
	let $debug := xdmp:log('[XQuery][GRIP] Graph Content: ', 'fine')
	let $debug := xdmp:log($trix, 'fine')
	return
		(: 
		 : If the incoming graph already exists, add the triples and return
		 : nothing. Otherwise, add the new graph and return its new graph URI. 
		 :)
		( gsp:insert-graph($trix/trix:graph), 
		gsp:merge-graph-docs($trix/trix:graph),
		if (doc-available($graphURI)) then () else xs:anyURI($graphURI) )
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
				<void:triples rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{count(gsp:tuples-for-context($defaultGraphURI))}</void:triples>
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
				<void:triples rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{count(gsp:tuples-for-context($graphURI))}</void:triples>
				<rdf:type rdf:resource="http://www.w3.org/ns/sparql-service-description#Graph"/>
			</rdf:Description> )
	)}</rdf:RDF>
return
	trix:rdf-xml-to-trix($serviceDescription, '')
}; 


(:~
 : Return all tuples for the given context (all triples for the given graph uri)
 : @param $c the context (graph URI)
 : @return element(t*)
 :)
declare function gsp:tuples-for-context($c as xs:string)
	as element(t)*
{
	sem:tuples-for-query(gsp:cq($c))
};


(:~
 : 
 : @param $c context (graph URI)
 : @return cts:query
 :)
declare function gsp:cq($c as xs:string+)
	as cts:query
{
	gsp:rq($sem:QN-C, $c)
};


(:~
 : RangeQuery - returns a cts:element-range-query with the equal operator 
 : between $qn and $v
 : @param $qn QName
 : @param $v query value
 : @return cts:query
 :)
declare function gsp:rq($qn as xs:QName+, $v as xs:string+)
	as cts:query
{
	cts:element-range-query($qn, '=', $v, 
  			('collation=http://marklogic.com/collation/codepoint'))
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


(:~
 : Transform TriX to RDF/XML.
 : @param $trix the graph to be inserted.
 : @return element(rdf:RDF)
 :)
declare function gsp:trix-to-rdf-xml($trix as element(trix:trix))
	as element(rdf:RDF)
{
	xdmp:xslt-invoke('resources/xslt/application-rdf-xml/trix-to-rdf-xml.xsl', $trix, ())/*
};
