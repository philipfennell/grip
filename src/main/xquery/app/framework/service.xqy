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
 : Service specific variables and functions.
 : @author	Philip A. R. Fennell
 :)

module namespace service = "http://www.marklogic.com/rig/service";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace core = "http://www.marklogic.com/rig/core" 
		at "/framework/core.xqy";

declare namespace mt 		= "http://marklogic.com/xdmp/mimetypes"; 
declare namespace wadl 		= "http://wadl.dev.java.net/2009/02"; 

declare variable $service:MIME_TYPES as document-node() := 
		core:document-get('/resources/config/mimetypes.xml');
declare variable $service:DESCRIPTION as document-node() := 
		core:document-get('/resources/config/service.xml');
declare variable $service:BASE_URI as xs:string := 
		$service:DESCRIPTION/wadl:application/wadl:resources/@base;
declare variable $service:URI_TEMPLATES as xs:string* := 
		$service:DESCRIPTION/wadl:application/wadl:resources/wadl:resource/@path;


(:~
 : Derive an content-type (MIME Type) from the passed file extension.
 : @param  $fileExtension file extension suffix on a request URI.
 : @return MIME Type.
 :)
declare function service:extensionToContentType($fileExtension as xs:string) 
		as xs:string?
{ 
	string(
		(
			for $mt in $service:MIME_TYPES/mt:mimetypes/mt:mimetype return 
				if ($fileExtension = tokenize($mt/mt:extensions/text(), ' ')) then 
					$mt/mt:name 
				else 
					()
		)[1]
	)
}; 


(:~
 : Sets the response content-type header and returns the response document.
 : @param $contentType the content type to be set.
 : @param $response the response document.
 : @return the response document.
 :)
declare function service:set-response($response as item()?, $contentType as xs:string) 
		as item()? 
{
	(: 
	 : The logic in here is that if the result of an action is an xs:anyURI then 
	 : it indicates the creation of a new resource which should be indicated by 
	 : 201 (Created) and the URI put in the HTTP 'Location' response header.
	 : Given that an element() response that reaches this far has not, by 
	 : definition, failed so the response should be 200 (Ok) unless 
	 : nothing was returned which should then be marked as 204 (No Content).
	 :)
	typeswitch ($response) 
		case xs:anyURI 
		return 
			(xdmp:set-response-code(201, 'Created'),
			xdmp:add-response-header('Location', $response))
		case node() 
		return
			(xdmp:set-response-content-type($contentType),
			xdmp:set-response-code(200, 'Ok'),
			$response)
		default 
		return 
			(xdmp:set-response-code(204, 'No Content'))
}; 


(:~
 : Sets the Content-Type HTTP response header.
 : @param $response	the response document.
 : @return the response document. 
 :)
declare function service:handle-response($response as item()?, $contentType as xs:string) 
		as item()?
{
	(
		typeswitch ($response)
			(: 
			 : If a URI was the result of an action then this implies a new 
			 : resource has been created. There's no entity to return.
			 :)
			case xs:anyURI 
			return 
				service:set-response($response, '')
				
			(:
			 : If a node, element() or text(), is the result of an action then 
			 : there will be an enity returned in the response so pass the 
			 : requested content type.
			 :)
			case node() 
			return
				service:set-response($response, $contentType)
				
			(: As a fallback return the response as plain text. :)
			default return
				service:set-response($response, 'text/plain')
	)
}; 