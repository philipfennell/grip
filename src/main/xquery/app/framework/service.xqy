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
declare namespace xf 		= "http://www.w3.org/2002/xforms";
declare namespace xhtml 	= "http://www.w3.org/1999/xhtml";
declare namespace atom 		= "http://www.w3.org/2005/Atom";
declare namespace app 		= "http://www.w3.org/2007/app"; 
declare namespace rdf 		= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"; 
declare namespace trix 		= "http://www.w3.org/2004/03/trix/trix-1/"; 
declare namespace wadl 		= "http://wadl.dev.java.net/2009/02"; 

declare variable $service:MIME_TYPES as document-node() := 
		xdmp:document-get('Data/mimetypes.xml');
declare variable $service:DESCRIPTION as document-node() := 
		xdmp:document-get(concat($core:APP_PATH, 'root/service.xml'));
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
	 : Given that element() response that reaches this far has not, by 
	 : definition, failed so the response should otherwise be 200 (Ok) unless 
	 : nothing was returned which should then be marked as 204 (No Content).
	 :)
	typeswitch ($response) 
		case xs:anyURI 
		return 
			(xdmp:set-response-code(201, 'Created'),
			xdmp:add-response-header('Location', $response))
		case element() 
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
declare function service:handle-response($response as item()?) 
		as item()?
{
	(
		(: Need to update this to get the element/mime-type mappings from the service description. :)
		typeswitch ($response)
			case xs:anyURI return 
					service:set-response($response, '')
			case element(app:service) return
					service:set-response($response, 'application/atomsvc+xml')
			case element(app:categories) return
					service:set-response($response, 'application/atomcat+xml')
			case element(atom:feed) return
					service:set-response($response, 'application/atom+xml')
			case element(rdf:RDF) return
					service:set-response($response, 'application/rdf+xml')
			case element(trix:trix) return
					service:set-response($response, 'application/xml')
			case element(wadl:application) return
					service:set-response($response, 'application/vnd.sun.wadl+xml')
			case element(xhtml:html) return 
					if (exists($response//xf:model)) then
						service:set-response($response, 'application/xml')
					else
						(
							'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
							service:set-response($response/*, 'text/html')
						)
			default return
				service:set-response($response, 'text/plain')
	)
}; 