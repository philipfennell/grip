<?xml version="1.0" encoding="UTF-8"?>
<p:library 
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:http="http://www.w3.org/Protocols/rfc2616"
		xmlns:nt="http://www.w3.org/ns/formats/N-Triples"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		version="1.0">
	
	<p:documentation>Step Library for RDF Parser Testing.</p:documentation>
	
	<p:declare-step type="test:resolve-uris">
		<p:documentation>Resolve test URIs.</p:documentation>
		<p:input port="source"/>
		<p:output port="result"/>
		
		<p:string-replace match="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about" 
				replace="substring-after(., 'http://www.w3.org/2000/10/rdf-tests/rdfcore/')"/>
		<p:make-absolute-uris base-uri="./latest_Approved/" 
				match="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		
		<p:string-replace match="/test:*/test:outputDocument/test:NT-Document/@rdf:about" 
				replace="substring-after(., 'http://www.w3.org/2000/10/rdf-tests/rdfcore/')"/>
		<p:make-absolute-uris base-uri="./latest_Approved/" 
				match="/test:*/test:outputDocument/test:NT-Document/@rdf:about"/>
	</p:declare-step>
	
	
	<p:declare-step type="test:expected-result">
		<p:documentation>Retrieve the expected result.</p:documentation>
		<p:input port="source" primary="true"/>
		<p:output port="result"/>
		<p:option name="test-uri" required="true"/>
		
		<p:identity name="test-case"/>
		
		<p:add-attribute match="/c:request" attribute-name="href">
			<p:input port="source">
				<p:inline exclude-inline-prefixes="#all"><c:request method="GET" override-content-type="text/plain"/></p:inline>
			</p:input>
			<p:with-option name="attribute-value" select="/test:*/test:outputDocument/test:NT-Document/@rdf:about">
				<p:pipe port="result" step="test-case"/>
			</p:with-option>
		</p:add-attribute>
		
		<p:http-request media-type="text/plain" encoding="ASCII"/>
		
		<p:rename match="/c:body" new-name="nt:RDF"/>
		
		<p:xslt>
			<p:documentation>Transform the test's expected result into TriX.</p:documentation>
			<p:input port="stylesheet">
				<p:document href="../../../main/xquery/app/resources/xslt/lib/ntriples-to-trix.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			<p:with-param name="GRAPH_URI" select="$test-uri"/>
		</p:xslt>
		<p:xslt>
			<p:documentation>Convert to Canonical TriX.</p:documentation>
			<p:input port="stylesheet">
				<p:document href="../../../main/xquery/app/resources/xslt/lib/canonical-trix.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
		</p:xslt>
	</p:declare-step>
	
	
	<p:declare-step type="test:actual-result">
		<p:documentation>Retrieve the 'actual' test result.</p:documentation>
		<p:input port="source"/>
		<p:output port="result"/>
		<p:option name="test-uri" required="true"/>
		<p:option name="service-uri" required="true"/>
		
		<p:load name="source">
			<p:with-option name="href" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		</p:load>
		
		<gsp:add-graph name="insert" 
				content-type="application/rdf+xml">
			<p:documentation>Load the source test graph into GRIP.</p:documentation>
			<p:with-option name="uri" select="$service-uri"/>
			<p:with-option name="graph" select="$test-uri"/>
		</gsp:add-graph>
		
		<cx:message>
			<p:with-option name="message" select="concat('[XProc] Insert:   ', $test-uri, ' - ', /http:response/@status)"/>
		</cx:message>
		
		<p:choose>
			<p:when test="/http:response/@status eq '500'">
				<p:identity/>
			</p:when>
			<p:otherwise>
				<gsp:retrieve-graph name="retrieve" media-type="application/xml">
					<p:documentation>Retrieve the test graph as TriX for comparison.</p:documentation>
					<p:with-option name="uri" select="$service-uri"/>
					<p:with-option name="graph" select="$test-uri"/>
				</gsp:retrieve-graph>
		
				<cx:message>
					<p:with-option name="message" select="concat('[XProc] Retrieve: ', $test-uri, ' - ', /http:response/@status)"/>
				</cx:message>
				
				<p:filter select="/http:response/http:body/trix:trix"/>
				
				<p:xslt>
					<p:documentation>Convert to Canonical TriX.</p:documentation>
					<p:input port="stylesheet">
						<p:document href="../../../main/xquery/app/resources/xslt/lib/canonical-trix.xsl"/>
					</p:input>
					<p:input port="parameters">
						<p:empty/>
					</p:input>
				</p:xslt>
			</p:otherwise>
		</p:choose>
	</p:declare-step>
	
	
	<p:declare-step type="test:compare-results" name="compare">
		<p:documentation>Compare the 'actual' and 'expected' results.</p:documentation>
		<p:input port="expected" primary="true"/>
		<p:input port="actual"/>
		<p:output port="result" primary="true"/>
		<p:option name="test-name" required="true"/>
		
		<p:wrap-sequence wrapper="c:result"/>
		
		<p:insert name="expected-and-actual" match="/c:result" position="last-child">
			<p:input port="insertion">
				<p:pipe port="actual" step="compare"/>
			</p:input>
		</p:insert>
		
		<p:try>
			<p:group>
				<p:compare fail-if-not-equal="true">
					<p:input port="source" select="/c:result/trix:trix[1]"/>
					<p:input port="alternate" select="/c:result/trix:trix[2]"/>
				</p:compare>
				
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:test success="true"/></p:inline>
					</p:input>
				</p:identity>
				<p:add-attribute match="/c:*" attribute-name="uri">
					<p:with-option name="attribute-value" select="$test-name"/>
				</p:add-attribute>
			</p:group>
			<p:catch>
				<p:store encoding="UTF-8" indent="true" media-type="application/xml" method="xml">
					<p:input port="source">
						<p:pipe port="result" step="expected-and-actual"/>
					</p:input>
					<p:with-option name="href" select="concat('./grip/', $test-name, '.xml')"/>
				</p:store>
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:test success="false">Unknown</c:test></p:inline>
					</p:input>
				</p:identity>
				<p:add-attribute match="/c:*" attribute-name="uri">
					<p:with-option name="attribute-value" select="$test-name"/>
				</p:add-attribute>
			</p:catch>
		</p:try>
		
		<p:identity name="result"/>
	</p:declare-step>
	
	
	<p:declare-step type="test:report">
		<p:documentation>Generate the test report document.</p:documentation>
		<p:input port="source" sequence="true"/>
		<p:output port="result"/>
		
		<p:wrap-sequence wrapper="c:results"/>
		<p:add-attribute match="/c:results" attribute-name="successes">
			<p:with-option name="attribute-value" select="count(/c:results/c:test[xs:boolean(@success) = true()])"/>
		</p:add-attribute>
		<p:add-attribute match="/c:results" attribute-name="success-rate">
			<p:with-option name="attribute-value" select="concat(string((count(/c:results/c:test[xs:boolean(@success) = true()]) div count(/c:results/c:test)) * 100), '%')"/>
		</p:add-attribute>
	
		<p:identity name="report"/>
		
		<p:try>
			<p:documentation>Re-save the previous report for comparing with the new one.</p:documentation>
			<p:group>
				<p:load href="./grip/positive-parser-test-results.xml"/>
		
				<p:store encoding="UTF-8" indent="true" media-type="application/xml" method="xml"
						href="./grip/previous-positive-parser-test-results.xml"/>
			</p:group>
			<p:catch>
				<p:sink/>
			</p:catch>
		</p:try>
		
		<p:identity>
			<p:input port="source">
				<p:pipe port="result" step="report"/>
			</p:input>
		</p:identity>
	</p:declare-step>
	
</p:library>