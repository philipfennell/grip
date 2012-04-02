xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace common = "http://www.w3.org/TR/rdf-interfaces/Common"
	at "/lib/rdf-interfaces/common.xqy";

let $map as element(map) := 
	<map>
		<entry xml:id="string">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="boolean">http://www.w3.org/2001/XMLSchema#</entry>
	</map>
let $terms as element(map) := 
	<map>
		<entry xml:id="boolean">http://www.w3.org/2012/XMLSchema#</entry>
		<entry xml:id="dateTime">http://www.w3.org/2001/XMLSchema#</entry>
	</map>
return
	common:map-get(common:map-add($map, $terms/entry, false()), 'boolean') eq 'http://www.w3.org/2001/XMLSchema#'
