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

declare variable $core:DEFAULT_CONTENT_TYPE as xs:string := 'application/rdf+xml';


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
			<trace>loop-back</trace>
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
 : Generates an HTML representation of the HTTP request information.
 : @param $action the XML action fragment created from request information.
 : @return HTML document-node()
 :)
declare function core:debug-page($action as element()) 
		as document-node()
{ 
	let $moduleNamespaceURI as xs:string := namespace-uri($action)
	let $moduleURI as xs:string := concat(namespace-uri($action), '/', 
			local-name($action), '.xqy')
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
    		for $ext in $action/* return
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
 : @param $accept the HTTP Accept header string sent by the client.
 : @return xs:string
 :)
declare function core:preferred-content-type($accept as xs:string?) 
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
			($preferredContentTypes, $core:DEFAULT_CONTENT_TYPE)[1]
}; 	


(:~
 : Returns a representation of the instance document based upon the request's 
 : ACCEPT header and the document's root element.
 : @param $instance 
 : @param $contentType
 : @return item()
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
				(: Return either the child node() or text()... as it comes. :)
					xdmp:xslt-invoke($transformURI, $instance)/(*, text())[1]
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
 : Retrieve a document, realtive to the application root, whether it's on the 
 : file-system or a Modules database.
 : @param $uri the document's relative URI
 : @return document-node()
 :)
declare function core:document-get($uri as xs:string)
		as document-node()
{
	let $modulesDatabaseId as xs:unsignedLong := 
		admin:appserver-get-modules-database(
            admin:get-configuration(), 
            xdmp:server()
        )
	
	let $appRoot as xs:string := admin:appserver-get-root(admin:get-configuration(), xdmp:server())
	
	(: Remove any trailing / or \ before concatonating the appserver root URI to the document URI. :)
	let $absoluteURI as xs:string := 
		fn:concat(
			(
				if (fn:matches($appRoot, '(\\|/)$')) then 
					fn:substring($appRoot, 1, (fn:string-length($appRoot) - 1))
				else 
					$appRoot
			), 
			$uri
		)
	
	(: If the URI contains '\', ensure all file separators ar '\'. :)
	let $normalisedURI as xs:string := 
		if (fn:contains($absoluteURI, '\')) then
			fn:translate($absoluteURI, '/', '\')
		else
			$absoluteURI
	let $doc as document-node()? := 
		(: If the modules database id is 0 then it is the file system. :)
		if ($modulesDatabaseId eq 0) then
			xdmp:document-get($normalisedURI)
		else
			(: get documents from the modules database. :)
			xdmp:eval(
				fn:concat('fn:doc("', $normalisedURI, '")'),
				(),
				<options xmlns="xdmp:eval">
					<database>{$modulesDatabaseId}</database>
				</options>
			)
	return
		if (fn:exists($doc)) then
			$doc
		else
			fn:error(xs:QName('ERROR'), 'Failed to retrieve document.', $normalisedURI)
};
