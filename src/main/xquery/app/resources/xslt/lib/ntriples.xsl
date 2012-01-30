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
	
	<xsl:character-map name="ntriples">
		<xsl:output-character character="&#9;" string="&amp;#9;"/>
		<xsl:output-character character="&#10;" string="&amp;#10;"/>
		<xsl:output-character character="&#13;" string="&amp;#13;"/>
		<!--<xsl:output-character character="&amp;" string="&amp;"/>-->
	</xsl:character-map>
	
	
	
	
	<!-- Escape special characters in a plain literal string. -->
	<xsl:function name="nt:escape-string" as="xs:string">
		<xsl:param name="unescapedString" as="xs:string"/>
		<xsl:variable name="escapeSequences" as="element()+">
			<escape match="\\"><xsl:text>\\\\</xsl:text></escape>
			<escape match="\t"><xsl:text>\\t</xsl:text></escape>
			<escape match="\n"><xsl:text>\\n</xsl:text></escape>
			<escape match="\r"><xsl:text>\\r</xsl:text></escape>
			<escape match='"'><xsl:text>\\"</xsl:text></escape>
		</xsl:variable>
		<xsl:value-of select="nt:escape-string($unescapedString, $escapeSequences)"/>
	</xsl:function>
	
	
	<!-- Escape special characters in a plain literal string. -->
	<xsl:function name="nt:escape-string" as="xs:string">
		<xsl:param name="unescapedString" as="xs:string"/>
		<xsl:param name="escapeSequences" as="element()*"/>
		
		<xsl:choose>
			<xsl:when test="exists(nt:head($escapeSequences))">
				<xsl:value-of select="nt:escape-string(
							replace($unescapedString, nt:head($escapeSequences)/@match, nt:head($escapeSequences)/text()), 
									nt:tail($escapeSequences))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="result">
					<xsl:analyze-string select="$unescapedString" regex="(&amp;#x)([0-9A-F]{{2,8}})" flags="i">
						<xsl:matching-substring><xsl:value-of select="concat('\u', regex-group(2))"/></xsl:matching-substring>
						<xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:value-of select="string-join($result, '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	
	<!--  -->
	<xsl:function name="nt:unescape-string" as="xs:string">
		<xsl:param name="escapedString" as="xs:string"/>
		<xsl:variable name="escapeSequences" as="element()+">
			<escape match="\\t"><xsl:text>&#9;</xsl:text></escape>
			<escape match="\\n"><xsl:text>&#10;</xsl:text></escape>
			<escape match="\\r"><xsl:text>&#13;</xsl:text></escape>
			<escape match="\\u"><xsl:text>\\u</xsl:text></escape>
			<escape match='\\"'><xsl:text>"</xsl:text></escape>
			<escape match="\\\\"><xsl:text>\\</xsl:text></escape>
		</xsl:variable>
		<xsl:value-of select="nt:unescape-string($escapedString, $escapeSequences)"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="nt:unescape-string" as="xs:string">
		<xsl:param name="escapedString" as="xs:string"/>
		<xsl:param name="escapeSequences" as="element()*"/>
		
		<xsl:choose>
			<xsl:when test="exists(nt:head($escapeSequences))">
				<xsl:value-of select="nt:unescape-string(
							replace($escapedString, nt:head($escapeSequences)/@match, nt:head($escapeSequences)/text()), 
									nt:tail($escapeSequences))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="result">
					<xsl:analyze-string select="$escapedString" regex="(\\u)([0-9A-F]{{2,8}})" flags="i">
						<xsl:matching-substring><xsl:value-of select="concat('&amp;#x', regex-group(2), ';')"/></xsl:matching-substring>
						<xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:value-of select="string-join($result, '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="nt:head" as="item()?">
		<xsl:param name="sequence" as="item()*"/>
		
		<xsl:sequence select="subsequence($sequence, 1, 1)"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="nt:tail" as="item()*">
		<xsl:param name="sequence" as="item()*"/>
		
		<xsl:sequence select="subsequence($sequence, 2)"/>
	</xsl:function>
</xsl:transform>