<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
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
			<xsl:variable name="relabeledNodes" as="element()*">
				<xsl:apply-templates select="triple" mode="#current">
					<!-- Sort triples by the predicate URI. -->
					<xsl:sort select="string(*[2])"/>
					<xsl:with-param name="idLUT" as="element()" tunnel="yes">
						<ids xmlns="http://www.w3.org/2004/03/trix/trix-1/">
							<xsl:for-each select="distinct-values(descendant::id)">
								<id xmlns="http://www.w3.org/2004/03/trix/trix-1/" 
										value="{.}" replacement="{concat('A', string(position()))}"/>
							</xsl:for-each>
						</ids>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:for-each select="$relabeledNodes">
				<xsl:sort select="string(*[1])"/>
				<xsl:sort select="string(*[2])"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="id" mode="canon">
		<xsl:param name="idLUT" as="element()" tunnel="yes"/>
		<xsl:copy><xsl:value-of select="$idLUT/id[@value eq string(current())]/@replacement"/></xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*" mode="canon">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:transform>