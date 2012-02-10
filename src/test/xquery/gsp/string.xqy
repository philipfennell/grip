xquery version "1.0-ml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";

let $source as item()* := 
('Ramifications of',
  <apply xmlns="http://www.w3.org/TR/REC-mathml">
    <power/>
    <apply>
      <plus/>
      <ci>a</ci>
      <ci>b</ci>
    </apply>
    <cn>2</cn>
  </apply>,
    'to World Peace')
return
  gsp:string($source)
