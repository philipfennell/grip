xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace profile = "http://www.w3.org/TR/rdf-interfaces/Profile"
	at "/lib/rdf-interfaces/Profile.xqy";

let $profile as item() := map:map()
let $test := profile:set-term($profile, 'test', 'http://www.example.com/test/one#')
return
	map:get(profile:get-terms($profile), 'test') eq 'http://www.example.com/test/one#'
	