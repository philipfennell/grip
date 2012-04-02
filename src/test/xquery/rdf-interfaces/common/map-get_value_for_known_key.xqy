xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/Common.xqy";

let $map as element() := 
<map>
	<entry xml:id="owl">http://www.w3.org/2002/07/owl#</entry>
</map>
return
	common:map-get($map, 'owl') eq 'http://www.w3.org/2002/07/owl#'
