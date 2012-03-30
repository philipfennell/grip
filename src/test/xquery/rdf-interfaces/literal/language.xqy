xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace literal = "http://www.w3.org/TR/rdf-interfaces/Literal"
	at "/lib/rdf-interfaces/Literal.xqy";

let $triple as element() := 
<triple>
	<uri>http://example.org/book/book5</uri>
	<uri>http://purl.org/dc/elements/1.1/title</uri>
	<plainLiteral>Harry Potter and the Order of the Phoenix</plainLiteral>
</triple>
let $expectedResult as xs:string := 'en-gb'

return
	literal:get-language(<plainLiteral xml:lang="en-GB">Harry Potter and the Order of the Phoenix</plainLiteral>) eq $expectedResult