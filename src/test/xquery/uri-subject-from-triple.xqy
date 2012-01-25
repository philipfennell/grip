xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/" 
		at "/lib/lib-trix.xqy";

(:  :)
trix:subject-from-triple(
	<triple xmlns="http://www.w3.org/2004/03/trix/trix-1/">
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>
	</triple>)