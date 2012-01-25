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
 : Core function library for the application framework.
 : @author	Philip A. R. Fennell
 :)

module namespace core = "http://www.marklogic.com/rig/core";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace admin = "http://marklogic.com/xdmp/admin" 
		at "/MarkLogic/admin.xqy";
import module namespace service = "http://www.marklogic.com/rig/service" 
		at "/framework/service.xqy";

declare namespace err = 		"http://www.marklogic.com/rig/error";
declare namespace error = 		"http://marklogic.com/xdmp/error";
declare namespace xhtml = 		"http://www.w3.org/1999/xhtml";

declare variable $core:APP_PATH as xs:string := 'C:\Users\pfennell\Projects\SemanticWeb\grip\src\main\xquery\app\';
declare variable $core:BASE_URI as xs:string := 'http://www.marklogic.com/rig';
(:declare variable $core:COMPONENT_PATH as xs:string := '/system-files/presentation/components';:)
declare variable $core:CONTENT_PATH as xs:string := '/content';
declare variable $core:DEFAULT_CONTENT_TYPE as xs:string := 'application/rdf+xml';

declare variable $core:UUID_VERSION as xs:unsignedLong := 3; 
declare variable $core:UUID_RESERVED as xs:unsignedLong := 8;


(:~
 : Takes the incoming HTTP request and forwards it on to the handler.
 : @param	$handlerURI
 : @return	The handler URI.
 :)
declare function core:handle-request($protocol as xs:string, $host as xs:string, 
		$path as xs:string, $params as xs:string*, $handlerURI as xs:string) 
				as xs:string 
{
	let $requestPath as xs:string := 
		if (contains($path, '.')) then
			substring-before($path, '.')
		else if (ends-with($path, '/') and 
				string-length($path) gt 1) then 
			substring($path, 1, (string-length($path) - 1))
		else
			$path
	let $fileExtension as xs:string? := 
		if (contains($path, '.')) then
			(
				(: The presence of query params in the request must be dealt with
				   when extracting the file extension from the request. :)
				if (contains($path, '?')) then 
					substring-after(substring-before($path, '?'), '.')
				else
					substring-after($path, '.')
			)
		else
			()
	let $requestParams as xs:string := 
		string-join($params, '&amp;')
	let $requestURI as xs:string := concat($protocol, '://', 
			$host, $requestPath, 
					(if (string-length($requestParams) gt 0) then 
							'?' else ''), $requestParams)		
	return 
		concat($handlerURI, '?', '_requri=', encode-for-uri($requestURI), 
				'&amp;', '_reqpath=', encode-for-uri($requestPath), '&amp;', 
						'_reqext=', $fileExtension, 
								(if (string-length($requestParams) gt 0) then 
										'&amp;' else ''), $requestParams)
};


(:~
 : Looks at the current appserver to see who the default user is. If it is 
 : 'application-level' then redirect to the log-on action 
 : otherwise assume that basic or digest authentication has handled the 
 : credentials and carry on with the request.
 : @param $requestURI the incoming request URI.
 : @return a request URI.
 :)
(:declare function core:check-authentication-option($requestURI as xs:string) as xs:string 
{
	(
		if (admin:appserver-get-default-user(admin:get-configuration(), xdmp:server()) = xdmp:user('eoi-admin')) then  
			(
				if (usermodule:check-login()) then 
					xdmp:get-request-field('requri')
				else
					'/users/logon'
			)
		else
			xdmp:get-request-field('requri')
		)
}; :)


(:~
 : Maps the HTTP method name to an 'action' name.
 : @param	$method 
 : @return	The string value of the action name.
 :)
declare function core:getActionName($method as xs:string) as xs:string 
{
	let $methods as element() := 
		<methods>
			<options>options</options>
			<head>metainfo</head>
			<post>create</post>
			<get>retrieve</get>
			<put>update</put>
			<!-- <patch>patch</patch> -->
			<delete>delete</delete>
		</methods>
	return 
		data($methods/element()[local-name() = $method])
}; 


