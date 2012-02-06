<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0"
		xpath-default-namespace="http://www.w3.org/2004/03/trix/trix-1/">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<!-- Canonicalises a TriX document according to the Canonicalisation 
		 Guidelines. -->
	
	
	<xsl:template match="/">
		<xsl:apply-templates select="*" mode="canon"/>
	</xsl:template>
	
	
	<xsl:template match="graph" mode="canon">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="uri"/>
			<xsl:apply-templates select="triple" mode="#current">
				<!-- Sort triples by the predicate URI. -->
				<xsl:sort select="string(*[2])"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*" mode="canon">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:transform>