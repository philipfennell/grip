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
		xmlns:ex="http://example.org/stuff/1.0/">
	<rdf:Description rdf:about="http://example.org/basket">
		<ex:hasFruit rdf:parseType="Collection">
			<rdf:Description rdf:about="http://example.org/banana"/>
			<rdf:Description rdf:about="http://example.org/apple"/>
			<rdf:Description rdf:about="http://example.org/pear"/>
		</ex:hasFruit>
	</rdf:Description>
</rdf:RDF>
			</p:inline>
		</p:input>
	</gsp:add-graph>
	
	<!--<test:validate-with-schematron assert-valid="true">
		<p:input port="schema">
			<p:document href="test/resources/schemas/error-response.sch"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</test:validate-with-schematron>-->
	
</p:declare-step>