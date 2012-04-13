xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace nt = "http://www.w3.org/ns/formats/N-Triples";

import module namespace ntdp = "http://www.w3.org/TR/rdf-interfaces/NTriplesDataParser"
	at "/lib/rdf-interfaces/NTriplesDataParser.xqy";


let $doc as element(nt:RDF) := 
<nt:RDF><![CDATA[
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Prisoner Of Azkaban"@en-GB .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/creator> _:A0 .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/date> "1999-07-08"^^<http://www.w3.org/2001/XMLSchema#date> .
_:A0 <http://www.w3.org/2001/vcard-rdf/3.0#FN> "J.K. Rowling" .
]]></nt:RDF>
return
	ntdp:parse(string($doc), (), (), (), ())