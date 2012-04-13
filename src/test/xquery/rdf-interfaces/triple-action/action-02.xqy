xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace action = "http://www.w3.org/TR/rdf-interfaces/TripleAction"
	at "/lib/rdf-interfaces/TripleAction.xqy";


(:  :)
declare function local:has-title($rdfi:triple as element(triple))
		as xs:boolean
{
	string($rdfi:triple/*[2]) eq 'http://purl.org/dc/elements/1.1/title'
};


let $graph as element() := 
<graph xmlns="http://www.w3.org/TR/rdf-interfaces" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#"
		xml:base="/graph?default">
	<uri>/graph?default</uri>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Prisoner Of Azkaban</plainLiteral>
	</triple>
</graph>
let $uri as xs:string := '/test?default'
let $action as element() := 
<action>
	<filter><![CDATA[
(: Default action that is always applied to the context Triple. :)
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
declare variable $rdfi:triple as element() external;

true()
	]]></filter>
	<callback>
import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";	
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare variable $rdfi:triple as element() external;
declare variable $rdfi:graph as element() external;

impl:add-triple('{$uri}', $rdfi:triple)
	</callback>
</action>
return
	action:run($action, $graph/triple, $graph)
