<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
		xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:error="http://marklogic.com/xdmp/error"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:http="http://www.w3.org/Protocols/rfc2616"
		xmlns:nt="http://www.w3.org/ns/formats/N-Triples"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		exclude-inline-prefixes="#all"
		name="rdf-test-cases">
	
	<p:documentation>RDF Negative Parser Test Cases (Latest Approved) round-tripped through GRIP.</p:documentation>
	<p:input port="source">
		<p:document href="latest_Approved/Manifest.rdf"/>
	</p:input>
	<p:output port="result"/>
	<p:option name="TEST_URI" required="false" select="''"/>
	
	<p:import href="../../resources/xproc/lib-gsp.xpl"/>
	<p:import href="../../resources/xproc/library-1.0.xpl"/>
	<p:import href="lib-test.xpl"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	
	
	
	<!-- Iterate over the tests in the manifest document. ================== -->
	
	<p:for-each>
		<p:iteration-source select="/rdf:RDF/test:NegativeParserTest[test:status eq 'APPROVED']"/>
		
		
		<!-- Identify required tests and resolve URIs. ====================  -->
		
		<p:variable name="testURI" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		<p:variable name="testBaseURI" select="string-join((reverse(subsequence(reverse(tokenize($testURI, '/')), 3)), ''), '/')"/>
		<p:variable name="testName" select="substring-before(substring-after($testURI, $testBaseURI), '.rdf')"/>
		
		<test:resolve-uris name="test-case"/>
		
		<test:actual-result name="actual" service-uri="http://localhost:8005/graphs">
			<p:documentation>Get and process the test.</p:documentation>
			<p:with-option name="test-uri" select="$testURI"/>
		</test:actual-result>
		
		<p:choose>
			<p:when test="/http:response/@status eq '500'">
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:test success="true">Unknown</c:test></p:inline>
					</p:input>
				</p:identity>
				<p:string-replace match="/c:test/text()">
					<p:with-option name="replace" select="concat('&quot;', //error:code, '&quot;')">
						<p:pipe port="result" step="actual"/>
					</p:with-option>
				</p:string-replace>
			</p:when>
			<p:otherwise>
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:test success="false">Unknown</c:test></p:inline>
					</p:input>
				</p:identity>
			</p:otherwise>
		</p:choose>
		<p:add-attribute match="/c:*" attribute-name="uri">
			<p:with-option name="attribute-value" select="$testName"/>
		</p:add-attribute>
	</p:for-each>
	
	<p:wrap-sequence wrapper="c:results"/>
</p:declare-step>