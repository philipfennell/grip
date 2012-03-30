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
 : Function library that implements the W3C's RDF Interface: Graph for 
 : persistant (in-database) graph storage.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace pgraph = "http://www.w3.org/TR/rdf-interfaces/PeristantGraph"; 

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/rdf-interfaces/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";




(:~
 : Adds the specified triple to the persistant (in-database) graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function pgraph:add($contextGraph as element(rdfi:graph), 
		$triple as element(rdfi:triple)) 
	as element(rdfi:graph)
{
	let $subject as xs:string := rdfnode:to-string(triple:get-subject($triple))
	let $predicate as xs:string := rdfnode:to-string(triple:get-predicate($triple))
	let $object as item()* := rdfnode:to-string(triple:get-object($triple))
	let $permissions as xs:string* := ()
	let $collections as xs:string* := (graph:uri($contextGraph))
	let $add := 
		xdmp:document-insert(
			graph:uri-for-quad($subject, $predicate, $object, 
					graph:uri($contextGraph)),
			element t {
				( element s {
					( typeswitch ($triple/*[1])
						case $sub as element(rdfi:id) 
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
						case element(rdfi:uri) 
							return ( attribute datatype 
									{'http://www.w3.org/2001/XMLSchema#anyURI'}, 
											$object )
						case element(rdfi:id) 
							return $object
						default 
							return ( $triple/*[3]/@datatype, $object ) ) )},
				element c {graph:uri($contextGraph)} )
	    	},
	    	$permissions,
	    	$collections
	    )
	return
		(: Need to add new namespaces that don't exist in the graph document. :)
		$contextGraph
};

