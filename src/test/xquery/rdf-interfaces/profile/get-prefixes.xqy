xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/Profile.xqy";

map:keys(profile:get-prefixes())