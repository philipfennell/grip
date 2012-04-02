xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/rdf-interfaces/Profile.xqy";


let $profile as element(profile) := 
<profile>
	<prefix-map/>
	<term-map>
		<entry xml:id="string">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="boolean">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="dateTime">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="date">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="time">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="int">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="double">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="float">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="decimal">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="positiveInteger">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="integer">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="nonPositiveInteger">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="negativeInteger">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="long">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="int">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="short">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="byte">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="nonNegativeInteger">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="unsignedLong">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="unsignedInt">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="unsignedShort">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="unsignedByte">http://www.w3.org/2001/XMLSchema#</entry>
		<entry xml:id="positiveInteger">http://www.w3.org/2001/XMLSchema#</entry>
	</term-map>
</profile>
return
profile:resolve($profile, 'integer') eq 'http://www.w3.org/2001/XMLSchema#integer'
