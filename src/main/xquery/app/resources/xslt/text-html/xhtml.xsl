<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xforms="http://www.w3.org/2002/xforms"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xforms xhtml xs"
		version="2.0">
	
	
	<xsl:template match="processing-instruction('xml-stylesheet')">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<xsl:template match="/xhtml:html" priority="1">
		<xsl:apply-templates select="." mode="xhtml"/>
	</xsl:template>
	
	
	<xsl:template match="/xhtml:*">
		<xsl:apply-templates select="/" mode="xhtml"/>
	</xsl:template>
	
	
	<!-- Copies all element, attribute and text nodes within an XHTML document. -->
	<xsl:template match="*" mode="xhtml">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>