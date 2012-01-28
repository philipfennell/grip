<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:err="http://www.marklogic.com/rdf/error"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:nt="http://www.w3.org/TR/rdf-testcases/#ntriples"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<xsl:param name="GRAPH_URI" as="xs:string" select="'#default'"/>
	
	
	<!--  -->
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="nt:triples">
		<trix>
			<graph>
				<uri><xsl:value-of select="$GRAPH_URI"/></uri>
				<xsl:for-each select="tokenize(text(), '&#10;')">
					<xsl:call-template name="trix:triple"/>
				</xsl:for-each>
			</graph>
		</trix>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="trix:triple" as="element(trix:triple)">
		<xsl:variable name="tripleLine" as="xs:string" select="normalize-space(current())"/>
		
		
		
		<triple>
			<xsl:analyze-string select="$tripleLine" regex="{concat('(', nt:match-node-id(), '|', nt:match-uriref(), ')', nt:match-ws('+'), 
																	'(', nt:match-uriref(), ')', nt:match-ws('+'),
																	'(', nt:match-node-id(), '|', nt:match-uriref(), '|', nt:match-datatype-string(), '|', nt:match-lang-string(), ')',
																	nt:match-ws('*'), '\.')}">
				<xsl:matching-substring>
					
					<!-- Subject. -->
					<xsl:choose>
						<xsl:when test="matches(regex-group(1), nt:match-node-id())">
							<id><xsl:value-of select="nt:get-node-id(regex-group(1))"/></id>
						</xsl:when>
						<xsl:when test="matches(regex-group(1), nt:match-uriref())">
							<uri><xsl:value-of select="nt:get-uriref(regex-group(1))"/></uri>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="error(xs:QName('err:NT001'), concat('Invalid Subject: ', regex-group(1)))"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<!-- Predicate. -->
					<xsl:choose>
						<xsl:when test="matches(regex-group(3), nt:match-uriref())">
							<uri><xsl:value-of select="nt:get-uriref(regex-group(3))"/></uri>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="error(xs:QName('err:NT001'), concat('Invalid Predicate: ', regex-group(3)))"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<!-- Object. -->
					<xsl:choose>
						<xsl:when test="matches(regex-group(5), nt:match-datatype-string())">
							<typedLiteral datatype="{nt:get-datatype(regex-group(5))}">
								<xsl:value-of select="nt:get-data-value(regex-group(5))"/>
							</typedLiteral>
						</xsl:when>
						<xsl:when test="matches(regex-group(5), nt:match-lang-string())">
							<plainLiteral>
								<xsl:if test="nt:get-language-code(regex-group(5))">
									<xsl:attribute name="xml:lang" select="nt:get-language-code(regex-group(5))"></xsl:attribute>
								</xsl:if>
								<xsl:value-of select="nt:get-string-value(regex-group(5))"/>
							</plainLiteral>
						</xsl:when>
						<xsl:when test="matches(regex-group(5), nt:match-node-id())">
							<id><xsl:value-of select="nt:get-node-id(regex-group(5))"/></id>
						</xsl:when>
						<xsl:when test="matches(regex-group(5), nt:match-uriref())">
							<uri><xsl:value-of select="nt:get-uriref(regex-group(5))"/></uri>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="error(xs:QName('err:NT001'), concat('Invalid Object: ', regex-group(5)))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					
					<xsl:message>[XSLT] Invalid Triple: <xsl:value-of select="."/></xsl:message>
					<xsl:copy-of select="error(xs:QName('err:NT001'), concat('Invalid Triple: ', .))"/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</triple>
	</xsl:template>
	
	
	<!-- Match Typed Literal. -->
	<xsl:function name="nt:match-datatype-string" as="xs:string">
		<xsl:value-of select="'&quot;.*&quot;\^\^&lt;xs:\w+&gt;'"/>
	</xsl:function>
	
	
	<!-- Match a Plain Literal with optional language code. -->
	<xsl:function name="nt:match-lang-string" as="xs:string">
		<xsl:value-of select="concat('&quot;.*&quot;(', nt:match-lang-code(), ')?')"/>
	</xsl:function>
	
	
	<!-- Match language code. -->
	<xsl:function name="nt:match-lang-code" as="xs:string">
		<xsl:value-of select="'@[a-z]+(-[A-Z0-9]+)*'"/>
	</xsl:function>
	
	
	<!-- Match for nodeID. -->
	<xsl:function name="nt:match-node-id" as="xs:string">
		<xsl:value-of select="'_:\w+'"/>
	</xsl:function>
	
	
	<!-- Match for URI Reference. -->
	<xsl:function name="nt:match-uriref" as="xs:string">
		<xsl:value-of select="'&lt;.+&gt;'"/>
	</xsl:function>
	
	
	<!-- Match for whitespace. -->
	<xsl:function name="nt:match-ws" as="xs:string">
		<xsl:param name="c" as="xs:string?"/>
		
		<xsl:value-of select="concat('(\s|\t)', $c)"/>
	</xsl:function>
	
	
	<!-- Match for end-of-line -->
	<xsl:function name="nt:match-eoln" as="xs:string">
		<xsl:value-of select="'\n|\r|\r\n'"/>
	</xsl:function>
	
	
	<!-- Returns nodeID. -->
	<xsl:function name="nt:get-node-id" as="xs:string">
		<xsl:param name="string" as="xs:string"/>
		
		<xsl:value-of select="substring-after($string, '_:')"/>
	</xsl:function>
	
	
	<!-- Returns URI Reference. -->
	<xsl:function name="nt:get-uriref" as="xs:string">
		<xsl:param name="string" as="xs:string"/>
		
		<xsl:value-of select="replace($string, '&lt;|&gt;', '')"/>
	</xsl:function>
	
	
	<!-- Returns the datatype from the object. -->
	<xsl:function name="nt:get-datatype" as="xs:string">
		<xsl:param name="string" as="xs:string"/>
		
		<xsl:value-of select="nt:get-uriref(substring-after($string, '^^'))"/>
	</xsl:function>
	
	
	<!-- Returns the value from the object. -->
	<xsl:function name="nt:get-data-value" as="xs:string">
		<xsl:param name="string" as="xs:string"/>
		
		<xsl:value-of select="replace(substring-before($string, '^^'), '&quot;', '')"/>
	</xsl:function>
	
	
	<!-- Returns the string value from the object. -->
	<xsl:function name="nt:get-string-value" as="xs:string">
		<xsl:param name="string" as="xs:string"/>
		<xsl:variable name="langCode" as="xs:string?">
			<xsl:analyze-string select="$string" regex="{nt:match-lang-code()}">
				<xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:value-of select="replace(if (string-length($langCode) gt 0) then substring-before($string, $langCode) else $string, '&quot;', '')"/>
	</xsl:function>
	
	
	<!-- Returns language code from object. -->
	<xsl:function name="nt:get-language-code" as="xs:string?">
		<xsl:param name="string" as="xs:string"/>
		
		<xsl:analyze-string select="$string" regex="{nt:match-lang-code()}">
			<xsl:matching-substring><xsl:value-of select="substring-after(., '@')"/></xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
</xsl:transform>