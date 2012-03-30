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
 : Function library that implements the W3C's RDF Interface: RDFNode.
 : RDFNode is the base class of NamedNode, BlankNode, and Literal. Not that 
 : XQuery has the concept of classes, but the methods/properties it defines are 
 : useful functions to have.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";




(:~
 : The nominalValue of an RDFNode is refined by each interface which extends 
 : RDFNode.
 : @param $contextRDFNode 
 : @return item()
 :)
declare function rdfnode:get-nominal-value($contextRDFNode as element()) 
	as item() 
{
	error(xs:QName('NOT_IMPLEMENTED'), 'The function ''rdfnode:get-nominal-value'' is not implemented.')
}; 


(:~
 : Provides access to the string name of the current interface, normally one of 
 : "NamedNode", "BlankNode" or "Literal".
 : @param $contextRDFNode 
 : @return xs:string
 :)
declare function rdfnode:get-interface-name($contextRDFNode as element())
	as xs:string
{
	typeswitch ($contextRDFNode) 
  	case element(rdfi:id) 
  	return 
  		'BlankNode'
  	case element(rdfi:uri) 
  	return
  		'NamedNode'
  	case element(rdfi:plainLiteral) 
  	return 
  		'Literal'
  	case element(rdfi:typedLiteral) 
  	return 
  		'Literal'
  	default
  	return
  		'Unknown'
};


(:~
 : Returns true() if toCompare is equivalent to this node.
 : @param $contextRDFNode 
 : @param $toCompare 
 : @return xs:boolean
 :)
declare function rdfnode:equals($contextRDFNode as element(), 
		$toCompare as element()) 
	as xs:boolean 
{
	(: 
	 : This is probably NOT a good way to compare triples as no account is taken 
	 : of blank nodes. But it'll have to do for now.
	 :)
	deep-equal($contextRDFNode, $toCompare)
};


(:~
 : Converts this node into a string in N-Triples notation.
 : @param $contextRDFNode
 : @return xs:string.
 :)
declare function rdfnode:to-nt($contextRDFNode as element()) 
	as xs:string
{
	xdmp:xslt-invoke('/resources/xslt/text-plain/trix-to-ntriples.xsl', 
			document {$contextRDFNode})
};


(:~
 : The stringification of an RDFNode is defined as follows, 
 : if the interfaceName is:
 : * NamedNode then return the stringified nominalValue.
 : * BlankNode then prepend "_:" to the stringified value and return the result.
 : * Literal then return the stringified nominalValue.
 : @param $contextRDFNode
 : @return xs:string.
 :)
declare function rdfnode:to-string($contextRDFNode as element()) 
	as xs:string
{
	typeswitch ($contextRDFNode) 
  	case element(rdfi:id) 
  	return 
  		if (starts-with(string($contextRDFNode), '_:')) then 
  			string($contextRDFNode) 
  		else 
  			concat('_:', if (matches(string($contextRDFNode), '^[a-zA-Z]')) then '' 
  					else 'A', string($contextRDFNode))
  	case element(rdfi:typedLiteral) 
	return 
		(: If an XML Literal, copy the children and serialize as a string... :)
		if (ends-with(string($contextRDFNode/@datatype), '#XMLLiteral')) then
			xdmp:quote(<item>{$contextRDFNode/(* | text())}</item>)
		(: ...otherwise, take the string value. :)
		else
			string($contextRDFNode)
 	default 
 	return 
 		string($contextRDFNode)
};


(:~
 : Converts this triple into a string in N-Triples notation.
 : @param $contextRDFNode
 : @return xs:string.
 :)
declare function rdfnode:value-of($contextRDFNode as element()) 
	as xs:anyAtomicType
{
	let $value as xs:string := rdfnode:to-string($contextRDFNode)
	let $type as xs:string := substring-after($contextRDFNode/@datatype, '#')
	let $namespace as xs:string := substring-before($contextRDFNode/@datatype, '#')
	return
		typeswitch ($contextRDFNode) 
	  	case element(rdfi:id) 
	  	return 
	  		xs:string($value)
	  	case element(rdfi:uri) 
	  	return
	  		xs:string($value)
	  	case element(rdfi:plainLiteral) 
	  	return 
	  		xs:string($value)
	  	case element(rdfi:typedLiteral) 
	  	return 
	  		try {
	  			xdmp:apply(xdmp:function(QName($namespace, $type)), ($value))
	  		} catch ($error) {
	  			xs:string($value)
	  		}
	  	default
	  	return
	  		xs:string($value)
};
