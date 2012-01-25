<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="rdf xs"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<xsl:param name="GRAPH_URI" as="xs:string" select="/default"/>
	
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<xsl:template match="rdf:RDF">
		<graph uri="{$GRAPH_URI}">
			<xsl:for-each select="namespace::*">
				<xsl:copy-of select="."/>
			</xsl:for-each>
			<xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema#</xsl:namespace>
			<xsl:apply-templates select="rdf:Description" mode="tuples"/>
		</graph>
	</xsl:template>
	
	
	<xsl:template match="rdf:Description" mode="tuples">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>
	
	
	<xsl:template match="*" mode="tuples">
		<t>
			<s><xsl:value-of select="(../@rdf:about, ../@rdf:nodeID)[1]"/></s>
			<p><xsl:value-of select="concat(namespace-uri(), local-name())"/></p>
			<o>
				<xsl:if test="exists(@rdf:resource)">
					<xsl:attribute name="type">http://www.w3.org/2001/XMLSchema#anyURI</xsl:attribute>
				</xsl:if>
				<xsl:if test="exists(@rdf:datatype)">
					<xsl:attribute name="type" select="@rdf:datatype"/>
				</xsl:if>
				<xsl:if test="exists(@xml:lang)">
					<xsl:attribute name="lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="(@rdf:resource, @rdf:nodeID, string(.))[1]"/>
			</o>
			<c><xsl:value-of select="$GRAPH_URI"/></c>
		</t>
	</xsl:template>
</xsl:transform>