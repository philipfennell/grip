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
 : Request handler - maps requests to modules that implement the request's 
 : intended action.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace core = "http://www.marklogic.com/rig/core" 
		at "/framework/core.xqy";
import module namespace service = "http://www.marklogic.com/rig/service" 
		at "/framework/service.xqy";

declare namespace s = "http://www.w3.org/2009/xpath-functions/analyze-string";


(:~
 : Wrapper for the recursive function that transforms the request URI into a
 : module Namespace URI. 
 : @param $requestURI the absolute URI from the original request.
 : @param $requestPath the request path.
 : @param $uriTemplates the 'template URI that maps steps to WADL template params.
 : @param $method the HTTP request method.
 : @param $paramNames 
 : @param $requestBody 
 : @param $requestMediaType 
 : @returns an action element.
 :)
declare function local:build-action(
		$requestURI as xs:anyURI,
		$requestPath as xs:string, 
		$uriTemplates as xs:string+, 
		$method as xs:string,
		$paramNames as xs:string*,
		$requestBody as xs:string?,
		$requestMediaType as xs:string*
	)
		as element()
{
	let $action as xs:string := core:getActionName($method)
	let $match as xs:string+ := local:match-uri($requestPath, $uriTemplates)
	let $template as xs:string := subsequence($match, 1, 1)
	let $pattern as xs:string := subsequence($match, 2, 1)
	let $moduleNS as xs:string := concat($service:BASE_URI, lower-case(translate($template, '{}', '')))
	(: To keep things simple, remove any trailing '/' from module URIs. :)
	let $normalisedNS as xs:string := if (ends-with($moduleNS, '/')) then  
		substring($moduleNS, 1, (string-length($moduleNS) - 1))
	else 
		$moduleNS
		
	(: URI Template variables. :)
	let $templateVars as element()* := for $group in analyze-string($template, $pattern)//s:group
		return
			element {QName($normalisedNS, concat('resource:', translate($group/text(), '{}', '')))} {
				analyze-string($requestPath, $pattern)//s:group[@nr = $group/@nr]/text()
			}
			
	(: HTTP Request variables. :)
	let $requestParams as element()* := for $name in $paramNames
		where not($name = ('debug', '_requri', '_reqpath', '_reqext'))
		return
			element {QName($normalisedNS, concat('resource:', upper-case($name)))} {
				xdmp:get-request-field($name)
			}
	return
		element {QName($normalisedNS, concat('resource:', $action))} {
			(
				element {QName($normalisedNS, 'resource:REQUEST_URI')} {$requestURI},
				element {QName($normalisedNS, 'resource:REQUEST_PATH')} {$requestPath},
				$templateVars,
				$requestParams,
				element {QName($normalisedNS, 'resource:MEDIA_TYPE')} {$requestMediaType},
				element {QName($normalisedNS, 'resource:CONTENT')} {
					$requestBody
				}
			)
		}
};


(:~
 : Tries to match the passed URI against the known URI templates.
 : @param $uri 
 : @param $uriTemplates
 : @return The matched template and a RegExp to process it with.
 : @throws A err:REQ001 error 'Unknown URI pattern' if the request URI doesn't
 : match one of the known patterns.
 :)
declare function local:match-uri($uri, $uriTemplates) as xs:string*
{
	let $head as xs:string := subsequence($uriTemplates, 1, 1)
	let $tail as xs:string* := subsequence($uriTemplates, 2)
	let $pattern as xs:string := concat('^', replace($head, '\{\w+\}', '(.+)'), '$')
	return
		if (count($uriTemplates) gt 1) then 
			if (matches($uri, $pattern)) then
				($head, $pattern)
			else
				local:match-uri($uri, $tail)
		else
			($head, $pattern)
};


(:~
 : Invokes an XQuery Main Module based upon the passed 'action' element.
 : @param $action the 'action' element (with external variable child nodes).
 : @returns a result document element.
 :)
declare function local:dispatch($action as element()) 
		as item()? 
{
	try {
		(
			xdmp:invoke(
				concat(
					'/root',
					substring-after(namespace-uri($action), $service:BASE_URI), 
					'/', 
					local-name($action), '.xqy'
				), 
				for $externalVar in $action/* return
					(QName(namespace-uri($externalVar), local-name($externalVar)), (data($externalVar), '')[1])
			)
		)
	} catch ($error) {
		if (data($error/error:code) = 'SVC-FILOPN') then 
				core:error(
					xs:QName('err:MOD001'), 
					'Unsupported Module Invocation', 
					(:namespace-uri($action):)
					xdmp:quote($error)
				)
			else if (data($error/error:code) = 'SEC-PRIV') then
				core:error(
					xs:QName('err:MOD000'), 
					'Insufficient Security Privileges', 
					''
				)
			else
				(: Re-throw the error. :)
				core:rethrow-error($error)
	}
};


let $requestPath as xs:string := xdmp:get-request-field('_reqpath')
let $requestURI as xs:anyURI := xs:anyURI(xdmp:get-request-field('_requri'))

let $requestBody as xs:string :=
	try {
		xdmp:quote(xdmp:get-request-body('xml'))
	} catch ($error) {
		$error
	}

let $requestContentTypeHeader as xs:string? := string-join(xdmp:get-request-header('Content-Type'), ' ')

(: Action. :)
let $action as element() := 
	local:build-action(
		$requestURI, 
		$requestPath, 
		$service:URI_TEMPLATES, 
		lower-case(xdmp:get-request-method()),
		xdmp:get-request-field-names(),
		$requestBody,
		if (contains($requestContentTypeHeader, ';')) then 
			substring-before($requestContentTypeHeader, ';')
		else
			$requestContentTypeHeader
	)
let $debug := xdmp:log('[XQuery][GRIP] Request:', 'fine')
let $debug := xdmp:log(core:debug-page($action), 'fine')
let $debug := xdmp:log('[XQuery][GRIP] Action:', 'debug')
let $debug := xdmp:log($action, 'debug')

(: Use the passed content-type (when present) in preference to the Accept header. :)
let $contentType as xs:string := core:choose-content-type(xdmp:get-request-field('_reqext'), xdmp:get-request-header('Accept', $core:DEFAULT_CONTENT_TYPE))

(: Result. :)
let $response as item()? := 
	if (xdmp:get-request-field('debug') = 'request') then
		core:debug-page($action)
	else if (xdmp:get-request-field('debug') = 'action') then
		document {$action}
	else if (xdmp:get-request-field('debug') = 'instance') then
		local:dispatch($action)
	else
		core:representation(local:dispatch($action), $contentType)
let $debug := xdmp:log('[XQuery][GRIP] Response: &#10;', 'debug')
let $debug := xdmp:log($response, 'debug')
return 
	service:handle-response($response)
