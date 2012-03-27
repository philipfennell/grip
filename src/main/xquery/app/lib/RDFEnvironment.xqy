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
 : Function library that implements the W3C's RDF Interface: RDFEnvironment.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment";  

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/Graph.xqy";

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/RDFNode.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";




(:~
 : Creates a new Graph, an optional sequence of Triples to include within the 
 : graph may be specified, this allows easy transition between native sequences 
 : and Graphs and is the counterpart for the to-array method of the Graph 
 : interface.
 : @param $triples
 : @return a new Graph.
 :)
declare function rdfenv:create-graph($triples as element(trix:triple)*) 
	as element(trix:graph) 
{
	let $namespaces as item()* := 
			for $triple in $triples return $triple/namespace::*
	return
		<graph>{
			$namespaces,
			<uri/>,
			$triples
		}</graph>
};


(:~
 : Creates a Triple given a subject, predicate and object. If any incoming 
 : value does not match the requirements listed below, a Null value must be 
 : returned by this method.
 : @param $subject
 : @param $predicate
 : @param $object
 : @return a new Triple.
 :)
declare function rdfenv:create-triple($subject as element(), 
		$predicate as element(), $object as element()) 
	as element(trix:triple)? 
{
	<triple>{$subject, $predicate, $object}</triple>
};


(:~
 : Creates a Literal given a value, an optional language or an optional datatype.
 : @param $value The value to be represented by the Literal, the value must be 
 : a lexical representation of the value.
 : @param $language The language that is associated with the Literal.
 : @param $datatype The datatype of the Literal.
 : @return a new Literal.
 :)
declare private function rdfenv:create-literal($value as item(), 
		$language as xs:string?, $datatype as element()?) 
	as element()
{
	if (string-length($language) gt 0) then 
		<plainLiteral xml:lang="{$language}">{$value}</plainLiteral>
	else if (string-length($datatype) gt 0) then 
		<typedLiteral datatype="{rdfnode:to-string($datatype)}">{
			$value
		}</typedLiteral>
	else
		<plainLiteral>{$value}</plainLiteral>
};

declare function rdfenv:create-literal($value as item()) 
	as element()
{
	rdfenv:create-literal($value, (), ())
};

declare function rdfenv:create-literal($value as item(), $param as item()) 
	as element()
{
	typeswitch ($param) 
  	case element(trix:uri) 
  	return 
		rdfenv:create-literal($value, (), $param)
	default
	return
		rdfenv:create-literal($value, $param, ())
};

