xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/2004/03/trix/trix-1/";

declare namespace trix = "http://www.w3.org/2004/03/trix/trix-1/";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/Profile.xqy";

let $profile as item() := map:map()
let $test := profile:set-term($profile, 'test', 'http://www.example.com/test/one#')
return
	map:get(profile:get-terms($profile), 'test') eq 'http://www.example.com/test/one#'
	