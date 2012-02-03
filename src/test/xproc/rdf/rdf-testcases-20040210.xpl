<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
		xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
		xmlns:cx="http://xmlcalabash.com/ns/extensions"
		xmlns:nt="http://www.w3.org/ns/formats/N-Triples"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:test="http://www.w3.org/2000/10/rdf-tests/rdfcore/testSchema#"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		exclude-inline-prefixes="#all"
		name="rdf-test-cases">
	
	<p:documentation>RDF Test Cases (Latest Approved)</p:documentation>
	<p:input port="source">
		<p:document href="latest_Approved/Manifest.rdf"/>
	</p:input>
	<p:output port="result"/>
	
	<p:import href="../../resources/xproc/library-1.0.xpl"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	<p:for-each>
		<!-- <p:iteration-source select="/rdf:RDF/node()[ends-with(local-name(), 'ParserTest')][test:status eq 'APPROVED']"/> -->
		<p:iteration-source select="/rdf:RDF/test:PositiveParserTest[test:status eq 'APPROVED']"/>
		
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
		
		<p:identity name="test-case"/>
		
		<p:load name="source">
			<p:with-option name="href" select="/test:*/test:inputDocument/test:RDF-XML-Document/@rdf:about"/>
		</p:load>
		<p:sink/>
		
		
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
		</p:xslt>
		<p:string-replace name="expected" match="//trix:id/text()" replace="''"/>
		
		<p:xslt>
			<p:documentation>Transform the test's source into TriX.</p:documentation>
			<p:input port="source">
				<p:pipe port="result" step="source"/>
			</p:input>
			<p:input port="stylesheet">
				<p:document href="../../../main/xquery/app/resources/xslt/lib/rdf-xml-to-trix.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			<p:with-param name="BASE_URI" select="$testURI"/>
		</p:xslt>
		<p:string-replace name="actual" match="//trix:id/text()" replace="''"/>
		
		<p:wrap-sequence wrapper="c:result">
			<p:input port="source">
				<p:pipe port="result" step="expected"/>
			</p:input>
		</p:wrap-sequence>
		<p:insert name="expected-and-actual" match="/c:result" position="last-child">
			<p:input port="insertion">
				<p:pipe port="result" step="actual"/>
			</p:input>
		</p:insert>
		
		<p:choose>
			<p:when test="not(exists(/c:result/trix:trix[1]/trix:graph/trix:triple))">
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:no-source-triples/></p:inline>
					</p:input>
				</p:identity>
				<cx:message>
					<p:with-option name="message" select="concat('[XProc][Failed]  ', $testName, ' - No Source Triples')"/>
				</cx:message>
			</p:when>
			<p:when test="exists(/c:result/trix:trix[2]/trix:graph/trix:triple)">
				<p:try>
					<p:group>
						<p:compare fail-if-not-equal="true">
							<p:input port="source" select="/c:result/trix:trix[1]"/>
							<p:input port="alternate" select="/c:result/trix:trix[2]"/>
						</p:compare>
						
						<p:identity>
							<p:input port="source">
								<p:inline exclude-inline-prefixes="#all"><c:success/></p:inline>
							</p:input>
						</p:identity>
						<cx:message>
							<p:with-option name="message" select="concat('[XProc][Success] ', $testName)"/>
						</cx:message>
					</p:group>
					<p:catch>
						<p:identity>
							<p:input port="source">
								<p:inline exclude-inline-prefixes="#all"><c:failed/></p:inline>
							</p:input>
						</p:identity>
						<cx:message>
							<p:with-option name="message" select="concat('[XProc][Failed]  ', $testName)"/>
						</cx:message>
					</p:catch>
				</p:try>
			</p:when>
			<p:otherwise>
				<p:identity>
					<p:input port="source">
						<p:inline exclude-inline-prefixes="#all"><c:no-result-triples/></p:inline>
					</p:input>
				</p:identity>
				<cx:message>
					<p:with-option name="message" select="concat('[XProc][Failed]  ', $testName, ' - No Result Triples')"/>
				</cx:message>
			</p:otherwise>
		</p:choose>
		
		<p:identity name="result"/>
		
		
		
		<p:store encoding="UTF-8" indent="true" media-type="application/xml" method="xml">
			<p:input port="source">
				<p:pipe port="result" step="expected-and-actual"/>
			</p:input>
			<p:with-option name="href" select="concat('./results/', $testName, '.xml')"/>
		</p:store>
		
		<p:identity>
			<p:input port="source">
				<p:pipe port="result" step="result"/>
			</p:input>
		</p:identity>
	</p:for-each>
	
	<p:wrap-sequence wrapper="c:results"/>
</p:declare-step>