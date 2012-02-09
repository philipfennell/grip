<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
		xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:http="http://www.w3.org/Protocols/rfc2616"
		xmlns:nt="http://www.w3.org/ns/formats/N-Triples"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		exclude-inline-prefixes="#all"
		name="rdf-test-cases">
	
	<p:documentation>RDF Test Cases (Latest Approved) round-tripped through GRIP.</p:documentation>
	<p:input port="source">
		<p:document href="latest_Approved/Manifest.rdf"/>
	</p:input>
	<p:output port="result"/>
	
	<p:import href="../../resources/xproc/lib-gsp.xpl"/>
	<p:import href="../../resources/xproc/library-1.0.xpl"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	
	
	
	<!-- Iterate over the tests in the manifest document. ================== -->
	
	<p:for-each>
		<!-- <p:iteration-source select="/rdf:RDF/node()[ends-with(local-name(), 'ParserTest')][test:status eq 'APPROVED']"/> -->
		<p:iteration-source select="/rdf:RDF/test:PositiveParserTest[test:status eq 'APPROVED']"/>
		
		
		
		
		<!-- Identify required tests and resolve URIs. ====================  -->
		
		<p:variable name="testURI" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		<p:variable name="testBaseURI" select="string-join((reverse(subsequence(reverse(tokenize($testURI, '/')), 3)), ''), '/')"/>
		<p:variable name="testName" select="substring-before(substring-after($testURI, $testBaseURI), '.rdf')"/>
		
		<p:string-replace match="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about" 
				replace="substring-after(., 'http://www.w3.org/2000/10/rdf-tests/rdfcore/')"/>
		<p:make-absolute-uris base-uri="./latest_Approved/" 
				match="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		
		<p:string-replace match="/test:*/test:outputDocument/test:NT-Document/@rdf:about" 
				replace="substring-after(., 'http://www.w3.org/2000/10/rdf-tests/rdfcore/')"/>
		<p:make-absolute-uris base-uri="./latest_Approved/" 
				match="/test:*/test:outputDocument/test:NT-Document/@rdf:about"/>
		
		
		
		
		<!-- === Get and prepare the expected result. ====================== -->
		
		<p:identity name="test-case"/>
		
		<p:load name="source">
			<p:with-option name="href" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		</p:load>
		
		
		
		
		<!-- === Get and process the test. ================================= -->
		
		<gsp:add-graph name="insert" uri="http://localhost:8005/graphs" 
				content-type="application/rdf+xml">
			<p:documentation>Load the source test graph into GRIP.</p:documentation>
			<p:with-option name="graph" select="$testURI"/>
		</gsp:add-graph>
		
	</p:for-each>
	
	<p:wrap-sequence wrapper="c:results"/>
	
</p:declare-step>