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
 : Function library that implements common functions for the W3C's RDF 
 : Interface.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace ntdp = "http://www.w3.org/TR/rdf-interfaces/NTriplesDataParser";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace nt = "http://www.w3.org/ns/formats/N-Triples";



(:~
 : A function, which when called will serialize the given Graph and return the 
 : resulting serialization.
 : @param $toParse The document to parse.
 : @param $callBack The ParserCallback to execute once the parse has completed, 
 : the ParserCallback will be passed a single argument which is the propulated 
 : Graph.
 : @param $base An optional base to be used by the parser when resolving 
 : relative IRI references.
 : @param $filter An optional TripleFilter to test each Triple against before 
 : adding to the output Graph, only those triples successfully passing the test 
 : will be added to the output graph.
 : @param $graph An optional Graph to add the parsed triples to, if no Graph is 
 : provided then a new, empty, Graph will be used.
 : @return Graph.
 :)
declare function ntdp:parse($toParse as xs:string, $callBack as item(), 
		$base as xs:string?, $filter as item()?, $graph as element(graph)?) 
	as element(graph)
{
	xdmp:xslt-invoke('xslt/ntriples-to-graph.xsl', document {<nt:RDF>{$toParse}</nt:RDF>})/*
};

