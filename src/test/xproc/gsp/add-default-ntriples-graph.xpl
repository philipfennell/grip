<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:test="http://www.w3.org/ns/xproc/test"
		xml:base="../../../"
		exclude-inline-prefixes="#all"
	 	version="1.0">
	
	<p:output port="result"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	<p:import href="test/resources/xproc/lib-gsp.xpl"/>
	<p:import href="test/resources/xproc/test.xpl"/>
	
	
	<gsp:add-graph name="test" uri="http://localhost:8005/test/data" 
			default="true" content-type="text/plain">
		<p:input port="source">
			<p:inline exclude-inline-prefixes="#all"><c:body content-type="text/plain"><![CDATA[_:A265d1842X3aX1351f697243X3aXX2dX7ffe <http://www.w3.org/2001/vcard-rdf/3.0#N> _:A265d1842X3aX1351f697243X3aXX2dX7ffd .
_:A265d1842X3aX1351f697243X3aXX2dX7ffe <http://www.w3.org/2001/vcard-rdf/3.0#FN> "J.K. Rowling" .
<http://example.org/book/book5> <http://purl.org/dc/elements/1.1/date> "2003-06-21"^^<xs:date> .
<http://example.org/book/book5> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book5> <http://purl.org/dc/elements/1.1/creator> "J.K. Rowling" .
<http://example.org/book/book5> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Order of the Phoenix" .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/date> "1999-07-08"^^<xs:date> .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/creator> _:A265d1842X3aX1351f697243X3aXX2dX7ffe .
<http://example.org/book/book3> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Prisoner Of Azkaban" .
<http://example.org/book/book1> <http://purl.org/dc/elements/1.1/date> "2001-11-04"^^<xs:date> .
<http://example.org/book/book1> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book1> <http://purl.org/dc/elements/1.1/creator> "J.K. Rowling" .
<http://example.org/book/book1> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Philosopher's Stone"@en-GB .
<http://example.org/book/book6> <http://purl.org/dc/elements/1.1/date> "2005-07-16"^^<xs:date> .
<http://example.org/book/book6> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book6> <http://purl.org/dc/elements/1.1/creator> "J.K. Rowling" .
<http://example.org/book/book6> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Half-Blood Prince" .
_:A265d1842X3aX1351f697243X3aXX2dX7ffd <http://www.w3.org/2001/vcard-rdf/3.0#Given> "Joanna" .
_:A265d1842X3aX1351f697243X3aXX2dX7ffd <http://www.w3.org/2001/vcard-rdf/3.0#Family> "Rowling" .
<http://example.org/book/book4> <http://purl.org/dc/elements/1.1/date> "2000-07-08"^^<xs:date> .
<http://example.org/book/book4> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book4> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Goblet of Fire" .
<http://example.org/book/book2> <http://purl.org/dc/elements/1.1/date> "1998-07-02"^^<xs:date> .
<http://example.org/book/book2> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book2> <http://purl.org/dc/elements/1.1/creator> _:A265d1842X3aX1351f697243X3aXX2dX7ffe .
<http://example.org/book/book2> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Chamber of Secrets" .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/date> "2001-07-21"^^<xs:date> .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/publisher> <http://live.dbpedia.org/page/Bloomsbury_Publishing> .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/creator> "J.K. Rowling" .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/title> "Harry Potter and the Deathly Hallows" .]]></c:body></p:inline>
		</p:input>
	</gsp:add-graph>
	
	<test:validate-with-schematron assert-valid="false">
		<p:input port="schema">
			<p:document href="test/resources/schemas/successful-response.sch"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</test:validate-with-schematron>
	
</p:declare-step>