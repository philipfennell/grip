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
 : Function library that implements the W3C's RDF API.
 : @see http://www.w3.org/2010/02/rdfa/sources/rdf-api/
 : @see http://www.w3.org/TR/rdf-api/
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace rdfapi = "http://www.w3.org/TR/rdf-api/"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";
