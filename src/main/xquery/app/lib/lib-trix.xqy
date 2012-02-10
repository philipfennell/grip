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
 : Function library for working with TriX Graph documents.
 : @see http://www.hpl.hp.com/techreports/2004/HPL-2004-56.pdf
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace nt 	= "http://www.w3.org/ns/formats/N-Triples";
declare namespace rdf 	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace ttl 	= "http://www.w3.org/ns/formats/Turtle";


(:~
 : Returns the subject URI or NodeID from the triple.
 : @param $triple context triple.
 : @return xs:string
 :)
declare function trix:subject-from-triple($triple as element(trix:triple)) 
		as xs:string 
{
	trix:parse-content($triple/*[1])
};


(:~
 : Returns the predicate URI from the triple.
 : @param $triple context triple.
 : @return xs:string
 :)
declare function trix:predicate-from-triple($triple as element(trix:triple)) 
		as xs:string 
{
	string($triple/*[2])
};


(:~
 : Returns the object value or reference.
 : @param $triple context triple.
 : @return xs:string
 :)
declare function trix:object-from-triple($triple as element(trix:triple)) 
		as item()*
{
	trix:parse-content($triple/*[3])
};


(:~
 : Takes a reference (uri or id) and returns either the URI as-is or a nodeID 
 : with '_:' prepended on the front to uniquiely identify the value as a nodeID
 : in that context.
 : @param $obj the object.
 : @return xs:string
 :)
declare function trix:parse-content($object as element()) 
		as item()*
{
	typeswitch ($object) 
  	case element(trix:id) 
  	return 
  		if (starts-with(string($object), '_:A')) then 
  			string($object) 
  		else 
  			concat('_:A', string($object))
  	case element(trix:typedLiteral) 
	return 
		(: If an XML Literal... copy the children... :)
		if (ends-with(string($object/@datatype), '#XMLLiteral')) then
			$object/(* | text())
		(: ...otherwise, take the string value. :)
		else
			string($object)
 	default 
 	return 
 		string($object)
};


(:~
 : Transform the RDF/XML to TriX.
 : @param $rdf the graph to be inserted.
 : @param $graphURI the graph URI.
 : @return element(trix:trix)
 :)
declare function trix:rdf-xml-to-trix($rdf as element(), $graphURI as xs:string)
	as element(trix:trix)
{
	let $params := map:map()
	let $_put := map:put($params, 'GRAPH_URI', $graphURI)
	let $_put := map:put($params, 'BASE_URI', $graphURI)
	return
		xdmp:xslt-invoke('/resources/xslt/lib/rdf-xml-to-trix.xsl', document {$rdf}, $params)/*
};


(:~
 : Transform the RDF/N-Triples to TriX.
 : @param $rdf the graph to be inserted.
 : @param $graphURI the graph URI.
 : @return element(trix:trix)
 :)
declare function trix:ntriples-to-trix($rdf as element(nt:RDF), $graphURI as xs:string)
	as element(trix:trix)
{
	let $params := map:map()
	let $_put := map:put($params, 'GRAPH_URI', $graphURI)
	return
		xdmp:xslt-invoke('/resources/xslt/lib/ntriples-to-trix.xsl', $rdf, $params)/*
};


(:~
 : Transform the RDF/Turtle to TriX.
 : @param $rdf the graph to be inserted.
 : @param $graphURI the graph URI.
 : @return element(trix:trix)
 :)
declare function trix:turtle-to-trix($rdf as element(ttl:RDF), $graphURI as xs:string)
	as element(trix:trix)
{
	let $params := map:map()
	let $_put := map:put($params, 'GRAPH_URI', $graphURI)
	return
		xdmp:xslt-invoke('/resources/xslt/lib/turtle-to-trix.xsl', $rdf, $params)/*
};


(:~
 : Overwrites the existing graph URI with the passed URI.
 : @param $trix the graph to be inserted.
 : @param $graphURI the graph URI.
 : @return element(trix:trix)
 :)
declare function trix:trix-set-graph-uri($trix as element(trix:trix), $graphURI as xs:string)
	as element(trix:trix)
{
	let $params := map:map()
	let $_put := map:put($params, 'GRAPH_URI', $graphURI)
	return
		xdmp:xslt-invoke('/resources/xslt/lib/trix-set-graph-uri.xsl', $trix, $params)/*
};


(:~
 : Transform MarkLogic's internal graph data model into TriX.
 : @param $graph the graph to be inserted.
 : @return element(trix:trix)
 :)
declare function trix:tuples-to-trix($graph as element(graph), $namespaces as element())
	as element(trix:trix)
{
	let $params := map:map()
	let $_put := map:put($params, 'NAMESPACES', $namespaces)
	return
		xdmp:xslt-invoke('/resources/xslt/lib/ml-tuples-to-trix.xsl', $graph, $params)/*
};
