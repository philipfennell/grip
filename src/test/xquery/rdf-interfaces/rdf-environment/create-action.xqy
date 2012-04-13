xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace rdfenv = "http://www.w3.org/TR/rdf-interfaces/RDFEnvironment"
	at "/lib/rdf-interfaces/RDFEnvironment.xqy";


let $uri as xs:string := '/test?default'
return
	rdfenv:create-action($rdfenv:DEFAULT_ENVIRONMENT, 
		<filter><![CDATA[
(: Default action that is always applied to the context Triple. :)
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
declare variable $rdfi:triple as element() external;

true()
	]]></filter>,
		<callback>
import module namespace impl = "http://www.w3.org/TR/rdf-interfaces/Implementation"
	at "/lib/rdf-interfaces/Implementation.xqy";	
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare variable $rdfi:triple as element() external;
declare variable $rdfi:graph as element() external;

impl:add-triple('{$uri}', $rdfi:triple)
	</callback>
	) instance of element(action)

