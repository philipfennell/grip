xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
		at "/lib/lib-rdf.xqy";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/"
	at "/lib/lib-trix.xqy";

let $baseURI as xs:string := 'http://www.w3.org/2000/10/rdf-tests/rdfcore/rdf-charmod-literals/test001.rdf'
let $source as element() := 
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:eg="http://example.org/">
   <!-- Dürst registers himself as a creator of the Charmod WD. -->

   <rdf:Description rdf:about="http://www.w3.org/TR/2002/WD-charmod-20020220">

   <!-- The ü below is a single character #xFC in NFC
        (encoded as two UTF-8 octets #xC3 #xBC)  -->
      <eg:Creator eg:named="Dürst"/>

   </rdf:Description>
</rdf:RDF>
return
	rdf:normalise-rdf-xml($source, $baseURI)

