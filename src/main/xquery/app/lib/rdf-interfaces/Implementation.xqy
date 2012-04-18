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
 : Function library that provides implementation specific functions for 
 : persisting RDF Interfaces data in a MarkLogic database.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"; 

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/Common.xqy";

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/rdf-interfaces/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $PERMISSIONS as xs:string* := ();

declare variable $DEFAULT_GRAPH_COLLECTION as xs:string* := "http://www.w3.org/TR/rdf-interfaces/Graph";




(:~
 : Insert the passed triple into the database for the context graph URI.
 : @param $graphURI The context graph's URI.
 : @param $triple The Triple to add. Graphs must not contain duplicate triples.
 : @return the context Graph.
 :)
declare function impl:add-triple($graphURI as xs:string, $triple as element(triple)) 
	as empty-sequence()
{
	let $subject as xs:string := rdfnode:to-string(triple:get-subject($triple))
	let $predicate as xs:string := rdfnode:to-string(triple:get-predicate($triple))
	let $object as item()* := rdfnode:to-string(triple:get-object($triple))
	let $collections as xs:string* := ($graphURI)
	return
		xdmp:document-insert(
			impl:uri-for-triple($triple, $graphURI),
			element {QName('', 't')} {
				( element {QName('', 's')} {
					( typeswitch (triple:get-subject($triple))
						case $sub as element(id) 
							return $subject
						default 
							return $subject ) },
				element {QName('', 'p')} {$predicate},
				element {QName('', 'o')} {
					(: Add the language annotation if present. :)
					( triple:get-object($triple)/@xml:lang,
					(: 
					 : When the subject is a URI reference mark it as such with 
					 : xs:anyURI, otherwise copy the datatype, if any.
					 :)
					( typeswitch (triple:get-object($triple)) 
						case element(uri) 
							return ( attribute datatype 
									{'http://www.w3.org/2001/XMLSchema#anyURI'}, 
											$object )
						case element(id) 
							return $object
						default 
							return ( triple:get-object($triple)/@datatype, $object ) ) )},
				element {QName('', 'c')} {$graphURI} )
	    	} ,
	    	$PERMISSIONS,
	    	$collections
	    )
};


(:~
 : Returns the set of Triples within the Graph as a host language native 
 : sequence, in this case an XPath 2.0 sequence.
 : @param $contextGraph
 : @return sequence of zero or more triple elements.
 :)
declare function impl:get-triples($contextGraph as element(graph)) 
	as element(triple)*
{
	xdmp:xslt-invoke('xslt/ml-tuples-to-graph.xsl', 
		document { 
			element {xs:QName(name($contextGraph))} {
				$contextGraph/@*,
				$contextGraph/uri,
				for $t in collection(impl:get-graph-uri($contextGraph))/*
				return
					element {QName('', 't')} {
						attribute xml:base {base-uri($t)},
						$t/*
					}
			}
		}
	)//triple
};


(:~
 : Removes the specified Triple from the persistent graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function impl:remove-triple($contextGraph as element(graph), 
		$triple as element(triple)) 
	as element(graph)
{
	let $remove := xdmp:document-delete(string($triple/@xml:base))
	return
		$contextGraph
};


(:~
 : A non-negative integer that specifies the number of Triples in the set.
 : @param $contextGraph
 : @return Unsigned Long.
 :)
declare function impl:count-triples($contextGraph as element(graph)) 
	as xs:unsignedLong
{
	xdmp:estimate(collection(impl:get-graph-uri($contextGraph)))
};


(:~
 : Determin if the context node is Persistent (in-database) or Transient 
 : (in-memory) by looking for a Base URI.
 : @param the context node to be tested for persistence.
 : @return xs:boolean
 :)
declare function impl:is-persistent($contextNode as element()) 
	as xs:boolean
{
	exists(base-uri($contextNode))
};


(:~
 : Returns the context graph's URI.
 : @param $contextGraph 
 : @return xs:string.
 :)
declare function impl:get-graph-uri($contextGraph as element(graph)) 
	as xs:string
{
	string(($contextGraph/uri, base-uri($contextGraph))[1])
};


(:~
 : Build a deterministic uri for a quad. 
 : @param $subject Subject.
 : @param $predicate Predicate.
 : @param $object Object.
 : @param $context
 : @return a URI string.
 :)
declare function impl:uri-for-quad($subject as xs:string, 
		$predicate as xs:string, $object as xs:string, $context as xs:string?)
	as xs:string
{
  xdmp:integer-to-hex(
    xdmp:hash64(
      string-join(($subject, $predicate, $object, $context), '|') ) )
};


(:~
 : Build a deterministic uri for . 
 : @param $triple The context Triple.
 : @param $context
 : @return a URI string.
 :)
declare function impl:uri-for-triple($triple, $context as xs:string?)
	as xs:string
{
  xdmp:integer-to-hex(
    xdmp:hash64(
      string-join((triple:to-string($triple), $context, string(current-dateTime())), '|') ) )
};


(:~
 : Inserts entries into the context Map. If override is 
 : true() then replace entries with new ones with the same key. 
 : @param $contextMap
 : @param $entries A sequence of entries.
 : @param $override If true() then conflicting keys will be overridden by 
 : those specified on the Map being imported, by default imported 
 : entries augment the existing set.
 : @return empty sequence.
 :)
declare function impl:map-add($contextMap as element(), 
		$entries as element(entry)*, $override as xs:boolean) 
	as empty-sequence()
{
	for $newEntry in $entries
	let $key as xs:string := string($newEntry/@xml:id)
	let $matchingEntry as element(entry)? := $contextMap/entry[@xml:id eq $key]
	return
		if (exists($matchingEntry)) then 
			( if ($override eq true()) then 
				xdmp:node-replace($matchingEntry, $newEntry)
			else
				() )
		else
			xdmp:node-insert-child($contextMap, $newEntry)
};


(:~
 : Set the value for the passed key in the context Map.
 : @param $contextMap
 : @param $key the look-up key of the entry to be set.
 : @param $value 
 : @return empty sequence.
 :)
declare function impl:map-set($contextMap as element(), $key as xs:string, 
		$value as xs:string) 
	as empty-sequence()
{
	let $matchingEntry as element(entry)? := $contextMap/entry[@xml:id eq $key]
	let $newEntry as element(entry) := <entry xml:id="{$key}">{$value}</entry>
	return
		if (exists($matchingEntry)) then 
			xdmp:node-replace($matchingEntry, $newEntry)
		else
			xdmp:node-insert-child($contextMap, $newEntry)
};


(:~
 : Remove an entry from the context Map.
 : @param $contextMap 
 : @param $key the look-up key of the entry to be removed.
 : @return empty sequence.
 :)
declare function impl:map-remove($contextMap as item(), $key as xs:string) 
	as empty-sequence()
{
	let $matchingEntry as element(entry)? := $contextMap/entry[@xml:id eq $key]
	return
		xdmp:node-delete($matchingEntry)
};


(:~
 : Inserts a <uri> element as the first chiold of the graph.
 : @param $graph The context graph.
 : @param $uri The URI to be inserted.
 : @return the updated graph.
 :)
declare function impl:graph-add-uri($graph as element(graph), $uri as xs:string) 
	as element(graph)
{
	element {xs:QName(name($graph))} {
		<uri>{$uri}</uri>,
		$graph/*
	}
};

