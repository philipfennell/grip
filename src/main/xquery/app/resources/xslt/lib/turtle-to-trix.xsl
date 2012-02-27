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
				<xsl:call-template name="ttl:parse-statements"/>
				<!--<uri><xsl:value-of select="$GRAPH_URI"/></uri>-->
			</graph>
		</trix>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-statements">
		<!-- Directives: -->
		<!-- Prefixes. -->
		<xsl:analyze-string select="string(.)" regex="{concat(ttl:match-prefix-id(), ttl:match-ws('*'), '\.', ttl:match-ws('*'))}">
			<xsl:matching-substring>
				<namespace name="{if (string-length(regex-group(2)) gt 0) then regex-group(2) else '_'}"><xsl:value-of select="substring(regex-group(5), 2, string-length(regex-group(5)) - 2)"/></namespace>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<!-- Base URI. -->
				<xsl:analyze-string select="string(.)" regex="{concat(ttl:match-base(), ttl:match-ws('*'), '\.', ttl:match-ws('*'))}">
					<xsl:matching-substring>
						<base-uri name="xml:base"><xsl:value-of select="ttl:get-uri(regex-group(2))"/></base-uri>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<!-- Triples. -->
						<xsl:call-template name="ttl:triples"/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:triples">
		<!--<xsl:analyze-string select="string(.)" regex="{concat(ttl:match-comment(), ttl:match-triples(), ttl:match-ws('*'), '\.', ttl:match-ws('*'))}">-->
			<xsl:analyze-string select="string(.)" 
					regex="{concat('((&lt;.*&gt;)|(([A-Za-z_])([A-Za-z_\-0-9])*)?:[A-Za-z_]([A-Za-z_\-0-9])*)', 
									ttl:match-ws('*'),
									'((&lt;.*&gt;)|(([A-Za-z_])([A-Za-z_\-0-9])*)?:[A-Za-z_]([A-Za-z_\-0-9])*)', ttl:match-ws('*'), '(', ttl:match-string(), ')', ttl:match-ws('*'), '\.', ttl:match-ws('*'))}">
			<xsl:matching-substring>
				<triple>
					<subject><xsl:value-of select="regex-group(1)"/></subject>
					<predicate><xsl:value-of select="regex-group(8)"/></predicate>
					<object><xsl:value-of select="regex-group(15)"/></object>
				</triple>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
		<!--<xsl:value-of select="ttl:match-triples()"/>-->
	</xsl:template>
	
	
	
	<!--  -->
	<xsl:function name="ttl:match-turtle-doc" as="xs:string">
		<xsl:value-of select="concat('(', ttl:match-statement(), ')*')"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-statement" as="xs:string">
		<xsl:value-of select="concat(ttl:match-directive(), '\.|', ttl:match-triples(), '\.|', ttl:match-ws('+'))"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-directive" as="xs:string">
		<xsl:value-of select="concat(ttl:match-prefix-id(), '|', ttl:match-base())"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-base" as="xs:string">
		<xsl:value-of select="concat('@base', ttl:match-ws('+'), ttl:match-uriref())"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-triples" as="xs:string">
		<xsl:value-of select="ttl:match-subject()"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-subject" as="xs:string">
		<!--<xsl:value-of select="concat(ttl:match-resource(), '|', ttl:match-blank())"/>-->
		<xsl:value-of select="ttl:match-resource()"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-resource" as="xs:string">
		<xsl:value-of select="concat(ttl:match-uriref(), '|', ttl:match-qname())"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-qname" as="xs:string">
		<xsl:value-of select="concat('(', ttl:match-prefix-name(), ')?', ':', ttl:match-name())"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-blank" as="xs:string">
		<xsl:value-of select="''"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-prefix-id" as="xs:string">
		<xsl:value-of select="concat('@prefix', ttl:match-ws('+'), '(', ttl:match-prefix-name(), ')?', ':', ttl:match-ws('*'), ttl:match-uriref())"/>
	</xsl:function>
	
	
	<!--  -->
	
	
	<!--  -->
	<xsl:function name="ttl:match-uriref" as="xs:string">
		<xsl:value-of select="'(&lt;.*&gt;)'"/>
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
	<!-- <xsl:value-of select="'[A-Z]|_|[a-z]|[&#x00C0;-&#x00D6;]|[&#x00D8;-&#x00F6;]|[&#x00F8;-&#x02FF;]|[&#x0370;-&#x037D;]|[&#x037F;-&#x1FFF;]|[&#x200C;-&#x200D;]|[&#x2070;-&#x218F;]|[&#x2C00;-&#x2FEF;]|[&#x3001;-&#xD7FF;]|[&#xF900;-&#xFDCF;]|[&#xFDF0;-&#xFFFD;]|[&#x10000;-&#xEFFFF;]'"/>-->
		<xsl:value-of select="'[A-Za-z_]'"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name-char" as="xs:string">
		<!--<xsl:value-of select="concat(ttl:match-name-start-char(), '|-|[0-9]|&#x00B7;|[&#x0300;-&#x036F;]|[&#x203F;-&#x2040;]')"/>-->
		<xsl:value-of select="concat('[', translate(ttl:match-name-start-char(), '[]', ''), '\-0-9]')"/>
	</xsl:function>
	
	
	<!-- Match whitespace characters. -->
	<xsl:function name="ttl:match-ws" as="xs:string">
		<xsl:param name="c" as="xs:string?"/>
		
		<xsl:value-of select="concat('(\t|\n|\r|\s)', $c)"/><!-- , '|', ttl:match-comment() -->
	</xsl:function>
	
	
	<!-- Match comments. -->
	<xsl:function name="ttl:match-comment" as="xs:string">
		<xsl:value-of select="'(^#.*)'"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-string" as="xs:string">
		<xsl:value-of select='".*"'/>
	</xsl:function>
	
	
	<!-- Extracts the URI from its start/end tags. -->
	<xsl:function name="ttl:get-uri" as="xs:string">
		<xsl:param name="uriRef" as="xs:string"/>
		
		<xsl:value-of select="substring($uriRef, 2, string-length($uriRef) - 2)"/>
	</xsl:function>
	
</xsl:transform>