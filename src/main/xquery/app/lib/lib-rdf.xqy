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
 : Function library for working with RDF/XML Graph documents.
 : @see http://www.hpl.hp.com/techreports/2004/HPL-2004-56.pdf
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";


(:~
 : Transform the RDF/XML to a 'normalised', (canonical if you will, form.
 : @param $rdf the graph to be inserted.
 : @param $baseURI the graph's Base URI.
 : @return element(rdf:RDF)
 :)
declare function rdf:normalise-rdf-xml($rdf as element(), $baseURI as xs:string)
	as element(rdf:RDF)
{
	let $params := map:map()
	let $_put := map:put($params, 'BASE_URI', $baseURI)
	return
		xdmp:xslt-invoke('/resources/xslt/lib/normalise-rdf-xml.xsl', document {$rdf}, $params)/*
};
