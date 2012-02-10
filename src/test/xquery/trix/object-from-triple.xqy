xquery version "1.0-ml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/"
	at "/lib/lib-trix.xqy";

let $source as element() := 
    <triple xmlns="http://www.w3.org/2004/03/trix/trix-1/">
            <uri>http://mycorp.example.com/papers/NobelPaper1</uri>
            <uri>http://purl.org/metadata/dublin_core#Title</uri>
            <typedLiteral datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral">
    Ramifications of
       <apply xmlns="http://www.w3.org/TR/REC-mathml">
                  <power/>
                  <apply>
                     <plus/>
                     <ci>a</ci>
                     <ci>b</ci>
                  </apply>
                  <cn>2</cn>
               </apply>
    to World Peace
  </typedLiteral>
         </triple>
return
    trix:object-from-triple($source)