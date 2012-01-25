<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0"
		xpath-default-namespace="http://www.w3.org/2004/03/trix/trix-1/">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/rdf+xml" method="xml"/>
	
	<xsl:param name="GRAPH_URI" as="xs:string" select="'#default'"/>
	
	
	<!-- Replaces the in-line Graph URI with that passed into the transform. -->
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<xsl:template match="trix:graph/trix:uri">
		<xsl:copy><xsl:value-of select="$GRAPH_URI"/></xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()"/>
		</xsl:copy>
	</xsl:template>
</xsl:transform>