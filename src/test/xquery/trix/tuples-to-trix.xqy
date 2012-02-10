xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace gsp="http://www.w3.org/TR/sparql11-http-rdf-update/" 
		at "/lib/lib-gsp.xqy";

import module namespace trix = "http://www.w3.org/2004/03/trix/trix-1/"
	at "/lib/lib-trix.xqy";

let $graphURI as xs:string := 'http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test002.rdf'
return
	trix:tuples-to-trix(
<graph uri="{$graphURI}">
<t>
	<s>http://mycorp.example.com/papers/NobelPaper1</s>
	<p>http://purl.org/metadata/dublin_core#Creator</p>
	<o>David Hume</o><c>http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test002.rdf</c>
</t>
<t>
	<s>http://mycorp.example.com/papers/NobelPaper1</s>
	<p>http://purl.org/metadata/dublin_core#Title</p>
	<o datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral">
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
	</o>
	<c>http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-xml-literal-namespaces/test002.rdf</c>
</t>
</graph>,
		gsp:get-graph-namespace(doc($graphURI)/*))

