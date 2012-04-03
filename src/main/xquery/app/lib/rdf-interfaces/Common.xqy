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

module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";




(:~
 : Recursively inserts entries into the context Map. If override is 
 : true() then replace entries with new ones with the same key. 
 : @param $contextMap
 : @param $entries A sequence of entries.
 : @param $override If true() then conflicting keys will be overridden by 
 : those specified on the Map being imported, by default imported 
 : entries augment the existing set.
 : @return Map.
 :)
declare function common:map-add($contextMap as element(), 
		$entries as element(entry)*, $override as xs:boolean) 
	as element()
{
	let $head as element(entry)? := subsequence($entries, 1, 1)
	let $tail as element(entry)* := subsequence($entries, 2)
	return
		if (exists($head)) then 
			common:map-add(
				( if ($head/@xml:id = $contextMap/entry/@xml:id) then 
					if ($override eq true()) then 
						common:map-set($contextMap, string($head/@xml:id), string($head))
					else
						$contextMap
				else
					common:map-set($contextMap, string($head/@xml:id), string($head)) ), 
				$tail, $override)
		else
			$contextMap
};


(:~
 : Set the value for the passed key in the context Map.
 : @param $contextMap
 : @param $key 
 : @param $value 
 : @return element()
 :)
declare function common:map-set($contextMap as element(), $key as xs:string, 
		$value as xs:string) 
	as element()
{
	element {xs:QName(name($contextMap))} {
		( $contextMap/@*,
		<entry xml:id="{$key}">{$value}</entry>,
		( for $entry in $contextMap/entry
		where not(string($entry/@xml:id) eq $key)
		return
			$entry ) )
	}
};


(:~
 : Get the value from the passed key.
 : @param $contextMap
 : @param $key
 : @return xs:string
 :)
declare function common:map-get($contextMap as element(), $key as xs:string) 
	as xs:string?
{
	common:map-get-entry($contextMap, $key)
};


(:~
 : Get the map entry from the passed key.
 : @param $contextMap
 : @param $key
 : @return element(entry)
 :)
declare function common:map-get-entry($contextMap as element(), $key as xs:string) 
	as element(entry)?
{
	let $context := 
		(: 
		 : If the context node is not in a document, wrap it in one because the 
		 : id() function need a document root. 
		 :)
		if (exists($contextMap/..)) then $contextMap else document {$contextMap}
	return
		subsequence(id((if ($key eq '') then '_' else $key), $context), 1, 1)
};


(:~
 : Remove the entry from the context Map.
 : @param $contextMap
 : @param $key 
 : @return the passed map.
 :)
declare function common:map-remove($contextMap as element(), $key as xs:string) 
	as element()
{
	let $thisId as xs:string := if ($key eq '') then '_' else $key
	return
		element {xs:QName(name($contextMap))} {
			( $contextMap/@*,
			for $entry in $contextMap/entry
			where not(string($entry/@xml:id) eq $thisId)
			return
				$entry )
		}
};