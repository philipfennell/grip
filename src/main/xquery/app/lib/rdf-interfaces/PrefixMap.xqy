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
 : Function library that implements the W3C's RDF Interface: PrefixMap.
 : PrefixMap - which is a map of prefixes to IRIs, and provides methods to turn 
 : one in to the other.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"; 

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/Common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
	
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";




(:~
 : Given a valid CURIE for which a prefix is known (for example "rdfs:label"), 
 : this method will return the resulting IRI 
 : (for example "http://www.w3.org/2000/01/rdf-schema#label")
 : If the prefix is not known then this method will return null.
 : @param $contextPrefixMap 
 : @param $curie The CURIE to resolve.
 : @return an IRI as an xs:string.
 :)
declare function prefixmap:resolve($contextPrefixMap as item(), $curie as xs:string) 
	as xs:string?
{
	let $prefix as xs:string? := substring-before($curie, ':')
	let $term as xs:string := substring-after($curie, ':')
	let $namespaceIRI as xs:string? := prefixmap:get($contextPrefixMap, $prefix)
	return
		if (string-length($namespaceIRI) gt 0) then 
			concat($namespaceIRI, $term)
		else
			()
};


(:~
 : Given an IRI for which a prefix is known 
 : (for example "http://www.w3.org/2000/01/rdf-schema#label") this method 
 : returns a CURIE (for example "rdfs:label"), if no prefix is known the 
 : original IRI is returned.
 : @param $contextPrefixMap 
 : @param $iri The IRI to shrink to a CURIE.
 : @return a CURIE as an xs:string.
 :)
declare function prefixmap:shrink($contextPrefixMap as element(prefix-map), 
		$iri as xs:string) 
	as xs:string
{
	let $namespaceIRI as xs:string := 
		if (matches($iri, '#[A-Za-z_\-\.]+$')) then 
			concat(substring-before($iri, '#'), '#')
		else
			string-join((reverse(subsequence(reverse(tokenize($iri, '/')), 2)), ''), '/')
	let $prefix as xs:string? := 
		for $id in $contextPrefixMap/entry/@xml:id
		where prefixmap:get($contextPrefixMap, string($id)) eq $namespaceIRI
		return
			$id
	let $term as xs:string := 
		( substring-after($iri, $namespaceIRI), 
				substring-after($iri, concat($namespaceIRI, '/')) )[1]
	return
		if ($prefix) then 
			concat($prefix, ':', $term)
		else
			$iri
};


(:~
 : Sets the 'default' URI for curies without a prefix.
 : @param $contextPrefixMap 
 : @param $iri The iri to be used when resolving CURIEs without a prefix, 
 : for example ":this".
 : @return 
 :)
declare function prefixmap:set-default($contextPrefixMap as element(prefix-map), 
		$iri as xs:string) 
	as element(prefix-map)
{
	prefixmap:set($contextPrefixMap, '_', $iri)
};


(:~
 : Import a PrefixMap into the context PrefixMap.
 : @param $contextPrefixMap 
 : @param $prefixes The PrefixMap to import.
 : @param $override If true() then conflicting prefixes will be overridden by 
 : those specified on the PrefixMap being imported, by default imported 
 : prefixes augment the existing set.
 : @return PrefixMap
 :)
declare function prefixmap:add-all($contextPrefixMap as element(prefix-map), 
		$prefixes as element(prefix-map), $override as xs:boolean) 
	as element(prefix-map)
{
	common:map-add($contextPrefixMap, $prefixes/entry, $override)
};


(:~
 : Import a PrefixMap into the context PrefixMap.
 : @param $contextPrefixMap 
 : @param $prefixes The PrefixMap to import.
 : @return PrefixMap
 :)
declare function prefixmap:add-all($contextPrefixMap as element(prefix-map), 
		$prefixes as item()) 
	as element(prefix-map)
{
	prefixmap:add-all($contextPrefixMap, $prefixes, false())
};


(:~
 : Get the IRI from the passed prefix.
 : @param $contextPrefixMap
 : @param $prefix
 : @return xs:string
 :)
declare function prefixmap:get($contextPrefixMap as element(prefix-map), 
		$prefix as xs:string) 
	as xs:string?
{
	common:map-get($contextPrefixMap, $prefix)
};


(:~
 : Set the IRI from the passed prefix.
 : @param $contextPrefixMap
 : @param $prefix The prefix must not contain any whitespace.
 : @param $iri An IRI.
 : @return empty sequence.
 :)
declare function prefixmap:set($contextPrefixMap as element(prefix-map), 
		$prefix as xs:string, $iri as xs:string) 
	as element(prefix-map)
{
	common:map-set($contextPrefixMap, $prefix, $iri)
};


(:~
 : Remove the prefix/IRI from the context PrefixMap.
 : @param $contextPrefixMap
 : @param $prefix 
 : @return empty sequence.
 :)
declare function prefixmap:remove($contextPrefixMap as item(), $prefix as xs:string) 
	as element(prefix-map)
{
	let $thisId as xs:string := if ($prefix eq '') then '_' else $prefix
	return
		element {xs:QName(name($contextPrefixMap))} {
			( $contextPrefixMap/@*,
			for $entry in $contextPrefixMap/entry
			where not(string($entry/@xml:id) eq $thisId)
			return
				$entry )
		}
};

