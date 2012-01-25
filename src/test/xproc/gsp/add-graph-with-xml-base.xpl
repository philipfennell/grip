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
			default="true" content-type="application-rdf+xml">
		<p:input port="source">
			<p:inline exclude-inline-prefixes="#all">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xml:base="http://www.example.com/test">
	<rdf:Description rdf:about="http://example.org/book/book7">
		<dc:title>Harry Potter and the Deathly Hallows</dc:title>
		<dc:creator>J.K. Rowling</dc:creator>
		<dc:publisher rdf:resource="http://live.dbpedia.org/page/Bloomsbury_Publishing"/>
		<dc:date>2001-07-21</dc:date>
	</rdf:Description>
</rdf:RDF>
			</p:inline>
		</p:input>
	</gsp:add-graph>
	
	<test:validate-with-schematron assert-valid="true">
		<p:input port="schema">
			<p:document href="test/resources/schemas/error-response.sch"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</test:validate-with-schematron>
	
</p:declare-step>