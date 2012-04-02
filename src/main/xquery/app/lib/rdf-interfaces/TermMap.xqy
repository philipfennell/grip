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
 : Function library that implements the W3C's RDF Interface: TermMap.
 : TermMap - which is a map of simple string terms to IRIs, and provides 
 : methods to turn one in to the other.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap";

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/Common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
	
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";




(:~
 : Given a valid term for which an IRI is known (for example "label"), this 
 : method will return the resulting IRI 
 : (for example "http://www.w3.org/2000/01/rdf-schema#label").
 : If no term is known and a default has been set, the IRI is obtained by 
 : concatenating the term and the default iri.
 : If no term is known and no default is set, then this method returns null.
 : @param $contextTermMap 
 : @param $term The term to resolve.
 : @return an IRI as an xs:string.
 :)
declare function termmap:resolve($contextTermMap as element(term-map), $term as xs:string) 
	as xs:string?
{
	let $resolvedIRI as xs:string? := 
		(termmap:get($contextTermMap, $term), termmap:get($contextTermMap, ''))[1]
	return
		if (string-length($resolvedIRI) gt 0) then 
			concat($resolvedIRI, $term)
		else 
			()
};


(:~
 : Given an IRI for which an term is known 
 : (for example "http://www.w3.org/2000/01/rdf-schema#label") this method 
 : returns a term (for example "label"), if no term is known the original IRI 
 : is returned.
 : @param $contextTermMap 
 : @param $iri The IRI to shrink to a CURIE.
 : @return a CURIE as an xs:string.
 :)
declare function termmap:shrink($contextTermMap as element(term-map), 
		$iri as xs:string) 
	as xs:string
{
	let $namespaceIRI as xs:string := 
		if (matches($iri, '#[A-Za-z_\-\.]+$')) then 
			concat(substring-before($iri, '#'), '#')
		else
			string-join((reverse(subsequence(reverse(tokenize($iri, '/')), 2)), ''), '/')
	let $term as xs:string? := 
		for $id in $contextTermMap/entry/@xml:id
		where concat(termmap:get($contextTermMap, $id), $id) eq $iri
		return
			$id
	return
		if ($term) then 
			$term
		else
			$iri
};


(:~
 : Sets the 'default' URI for curies without a prefix.
 : @param $contextTermMap 
 : @param $iri The default iri to be used when an term cannot be resolved, the 
 : resulting IRI is obtained by concatenating this iri with the term being 
 : resolved.
 : @return TermMap
 :)
declare function termmap:set-default($contextTermMap as element(term-map), 
		$iri as xs:string) 
	as element(term-map)
{
	termmap:set($contextTermMap, '_', $iri)
};


(:~
 : Import a TermMap into the context TermMap.
 : @param $contextTermMap 
 : @param $terms the TermMap to import.
 : @param $override if true then conflicting terms will be overridden by those 
 : specified on the TermMap being imported, by default imported terms augment 
 : the existing set.
 : @return the TermMap instance on which it was called.
 :)
declare function termmap:add-all($contextTermMap as element(term-map), 
		$terms as element(term-map), $override as xs:boolean) 
	as element(term-map)
{
	common:map-add($contextTermMap, $terms/entry, $override)
};


(:~
 : Recursively inserts terms into the context TermMap. If override is 
 : true() then replace entries with new ones with the same term. 
 : @param $contextTermMap
 : @param $prefixes A sequence of terms entries.
 : @param $override If true() then conflicting terms will be overridden by 
 : those specified on the TermMap being imported, by default imported 
 : terms augment the existing set.
 : @return PrefixMap.
 :)
declare private function termmap:add($contextTermMap as element(term-map), 
		$terms as element(entry)*, $override as xs:boolean) 
	as element(term-map)
{
	let $head as element(entry)? := subsequence($terms, 1, 1)
	let $tail as element(entry)* := subsequence($terms, 2)
	return
		if (exists($head)) then 
			termmap:add(
				( if ($head/@xml:id = $contextTermMap/entry/@xml:id) then 
					if ($override eq true()) then 
						termmap:set($contextTermMap, string($head/@xml:id), string($head))
					else
						$contextTermMap
				else
					termmap:set($contextTermMap, string($head/@xml:id), string($head)) ), 
				$tail, $override)
		else
			$contextTermMap
};


(:~
 : Import a TermMap into the context TermMap.
 : @param $contextTermMap 
 : @param $terms the TermMap to import.
 : @return the TermMap instance on which it was called.
 :)
declare function termmap:add-all($contextTermMap as element(term-map), 
		$terms as element(term-map)) 
	as element(term-map)
{
	termmap:add-all($contextTermMap, $terms, false())
};


(:~
 : Get the IRI from the passed term.
 : @param $contextTermMap
 : @param $term
 : @return xs:string
 :)
declare function termmap:get($contextTermMap as element(term-map), 
		$term as xs:string) 
	as xs:string?
{
	common:map-get($contextTermMap, $term)
};


(:~
 : Set the IRI from the passed term.
 : @param $contextTermMap
 : @param $term The term must not contain any whitespace.
 : @param $iri An IRI.
 : @return element(term-map)
 :)
declare function termmap:set($contextTermMap as element(term-map), 
		$term as xs:string, $iri as xs:string) 
	as element(term-map)
{
	common:map-set($contextTermMap, $term, $iri)
};


(:~
 : Remove the term/IRI from the context TermMap.
 : @param $contextTermMap
 : @param $term
 : @return element(term-map)
 :)
declare function termmap:remove($contextTermMap as element(term-map), 
		$term as xs:string) 
	as element(term-map)
{
	let $thisId as xs:string := if ($term eq '') then '_' else $term
	return
		element {xs:QName(name($contextTermMap))} {
			( $contextTermMap/@*,
			for $entry in $contextTermMap/entry
			where not(string($entry/@xml:id) eq $thisId)
			return
				$entry )
		}
};