(:~
 : Wraps the passed element in a 'result' container and adds a src attribute
 : which takes the URI of the return resource as its value as well as the passed
 : metadata attribute sequence.
 : @param $result	
 : @param $baseURI	
 : @param $metadata	
 : @return The result wrapper with additional metadata attributes.
 :)
declare function core:wrap-result($result as element()+, $baseURI as xs:string,
	$metadata as attribute()*) 
		as element(result)
{
	let $wrapper as element() := core:wrap-result($result, $baseURI)
	return
		element {name($wrapper)} {
			(
				$wrapper/@*,
				$metadata,
				$wrapper/*
			)
		}
}; 


(:~
 : Wraps the passed element in a 'result' container and adds a src attribute
 : which takes the URI of the return resource as its value.
 : @param $result	
 : @param $baseURI	
 : @return The result wrapper that includes a src URI attribute.
 :)
declare function core:wrap-result($result as element()+, $baseURI as xs:string) 
		as element(result)
{
	<result src="{$baseURI}">{$result}</result>
};


(:~
 : Throws an XQuery error.
 : @param $name			
 : @param $description	
 : @param $data		
 :)
declare function core:error($name as xs:QName, $description as xs:string, $data as item()?)
{
	error($name, $description, $data)
};


(:~
 : Rethrows an XQuery error.
 : @param $error	
 :)
declare function core:rethrow-error($error as element(error:error))
{
	let $debug := xdmp:log('[XQuery][RIG] Exception:', 'debug')
	let $debug := xdmp:log($error, 'debug')
	return
		core:error(
			xs:QName(if (string-length($error/error:name) gt 0) then $error/error:name else 'err:UNKNOWN'), 
			$error/error:code, 
			concat(string($error/error:format-string[1]), ' -- in file -- ', 
					string($error/error:stack/error:frame[1]/error:uri[1]), ', -- at line: ',
							string($error/error:stack/error:frame[1]/error:line[1])))
};


(:~
 :
 :)
declare function core:debug-page($moduleElement as element()) 
		as document-node()
{ 
	let $moduleNamespaceURI as xs:string := namespace-uri($moduleElement)
	let $moduleURI as xs:string := concat(namespace-uri($moduleElement), '/', 
			local-name($moduleElement), '.xqy')
	return
document {<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    	<title>Handler Debug</title>
    </head>
    <body>
    	<h1>EOI Request Handler Debug</h1>
    	<p>Module Namespace URI: &lt;{$moduleNamespaceURI}&gt;</p>
    	<p>Module URI: &lt;{$moduleURI}&gt;</p>
    	<p>Module External Variables: </p>
    	<ul>{
    		for $ext in $moduleElement/* return
    			<li>{name($ext)} = {data($ext)}</li>
    	}</ul>
    	<p>Content-Type: '{core:choose-content-type(xdmp:get-request-field('ext'), xdmp:get-request-header('Accept'))}'</p>
    	<p>Request URI: &lt;{xdmp:get-request-field('requri')}&gt;</p>
    	<p>Request Method: {xdmp:get-request-method()}</p>
    	<p>Request Params: </p>
    	<ul>{
    		for $paramName in xdmp:get-request-field-names() return 
    			<li>{$paramName} = '{xdmp:get-request-field($paramName)}'</li>
    	}</ul>
    	<p>Request Headers: </p>
    	<ul>{
    		for $headerName in xdmp:get-request-header-names() return 
    			<li>{$headerName} = '{xdmp:get-request-header($headerName)}'</li>
    	}</ul>
    	<p>Session Fields: </p>
    	<ul>{
    		for $fieldName in xdmp:get-session-field-names() return 
    			<li>{$fieldName} = '{xdmp:get-session-field($fieldName)}'</li>
    	}</ul>
    	<p>Request Body</p>
    	<pre>
			'Not Implemented.'
    	</pre>
    </body>
</html>}
};


(:~
 : Given an accept header and a file extension, select the extension over the
 : accept header.
 :)
declare function core:choose-content-type($ext as xs:string?, $accept as xs:string?) 
	as xs:string 
{
	if ($ext) then 
		service:extensionToContentType($ext)
	else
		core:preferred-content-type($accept)
}; 


(:~
 : Returns the 'preferred' content type from the passed Accept header string.
 : FireFoxtext/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
 :)
declare function core:preferred-content-type($accept as xs:string) 
		as xs:string 
{
	let $preferredContentTypes as xs:string* := (
			for $mtq in tokenize($accept, ',')
			let $mt as xs:string := normalize-space(subsequence(tokenize($mtq, ';'), 1, 1))
			let $q as xs:double := number(substring-after((subsequence(tokenize($mtq, ';'), 2, 1), 'q=1.0')[1], '='))
			order by $q descending
			return
				$mt
		)
	return
		if (count($preferredContentTypes) gt 1) then 
			if ($core:DEFAULT_CONTENT_TYPE = $preferredContentTypes) then
				$core:DEFAULT_CONTENT_TYPE
			else if ('*/*' = $preferredContentTypes) then
				$core:DEFAULT_CONTENT_TYPE
			else
				subsequence($preferredContentTypes, 1, 1)
		else if ('*/*' = $preferredContentTypes) then
			$core:DEFAULT_CONTENT_TYPE
		else
			($preferredContentTypes, 'application/xml')[1]
}; 	


(:~
 : Returns a representation of the instance document based upon the request's 
 : ACCEPT header and the document's root element.
 : @param $instance 
 : @param $contentType
 : @return 
 :)
declare function core:representation($instance as item()?, $contentType as xs:string) 
		as item()?
{
	let $info := xdmp:log(concat('[XQuery][GRIP] Generating representation for: ', $contentType), 'info')
	let $transformURI as xs:string := fn:concat('../resources/xslt/', fn:translate($contentType, '/-+.', '----'), '/core.xsl')
	let $debug := xdmp:log(concat('[XQuery][GRIP] Invoking transform: ', $transformURI), 'debug')
	return
		typeswitch ($instance) 
			case $item as xs:anyURI 
			return 
				$item
			case $item as element() 
			return
				try {
					xdmp:xslt-invoke($transformURI, $instance)/*
				} catch ($error) {
					(: If the transform cannot be found then throw an 'Unacceptable Error'... :)
					if (data($error/error:code) = ('SVC-FILOPN', 'XSLT-MSGTERMINATE')) then 
						core:error(
							xs:QName('err:REP001'), 
							concat('No representation available for: ', $contentType), 
							$transformURI
						)
					(: ...otherwise re-throw the error you've been given. :)
					else 
						error(xs:QName('error'), 'Internal Error', $error) 
				}
			default 
			return 
				()
};


(:~
 : Calculate the UUID and set the UUID property on the file.
 :
 : The layout of a UUID is as follows. 0 1 2 3 0 1 2 3 4 5 6 7 8 9 a b c d e f 0 1 2 3 4 5 6 7 8 9 a b c d e f +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ | time_low | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ | time_mid | time_hi |version| +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |clk_seq_hi |res| clk_seq_low | node (0-1) | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ | node (2-5) | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 0 1 2 3 4 5 6 7 8 9 a b c d e f 0 1 2 3 4 5 6 7 8 9 a b c d e f
 : 
 : This implements version 3 of the UUID specification. 
 : The timestamp is a 60-bit value. 
 : The clock sequence is a 14 bit value. 
 : The node is a 48-bit name value. 
 :) 
declare function core:generate-uuid($uri as xs:string) 
		as xs:string 
{ 
	core:generate-uuid($uri, xdmp:host-name(xdmp:host())) 
};

declare function core:generate-uuid($uri as xs:string, $namespace as xs:string) 
		as xs:string 
{ 
	(: calculate md5 with a dateTime for our random values :) 
	let $hash := xdmp:md5(concat($uri, xs:string(current-dateTime()), $namespace)) 
	return 
		concat(
			substring( $hash, 1, 15 ), 
			(: set version bits :) xdmp:integer-to-hex($core:UUID_VERSION), 
			(: set reserved bits :) substring( $hash, 17, 1 ), 
			xdmp:integer-to-hex((xdmp:hex-to-integer(substring($hash, 18, 1)) idiv 4) + $core:UUID_RESERVED), 
			substring( $hash, 19, 14 ) 
		)
}; 