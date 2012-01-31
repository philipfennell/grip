xquery version "1.0-ml" encoding "utf-8";

(:~
 : Action's variables and parameters.
 : @author	Philip A. R. Fennell
 :)

module namespace resource = "http://www.marklogic.com/grip/graphs/name";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(:~ The original, in-coming, request URI. :)
declare variable $resource:REQUEST_URI as xs:string external;
(:~ The 'path' portion of the original, in-coming, request URI. :)
declare variable $resource:REQUEST_PATH as xs:string external;

declare variable $resource:PATH as xs:string external;

(:~ SPARQL Query if passed. :)
declare variable $resource:QUERY as xs:string? external;
(:~ Request payload. :)
declare variable $resource:CONTENT as item()? external;
(:~ Request payload media-type. :)
declare variable $resource:MEDIA_TYPE as item()? external;


(: Handle params that weren't supplied when the context module was invoked. :)

declare variable $resource:query as xs:string? := 
		try {xs:string($resource:QUERY)} catch ($error) {''};
		