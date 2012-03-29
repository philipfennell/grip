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
 : The RDF Environment is an interface which exposes a high level API for 
 : working with RDF in a programming environment.
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

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/PrefixMap.xqy";

import module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/TermMap.xqy";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/Profile.xqy";

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
 : Creates a new Graph.
 : @return a new Graph.
 :)
declare function rdfenv:create-graph() 
	as element(trix:graph) 
{
	rdfenv:create-graph(())
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
 : Creates a Literal given a value, an optional language and/or an optional 
 : datatype.
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


(:~
 : Creates a plain Literal given a value
 : @param $value The value to be represented by the Literal, the value must be 
 : a lexical representation of the value.
 : @return a new Literal.
 :)
declare function rdfenv:create-literal($value as item()) 
	as element()
{
	rdfenv:create-literal($value, (), ())
};


(:~
 : Creates a Literal given a value, and a language or datatype. the language 
 : and datatype arguments are mutually exclusive.
 : @param $value The value to be represented by the Literal, the value must be 
 : a lexical representation of the value.
 : @param $arg
 : @return a new Literal.
 :)
declare function rdfenv:create-literal($value as item(), $arg as item()) 
	as element()
{
	typeswitch ($arg) 
  	case element(trix:uri) 
  	return 
		rdfenv:create-literal($value, (), $arg)
	default
	return
		rdfenv:create-literal($value, $arg, ())
};


(:~
 : Creates a NamedNode identified by the given IRI.
 : @param $value An IRI, CURIE or TERM.
 : @return a new NamedNode.
 :)
declare function rdfenv:create-named-node($value as item()) 
	as element(trix:uri)
{
	<uri>{$value}</uri>
};


(:~
 : Creates a new BlankNode.
 : @return a new BlankNode.
 :)
declare function rdfenv:create-blank-node() 
	as element(trix:id)
{
	<id/>
};


(:~
 : Create a new PrefixMap.
 : @param $empty If true is specified then an empty PrefixMap will be returned, 
 : by default the PrefixMap returned will be populated with prefixes 
 : replicating those of the current RDF environment.
 : @return a new PrefixMap.
 :)
declare function rdfenv:create-prefix-map($empty as xs:boolean) 
	as item() 
{
	if ($empty) then 
		map:map()
	else
		map:map()
};


(:~
 : Create a new PrefixMap.
 : PrefixMap returned will be populated with prefixes replicating those of the 
 : current RDF environment.
 : @return a new PrefixMap.
 :)
declare function rdfenv:create-prefix-map() 
	as item() 
{
	map:map()
};


(:~
 : Create a new TermMap.
 : @param $empty If true is specified then an empty TermMap will be returned, 
 : by default the TermMap returned will be populated with terms replicating 
 : those of the current RDF environment.
 : @return a new TermMap.
 :)
declare function rdfenv:create-term-map($empty as xs:boolean) 
	as item() 
{
	if ($empty) then 
		map:map()
	else
		map:map()
};


(:~
 : Create a new TermMap.
 : TermMap returned will be populated with terms replicating those of the 
 : current RDF environment.
 : @return a new TermMap.
 :)
declare function rdfenv:create-term-map() 
	as item() 
{
	map:map()
};


(:~
 : Create a new Profile.
 : @param $empty If true is specified then a profile with an empty TermMap and 
 : PrefixMap will be returned, by default the Profile returned will contain 
 : populated term and prefix maps replicating those of the current RDF 
 : environment.
 : @return a new Profile.
 :)
declare function rdfenv:create-profile($empty as xs:boolean) 
	as empty-sequence()
{
	()
};

