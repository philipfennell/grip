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
 : transient (in-memory) graph storage.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

declare namespace tgraph = "http://www.w3.org/TR/rdf-interfaces/TransientGraph"; 

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/rdf-interfaces/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

declare variable $GRAPH as element(rdfi:graph) external;
declare variable $TRIPLE as element(rdfi:triple) external;




(:~
 : Adds the specified triple to the transient (in-memory) graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function tgraph:add($contextGraph as element(rdfi:graph), 
		$triple as element(rdfi:triple)) 
	as element(rdfi:graph)
{
	(: Need to add new namespaces that don't exist in the graph document. :)
	element {xs:QName(name($contextGraph))} {
		$contextGraph/namespace::*,
		$contextGraph/@*,
		$contextGraph/rdfi:uri,
		$triple,
		$contextGraph/rdfi:triple
	}
};

tgraph:add($GRAPH, $TRIPLE)

