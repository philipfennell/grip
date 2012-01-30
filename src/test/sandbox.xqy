xquery version "1.0-ml" encoding "utf-8";

import module namespace sem = "http://marklogic.com/semantic" 
		at "lib/semantic.xqy"; 
import module namespace core = "http://www.marklogic.com/rig/core" 
		at "framework/core.xqy"; 

declare namespace dc 	= "http://purl.org/dc/elements/1.1/";
declare namespace rdf 	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare default function namespace "http://www.w3.org/2005/xpath-functions";


core:document-get('/root/service.xml')