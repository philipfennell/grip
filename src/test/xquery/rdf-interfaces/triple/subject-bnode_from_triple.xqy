xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/Triple.xqy";

let $triple as element() := 
<triple>
	<id>A0</id>
	<uri>http://www.w3.org/2001/vcard-rdf/3.0#FN</uri>
	<plainLiteral>J.K. Rowling</plainLiteral>
</triple>

return
	deep-equal(triple:subject($triple), <id>A0</id>)