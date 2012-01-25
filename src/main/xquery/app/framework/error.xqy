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

(:
 : Application specific error handler. Maps application errors to HTTP response 
 : codes.
 : @author	Philip A. R. Fennell
 :)

declare namespace error = 'http://marklogic.com/xdmp/error';
declare namespace err = 'http://www.marklogic.com/rig/error';

declare variable $error:errors as node()* external;

(:~ Mapping response codes to standard HTTP reason phrases. :)
declare variable $reasonPhraseLUT as element() := 
	<err:lut>
		<err:phrase code="{400}">Bad Request</err:phrase>
		<err:phrase code="{401}">Unauthorised</err:phrase>
		<err:phrase code="{404}">Not Found</err:phrase>
		<err:phrase code="{405}">Method Not Allowed</err:phrase>
		<err:phrase code="{406}">Not Acceptable</err:phrase>
		<err:phrase code="{415}">Unsupported Media Type</err:phrase>
		<err:phrase code="{500}">Internal Server Error</err:phrase>
	</err:lut>;

(:~ Internally generated exception mapping to HTTP resonse codes. :)
declare variable $responseCodeLUT as element() := 
	<err:lut>
		<err:GSP001>{400}</err:GSP001>
		<err:REQ001>{400}</err:REQ001>
		<err:REQ002>{400}</err:REQ002>
		<err:TX001>{400}</err:TX001>
		<err:REQ003>{415}</err:REQ003>
		<err:ENT002>{400}</err:ENT002>
		<err:ENT003>{400}</err:ENT003>
		<err:REQ003>{401}</err:REQ003>
		<err:RES001>{404}</err:RES001>
		<err:ENT001>{404}</err:ENT001>
		<err:MOD001>{405}</err:MOD001>
		<err:REP001>{406}</err:REP001>
		<err:RES002>{500}</err:RES002>
		<err:UPD002>{500}</err:UPD002>
		<err:SYS001>{500}</err:SYS001>
	</err:lut>;

let $responseCode as xs:string? := $responseCodeLUT/*[fn:name() = ($error:errors//error:name)[1]]/text()

(:~ If there's no mapping to a code, default to 500. :)
let $statusCode as xs:integer := if ($responseCode != 'NaN' or $responseCode != '') then 
	xs:integer($responseCode)
else
	500
let $reasonPhrase as xs:string? := string($reasonPhraseLUT/err:phrase[@code eq $statusCode])
return
	(
		(: 
		 : Set the error status code and return the stack trace (XML) if it's an
		 : internal error else just return the response phrase in the body as 
		 : plain text
		 :)
		xdmp:set-response-code($statusCode, $reasonPhrase),
		if ($statusCode = 500) then 
			( xdmp:set-response-content-type("application/xml"), 
			$error:errors ) 
		else 
			( xdmp:set-response-content-type("text/plain"), 
			concat($reasonPhrase, ': ', string($error:errors//error:message[1])))
	)
