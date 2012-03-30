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
	at "/lib/rdf-interfaces/PrefixMap.xqy";

import module namespace termmap = "http://www.w3.org/TR/rdf-interfaces/TermMap"
	at "/lib/rdf-interfaces/TermMap.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";




(:~
 : Gets the Profile's PrefixMap.
 : @param $contextProfile 
 : @return PrefixMap
 :)
declare function profile:get-prefixes($contextProfile as element(profile)) 
	as element(prefix-map)
{
	$contextProfile/prefix-map
};


(:~
 : Gets the Profile's TermMap.
 : @param $contextProfile 
 : @return TermMap
 :)
declare function profile:get-terms($contextProfile as element(profile)) 
	as item() 
{
	$contextProfile/term-map
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

