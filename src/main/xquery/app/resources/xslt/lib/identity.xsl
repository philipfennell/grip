<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:eoi="http://www.oecd.org/eoi"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xs"
		version="2.0">
	
	<xsl:output encoding="UTF-8" indent="yes" 
			media-type="application/xml" method="xml"/>
	
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<xsl:template match="*">
		<xsl:copy-of select="processing-instruction() | ."/>
	</xsl:template>
</xsl:transform>