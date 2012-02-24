<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:err="http://www.marklogic.com/rdf/error"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:ttl="http://www.w3.org/ns/formats/Turtle"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:xdmp="http://marklogic.com/xdmp"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" use-character-maps="ntriples" indent="yes" media-type="application/xml" method="xml"/>
	
	<xsl:include href="ntriples.xsl"/>
	
	<xsl:param name="GRAPH_URI" as="xs:string" select="'#default'"/>
	
	
	
	
	<!--  -->
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="ttl:RDF">
		<trix>
			<graph>
				<xsl:call-template name="ttl:prolog"/>
				<uri><xsl:value-of select="$GRAPH_URI"/></uri>
			</graph>
		</trix>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:prolog">
		<xsl:analyze-string select="string(.)" regex="{ttl:match-prefix-id()}">
<!--			<xsl:analyze-string select="string(.)" regex="@prefix(\s|\t)+([A-Z]|_|[a-z]([A-Z]|_|[a-z]|-|[0-9])*)?">-->
			<xsl:matching-substring>
				<xsl:namespace name="{if (string-length(regex-group(2)) gt 0) then regex-group(2) else '_'}"><xsl:value-of select="substring(regex-group(5), 2, string-length(regex-group(5)) - 2)"/></xsl:namespace>
<!--				<xsl:comment><xsl:value-of select="if (string-length(regex-group(2)) gt 0) then regex-group(2) else '_'"/> : <xsl:value-of select="substring(regex-group(5), 2, string-length(regex-group(5)) - 2)"/></xsl:comment>-->
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
	</xsl:template>
	
	
	<!--  -->
	<xsl:function name="ttl:uriref" as="xs:string">
		<xsl:value-of select="'(&lt;.*&gt;)'"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-prefix-id" as="xs:string">
		<xsl:value-of select="concat('@prefix', ttl:match-ws('+'), '(', ttl:match-prefix-name(), ')?', ':', ttl:match-ws('*'), ttl:uriref())"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-prefix-name" as="xs:string">
		<xsl:value-of select="concat(ttl:match-name-start-char(), '(', ttl:match-name-char(), ')*')"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name" as="xs:string">
		<xsl:value-of select="concat(ttl:match-name-start-char(), '(', ttl:match-name-char(), ')*')"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name-start-char" as="xs:string">
<!--		<xsl:value-of select="'[A-Z]|_|[a-z]|[&#x00C0;-&#x00D6;]|[&#x00D8;-&#x00F6;]|[&#x00F8;-&#x02FF;]|[&#x0370;-&#x037D;]|[&#x037F;-&#x1FFF;]|[&#x200C;-&#x200D;]|[&#x2070;-&#x218F;]|[&#x2C00;-&#x2FEF;]|[&#x3001;-&#xD7FF;]|[&#xF900;-&#xFDCF;]|[&#xFDF0;-&#xFFFD;]|[&#x10000;-&#xEFFFF;]'"/>-->
		<xsl:value-of select="'[A-Z]|_|[a-z]'"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name-char" as="xs:string">
<!--		<xsl:value-of select="concat(ttl:match-name-start-char(), '|-|[0-9]|&#x00B7;|[&#x0300;-&#x036F;]|[&#x203F;-&#x2040;]')"/>-->
		<xsl:value-of select="concat(ttl:match-name-start-char(), '|-|[0-9]')"/>
	</xsl:function>
	
	
	<!-- Match for whitespace. -->
	<xsl:function name="ttl:match-ws" as="xs:string">
		<xsl:param name="c" as="xs:string?"/>
		
		<xsl:value-of select="concat('(\s|\t)', $c)"/>
	</xsl:function>
	
</xsl:transform>