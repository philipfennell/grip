xquery version "1.0-ml" encoding "utf-8";

import module namespace sem = "http://marklogic.com/semantic" at 
		"lib/semantic.xqy"; 

declare namespace dc 	= "http://purl.org/dc/elements/1.1/";
declare namespace rdf 	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

sem:tuple-insert-as-property(
	'http://example.org/book/book1',						(: Subject   :)
	'dc:publisher',											(: Predicate :)
	'http://live.dbpedia.org/page/Bloomsbury_Publishing',	(: Object    :)
	'/default'												(: Context ? :)
)
