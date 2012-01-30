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
			<p:inline exclude-inline-prefixes="#all"><c:body content-type="text/plain"><![CDATA[<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/abstract> "Some text that is \"quoted\" and should remain so." .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/abstract> "Some text that is\ttab\tdelimited." .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/abstract> "Some text that has an escaped \\ back-slash." .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/abstract> "Some text with a new-line\nand a carriage-return\r." .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/abstract> "Some sepecial character like \uFF77 or \u10FFFF." .
<http://example.org/book/book7> <http://purl.org/dc/elements/1.1/abstract> "All \"together\" again \\ and \t again and \n again and \r again.." .]]></c:body></p:inline>
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