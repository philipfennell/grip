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
 : Function library that implements the W3C's RDF Interface: Profile.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)
 



module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile";

import module namespace prefixmap = "http://www.w3.org/TR/rdf-interfaces/PrefixMap"
	at "/lib/PrefixMap.xqy";

import module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/TermMap.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";


(:~ Required Prefix Map. :)
declare private variable $profile:PREFIX_MAP as item() := 
	map:map(
		<map:map xmlns:map="http://marklogic.com/xdmp/map" 
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<map:entry>
				<map:key>owl</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2002/07/owl#</map:value>
			</map:entry>
			<map:entry>
				<map:key>rdf</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/1999/02/22-rdf-syntax-ns#</map:value>
			</map:entry>
			<map:entry>
				<map:key>rdfs</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2000/01/rdf-schema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>rdfa</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/ns/rdfa#</map:value>
			</map:entry>
			<map:entry>
				<map:key>xhv</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/1999/xhtml/vocab#</map:value>
			</map:entry>
			<map:entry>
				<map:key>xml</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/XML/1998/namespace</map:value>
			</map:entry>
			<map:entry>
				<map:key>xsd</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>xs</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
		</map:map>
	);


(:~ XML Schema Term Map. :)
declare private variable $profile:TERM_MAP as item() := 
	map:map(
		<map:map xmlns:map="http://marklogic.com/xdmp/map" 
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<map:entry>
				<map:key>string</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>boolean</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>dateTime</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>date</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>time</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>int</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>double</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>float</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>decimal</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>positiveInteger</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>integer</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>nonPositiveInteger</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>negativeInteger</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>long</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>int</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>short</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>byte</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>nonNegativeInteger</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>unsignedLong</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>unsignedInt</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>unsignedShort</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>unsignedByte</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
			<map:entry>
				<map:key>positiveInteger</map:key>
				<map:value xsi:type="xs:string">http://www.w3.org/2001/XMLSchema#</map:value>
			</map:entry>
		</map:map>
	);




(:~
 : Gets the Profile's PrefixMap.
 : @param $contextProfile 
 : @return PrefixMap
 :)
declare function profile:get-prefixes($contextProfile as item()) 
	as item() 
{
	$profile:PREFIX_MAP
};


(:~
 : Gets the Profile's PrefixMap.
 : @param $contextProfile 
 : @return PrefixMap
 :)
declare function profile:get-terms($contextProfile as item()) 
	as item() 
{
	$profile:TERM_MAP
};


(:~
 : Given an Term or CURIE this method will return an IRI, or null if it cannot 
 : be resolved. If toResolve contains a : (colon) then this function returns the 
 : result of calling prefixmap:resolve(toResolve) otherwise this method returns 
 : the result of calling termmap.resolve(toResolve).
 : @param $contextProfile 
 : @param $toResolve A string Term or CURIE.
 : @return an IRI as an xs:string.
 :)
declare function profile:resolve($contextProfile as item(), 
		$toResolve as xs:string) 
	as xs:string?
{
	if (contains($toResolve, ':')) then 
		prefixmap:resolve(profile:get-prefixes($contextProfile), $toResolve)
	else
		termmap:resolve(profile:get-terms($contextProfile), $toResolve)
};


(:~
 : This method sets the default prefix for use when resolving CURIEs without a 
 : prefix, for example ":me", it is identical to calling the setDefault method 
 : on prefixes.
 : @param $contextProfile 
 : @param $iri The IRI to use as the default prefix.
 : @return empty sequence.
 :)
declare function profile:set-default-prefix($contextProfile as item(), $iri as xs:string) 
	as empty-sequence() 
{
	prefixmap:set-default(profile:get-prefixes($contextProfile), $iri)
};


(:~
 : This method sets the default vocabulary for use when resolving unknown terms, 
 : it is identical to calling the setDefault method on terms.
 : @param $contextProfile 
 : @param $iri The IRI to use as the default vocabulary.
 : @return empty sequence.
 :)
declare function profile:set-default-vocabulary($contextProfile as item(), $iri as xs:string) 
	as empty-sequence() 
{
	termmap:set-default(profile:get-terms($contextProfile), $iri)
};


(:~
 : This method associates an IRI with a prefix, it is identical to calling the 
 : set method on prefixes.
 : @param $contextProfile
 : @param $prefix The prefix must not contain any whitespace.
 : @param $iri The IRI to associate with the prefix.
 : @return empty sequence.
 :)
declare function profile:set-prefix($contextProfile as item(), 
		$prefix as xs:string, $iri as xs:string) 
	as empty-sequence()
{
	prefixmap:set(profile:get-prefixes($contextProfile), $prefix, $iri)
};


(:~
 : This method associates an IRI with a term, it is identical to calling the 
 : set method on term.
 : @param $contextProfile
 : @param $term The term to set, must not contain any whitespace or the : 
 : (single-colon) character
 : @param $iri The IRI to associate with the term.
 : @return empty sequence.
 :)
declare function profile:set-term($contextProfile as item(), 
		$term as xs:string, $iri as xs:string) 
	as empty-sequence()
{
	termmap:set(profile:get-terms($contextProfile), $term, $iri)
};

