<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:http="http://www.w3.org/Protocols/rfc2616"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/ns/xproc/test"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		xml:base="../../../"
		exclude-inline-prefixes="#all"
	 	version="1.0">
	
	<p:input port="source">
		<p:document href="test/resources/trix.xml"/>
	</p:input>
	<p:output port="result"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	<p:import href="test/resources/xproc/test.xpl"/>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="main/xquery/app/resources/xslt/application-rdf-xml/core.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	<!--
	<p:validate-with-xml-schema assert-valid="true">
		<p:input port="schema">
			<p:document href="test/resources/schemas/rdf.xsd"/>
		</p:input>
	</p:validate-with-xml-schema>
	-->
</p:declare-step>