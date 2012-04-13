xquery version "1.0-ml" encoding "utf-8";

(:
 : Action's variables and parameters.
 : @author	Philip A. R. Fennell
 :)

module namespace resource = "http://www.marklogic.com/grip/graphs";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(:~ The original, in-coming, request URI. :)
declare variable $resource:REQUEST_URI as xs:string external;

(:~ The 'path' portion of the original, in-coming, request URI. :)
declare variable $resource:REQUEST_PATH as xs:string external;

(:~ SPARQL Query if passed. :)
declare variable $resource:QUERY as xs:string? external;

(:~ Default graph? :)
declare variable $resource:DEFAULT as xs:string? external;

(:~ Explicit graph URI. :)
declare variable $resource:GRAPH as xs:string? external;

(:~ Request payload. :)
declare variable $resource:CONTENT as item()? external;

(:~ Request Slug header - a suggested name/suffix for the new graph URI. :)
declare variable $resource:SLUG as xs:string? external;

(:~ Request payload media-type. :)
declare variable $resource:MEDIA_TYPE as xs:string? external;


(: Handle params that weren't supplied when the context module was invoked. :)

declare variable $resource:query as xs:string? := 
		try {xs:string($resource:QUERY)} catch ($error) {''};

(: In the case of boolean params, if they're there but have no value then they 
 : to be regarded as being true. :)
declare variable $resource:default as xs:boolean? := 
		try {if ($resource:DEFAULT eq '') then true() else xs:boolean($resource:DEFAULT)} catch ($error) {false()};

declare variable $resource:graph as xs:string? := 
		try {xs:string($resource:GRAPH)} catch ($error) {''};

