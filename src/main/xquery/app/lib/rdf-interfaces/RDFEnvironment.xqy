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
	at "/lib/rdf-interfaces/Graph.xqy";

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/rdf-interfaces/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/rdf-interfaces/PrefixMap.xqy";

import module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/rdf-interfaces/TermMap.xqy";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/rdf-interfaces/Profile.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";




(:~
 : Creates a new Graph, an optional sequence of Triples to include within the 
 : graph may be specified, this allows easy transition between native sequences 
 : and Graphs and is the counterpart for the to-array method of the Graph 
 : interface.
 : @param $contextRDFEnvironment
 : @param $triples
 : @return a new Graph.
 :)
declare function rdfenv:create-graph(
		$contextRDFEnvironment as element(rdf-environment), 
				$triples as element(rdfi:triple)*) 
	as element(rdfi:graph) 
{
	<graph>{
		<uri/>,
		<actions/>,
		$triples
	}</graph>
};


(:~
 : Creates a new, but empty, Graph.
 : @param $contextRDFEnvironment
 : @return a new Graph.
 :)
declare function rdfenv:create-graph(
		$contextRDFEnvironment as element(rdf-environment)) 
	as element(rdfi:graph) 
{
	rdfenv:create-graph(())
};


(:~
 : Creates a Triple given a subject, predicate and object. If any incoming 
 : value does not match the requirements listed below, a Null value must be 
 : returned by this method.
 : @param $contextRDFEnvironment
 : @param $subject
 : @param $predicate
 : @param $object
 : @return a new Triple.
 :)
declare function rdfenv:create-triple(
		$contextRDFEnvironment as element(rdf-environment), 
				$subject as element(), $predicate as element(), 
						$object as element()) 
	as element(rdfi:triple)? 
{
	<triple>{$subject, $predicate, $object}</triple>
};


(:~
 : Creates a Literal given a value, an optional language and/or an optional 
 : datatype.
 : @param $contextRDFEnvironment
 : @param $value The value to be represented by the Literal, the value must be 
 : a lexical representation of the value.
 : @param $language The language that is associated with the Literal.
 : @param $datatype The datatype of the Literal.
 : @return a new Literal.
 :)
declare private function rdfenv:create-literal(
		$contextRDFEnvironment as element(rdf-environment), $value as item(), 
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
 : @param $contextRDFEnvironment
 : @return a new Literal.
 :)
declare function rdfenv:create-literal(
		$contextRDFEnvironment as element(rdf-environment), $value as item()) 
	as element()
{
	rdfenv:create-literal($contextRDFEnvironment, $value, (), ())
};


(:~
 : Creates a Literal given a value, and a language or datatype. the language 
 : and datatype arguments are mutually exclusive.
 : @param $value The value to be represented by the Literal, the value must be 
 : a lexical representation of the value.
 : @param $contextRDFEnvironment
 : @param $arg
 : @return a new Literal.
 :)
declare function rdfenv:create-literal(
		$contextRDFEnvironment as element(rdf-environment), $value as item(), 
				$arg as item()) 
	as element()
{
	typeswitch ($arg) 
  	case element(rdfi:uri) 
  	return 
		rdfenv:create-literal($contextRDFEnvironment, $value, (), $arg)
	default
	return
		rdfenv:create-literal($contextRDFEnvironment, $value, $arg, ())
};


(:~
 : Creates a NamedNode identified by the given IRI.
 : @param $contextRDFEnvironment
 : @param $value An IRI, CURIE or TERM.
 : @return a new NamedNode.
 :)
declare function rdfenv:create-named-node(
		$contextRDFEnvironment as element(rdf-environment), $value as item()) 
	as element(rdfi:uri)
{
	<uri>{$value}</uri>
};


(:~
 : Creates a new BlankNode.
 : @param $contextRDFEnvironment
 : @return a new BlankNode.
 :)
declare function rdfenv:create-blank-node(
		$contextRDFEnvironment as element(rdf-environment)) 
	as element(rdfi:id)
{
	<id/>
};


(:~
 : Create a new PrefixMap.
 : @param $empty If true is specified then an empty PrefixMap will be returned, 
 : by default the PrefixMap returned will be populated with prefixes 
 : replicating those of the current RDF environment.
 : @param $contextRDFEnvironment
 : @return a new PrefixMap.
 :)
declare function rdfenv:create-prefix-map(
		$contextRDFEnvironment as element(rdf-environment), 
				$empty as xs:boolean) 
	as element(prefix-map) 
{
	if ($empty) then 
		<prefix-map/>
	else
		$contextRDFEnvironment/prefix-map
};


(:~
 : Create a new PrefixMap.
 : PrefixMap returned will be populated with prefixes replicating those of the 
 : current RDF environment.
 : @param $contextRDFEnvironment
 : @return a new PrefixMap.
 :)
declare function rdfenv:create-prefix-map(
		$contextRDFEnvironment as element(rdf-environment)) 
	as element(prefix-map) 
{
	rdfenv:create-prefix-map($contextRDFEnvironment, false())
};


(:~
 : Create a new TermMap.
 : @param $empty If true is specified then an empty TermMap will be returned, 
 : by default the TermMap returned will be populated with terms replicating 
 : those of the current RDF environment.
 : @param $contextRDFEnvironment
 : @return a new TermMap.
 :)
declare function rdfenv:create-term-map(
		$contextRDFEnvironment as element(rdf-environment), 
				$empty as xs:boolean) 
	as element(term-map) 
{
	if ($empty) then 
		<term-map/>
	else
		$contextRDFEnvironment/term-map
};


(:~
 : Create a new TermMap.
 : TermMap returned will be populated with terms replicating those of the 
 : current RDF environment.
 : @param $contextRDFEnvironment
 : @return a new TermMap.
 :)
declare function rdfenv:create-term-map(
		$contextRDFEnvironment as element(rdf-environment)) 
	as element(term-map) 
{
	rdfenv:create-term-map($contextRDFEnvironment, false())
};


(:~
 : Create a new Profile.
 : @param $empty If true is specified then a profile with an empty TermMap and 
 : PrefixMap will be returned, by default the Profile returned will contain 
 : populated term and prefix maps replicating those of the current RDF 
 : environment.
 : @param $contextRDFEnvironment
 : @return a new Profile.
 :)
declare function rdfenv:create-profile(
		$contextRDFEnvironment as element(rdf-environment), $empty as xs:boolean) 
	as element(rdfi:profile)
{
	<profile>{
		if ($empty) then 
			( <prefix-map/>,
			<term-map/> )
		else
			($contextRDFEnvironment/prefix-map, $contextRDFEnvironment/term-map)
	}</profile>
};


(:~
 : Create a new Profile.
 : @param $contextRDFEnvironment
 : @return a new Profile.
 :)
declare function rdfenv:create-profile(
		$contextRDFEnvironment as element(rdf-environment)) 
	as element(rdfi:profile)
{
	rdfenv:create-profile($contextRDFEnvironment, false())
};

