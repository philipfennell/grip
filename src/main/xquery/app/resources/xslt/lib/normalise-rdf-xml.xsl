<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:err="http://www.marklogic.com/rdf/error"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/rdf+xml" method="xml"/>
	
	
	<!-- Normalises RDF/XML into some form of canonical representation. -->
	
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
		
	
	<!-- The RDF root. -->
	<xsl:template match="rdf:RDF">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			<xsl:apply-templates select="*" mode="rdf:nodes"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Conventional rdf:Description nodes. -->
	<xsl:template match="rdf:Description[@rdf:about | @rdf:nodeID]" mode="rdf:nodes">
		<xsl:copy>
			<xsl:copy-of select="@rdf:*"/>
			<xsl:apply-templates select="* | (@* except (@rdf:*))" mode="rdf:properties"/>
		</xsl:copy>
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	
	<!-- Conventional rdf:Description nodes with an abbreviated URI references. -->
	<xsl:template match="rdf:Description[@rdf:ID]" mode="rdf:nodes">
		<xsl:copy>
			<xsl:attribute name="rdf:about" select="rdf:resolve-uri(@rdf:ID)"/>
			<xsl:apply-templates select="* | (@* except (@rdf:*, @xml:*))" mode="rdf:properties"/>
		</xsl:copy>
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	
	<!-- Expand blank nodes. -->
	<xsl:template match="*[rdf:Description]" mode="rdf:nodes">
		<rdf:Description rdf:nodeID="{generate-id()}">
			<xsl:apply-templates select="rdf:Description/*" mode="rdf:properties"/>
		</rdf:Description>
	</xsl:template>
	
	
	<!-- Expand typed element nodes. -->
	<xsl:template match="*[prefix-from-QName(resolve-QName(name(), .)) ne 'rdf'][@rdf:about | @rdf:ID]" mode="rdf:nodes">
		<rdf:Description>
			<xsl:attribute name="rdf:about" select="rdf:resolve-uri((@rdf:about | @rdf:ID))"/>
			<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			<xsl:apply-templates select="*" mode="rdf:properties"/>
		</rdf:Description>
	</xsl:template>
	
	
	<!-- Expand blank nodes. -->
	<xsl:template match="*[@rdf:parseType = 'Resource']" mode="rdf:nodes">
		<rdf:Description rdf:nodeID="{generate-id()}">
			<xsl:apply-templates select="*" mode="rdf:properties"/>
		</rdf:Description>
	</xsl:template>
	
	
	<!-- Expand property attributes into property elements. -->
	<xsl:template match="@*" mode="rdf:properties">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Generate a node reference. -->
	<xsl:template match="*[rdf:Description]" mode="rdf:properties">
		<xsl:copy>
			<xsl:apply-templates select="*" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:Description[@rdf:about]" mode="rdf:properties">
		<xsl:attribute name="rdf:resource" select="@rdf:about"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:Description[not(@rdf:*)]" mode="rdf:properties">
		<xsl:attribute name="rdf:nodeID" select="generate-id(..)"/>
	</xsl:template>
	
	
	<!-- Generate a node reference. -->
	<xsl:template match="*[@rdf:parseType = 'Resource']" mode="rdf:properties">
		<xsl:copy>
			<xsl:attribute name="rdf:nodeID" select="generate-id()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Copy plain literals. -->
	<xsl:template match="*[text()]" mode="rdf:properties">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*[@rdf:nodeID]" mode="rdf:properties">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*[@rdf:resource]" mode="rdf:properties">
		<xsl:copy>
			<xsl:attribute name="rdf:resource" select="rdf:resolve-uri(@rdf:resource)"/>
			<xsl:copy-of select="text()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Suppress unwanted text nodes. -->
	<xsl:template match="text()" mode="#all"/>
	
	
	<!--  -->
	<xsl:function name="rdf:resolve-uri" as="xs:string">
		<xsl:param name="uriAttr" as="attribute()"/>
		
		<xsl:value-of select="resolve-uri(string($uriAttr), ($uriAttr/ancestor::*[@xml:base][1]/@xml:base, static-base-uri())[1])"/>
	</xsl:function>
	
	
	
	
	<!-- === Errors or Unsupported. ======================================================= -->
	
	
	<!-- Throw an exception for invalid/unsupported parse types. -->
	<xsl:template match="*[@rdf:parseType and not(@rdf:parseType = ('Resource', 'Literal'))]" mode="#all" priority="10">
		<xsl:copy-of select="error(xs:QName('err:TX001'), concat('Unsupported Parse Type: ''', @rdf:parseType, ''''), ())"/>
	</xsl:template>
	
	
	<!-- Throw an error if rdf:Bag, rdf:Seq or rdf:Alt are present. -->
	<xsl:template match="rdf:Bag | rdf:Seq | rdf:Alt" mode="#all" priority="10">
		<xsl:copy-of select="error(xs:QName('err:TX001'), 'Graphs using rdf:Bag, rdf:Seq or rdf:Alt are not, currently, supported.')"/>
	</xsl:template>
	
</xsl:transform>