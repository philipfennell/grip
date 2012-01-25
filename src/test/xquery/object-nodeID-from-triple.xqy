xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/" 
		at "/lib/lib-trix.xqy";

(:  :)
trix:object-from-triple(
	<triple xmlns="http://www.w3.org/2004/03/trix/trix-1/">
		<id>A1</id>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<id>A2</id>
	</triple>)