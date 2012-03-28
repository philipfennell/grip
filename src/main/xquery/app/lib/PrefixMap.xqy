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

declare default function namespace "http://www.w3.org/2005/xpath-functions";
	
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
	let $namespaceIRI as xs:string? := map:get($contextPrefixMap, $prefix)
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
declare function prefixmap:shrink($contextPrefixMap as item(), $iri as xs:string) 
	as xs:string
{
	let $namespaceIRI as xs:string := 
		if (matches($iri, '#[A-Za-z_\-\.]+$')) then 
			concat(substring-before($iri, '#'), '#')
		else
			string-join((reverse(subsequence(reverse(tokenize($iri, '/')), 2)), ''), '/')
	let $prefix as xs:string? := 
		for $key in map:keys($contextPrefixMap)
		where map:get($contextPrefixMap, $key) eq $namespaceIRI
		return
			$key
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
declare function prefixmap:set-default($contextPrefixMap as item(), 
		$iri as xs:string) 
	as empty-sequence()
{
	let $_put := map:put($contextPrefixMap, '', $iri)
	return
		()
};


(:~
 : Import a PrefixMap into the context PrefixMap.
 : @param $contextPrefixMap 
 : @param $prefixes 
 : @param $override 
 : @return 
 :)
declare function prefixmap:add-all($contextPrefixMap as item(), 
		$prefixes as item(), $override as xs:boolean) 
	as item()
{
	let $addAll := 
		for $key in map:keys($prefixes)
		where if ($override eq true()) then 
				true() 
			else 
				not($key = map:keys($contextPrefixMap))
		return
			map:put($contextPrefixMap, $key, map:get($prefixes, $key))
	return
		$contextPrefixMap
};


(:~
 : Import a PrefixMap into the context PrefixMap.
 : @param $contextPrefixMap 
 : @param $prefixes 
 : @return 
 :)
declare function prefixmap:add-all($contextPrefixMap as item(), 
		$prefixes as item()) 
	as item()
{
	prefixmap:add-all($contextPrefixMap, $prefixes, false())
};

