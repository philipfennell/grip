xquery version "1.0-ml" encoding "utf-8";

(:~
 : Implements the 'head' action for the identified resource.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";
      
import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";
		
import module namespace resource = "http://www.marklogic.com/grip/graphs" 
		at "/root/graphs/resource.xqy"; 


()