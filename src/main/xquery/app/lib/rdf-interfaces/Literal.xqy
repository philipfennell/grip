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
 : Function library that implements the W3C's RDF Interface: Literal.
 : Literals represent values such as numbers, dates and strings in RDF data.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace literal = "http://www.w3.org/TR/rdf-interfaces/Literal"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";
	
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";




(:~
 : The nominalValue of an RDFNode is refined by each interface which extends 
 : RDFNode.
 : @param $contextLiteral 
 : @return item()
 :)
declare function literal:get-nominal-value($contextLiteral as element()) 
	as item() 
{
	rdfnode:get-nominal-value($contextLiteral)
}; 


(:~
 : Converts this triple into a string in N-Triples notation.
 : @param $contextLiteral
 : @return xs:string.
 :)
declare function literal:value-of($contextLiteral as element()) 
	as xs:anyAtomicType
{
	rdfnode:value-of($contextLiteral)
};


(:~
 : An optional language string as defined in [BCP47], normalized to lowercase.
 : @param $contextLiteral
 : @see http://tools.ietf.org/rfc/bcp/bcp47.txt
 : @return xs:string.
 :)
declare function literal:get-language($contextLiteral as element()) 
	as xs:string?
{
	lower-case(string($contextLiteral/@xml:lang))
};


(:~
 : An optional datatype identified by a NamedNode.
 : @param $contextLiteral
 : @return xs:string.
 :)
declare function literal:get-datatype($contextLiteral as element()) 
	as element()?
{
	<uri xmlns="http://www.w3.org/TR/rdf-interfaces">{string($contextLiteral/@datatype)}</uri>
};

