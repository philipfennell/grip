xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace literal = "http://www.w3.org/TR/rdf-interfaces/Literal"
	at "/lib/Literal.xqy";

let $triple as element() := 
<triple>
	<uri>http://example.org/book/book1</uri>
	<uri>http://purl.org/dc/elements/1.1/date</uri>
	<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>
</triple>
let $expectedResult as element() := <uri>http://www.w3.org/2001/XMLSchema#date</uri>

return
	deep-equal(literal:get-datatype(<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>), $expectedResult)