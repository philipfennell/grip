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
 : Function library that implements the W3C's RDF Interface: Triple.
 : The Triple interface represents an RDF Triple. The stringification of a 
 : Triple results in an N-Triples representation as defined in: 
 : <http://www.w3.org/TR/2004/REC-rdf-testcases-20040210/#ntriples>
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";




(:~
 : The subject associated with the Triple.
 : @param $triple
 : @return subject of type RDFNode
 :)
declare function triple:subject($triple as element(trix:triple)) 
	as element() 
{
	$triple/*[1]
};


(:~
 : The predicate associated with the Triple.
 : @param $triple
 : @return predicate of type RDFNode
 :)
declare function triple:predicate($triple as element(trix:triple)) 
	as element() 
{
	$triple/*[2]
};


(:~
 : The object associated with the Triple.
 : @param $triple
 : @return object of type RDFNode
 :)
declare function triple:object($triple as element(trix:triple)) 
	as element() 
{
	$triple/*[3]
};


(:~
 : Converts this triple into a string in N-Triples notation.
 : @param $triple
 : @return xs:string.
 :)
declare function triple:to-string($triple as element(trix:triple)) 
	as xs:string
{
	xdmp:xslt-invoke('/resources/xslt/text-plain/trix-to-ntriples.xsl', document {$triple})
};


(:~
 : Returns true() if otherTriple is equivalent to this triple.
 : @param 
 : @return xs:boolean
 :)
declare function triple:equals($triple as element(trix:triple), 
		$otherTriple as element(trix:triple)) 
	as xs:boolean 
{
	(: 
	 : This is probably NOT a good way to compare triples as no account is taken 
	 : of blank nodes. But it'll have to do for now.
	 :)
	deep-equal($triple, $otherTriple)	
};
