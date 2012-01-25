<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<!-- Default namespaces. -->
	<xsl:param name="NAMESPACES" as="element(gsp:namespaces)">
		<gsp:namespaces xmlns="">
			<gsp:namespace prefix="rdf"	uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
			<gsp:namespace prefix="dc"	uri="http://purl.org/dc/elements/1.1/"/>
			<gsp:namespace prefix="xs"	uri="http://www.w3.org/2001/XMLSchema#"/>
		</gsp:namespaces>
	</xsl:param>
	
	
	
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<xsl:template match="graph">
		<xsl:variable name="root" as="element()" select="current()"/>
		
		<trix>
			<!-- Insert the namespace declarations into the RDF/XML serialisation. -->
			<xsl:for-each select="$NAMESPACES/gsp:namespace">
				<xsl:namespace name="{@prefix}"><xsl:value-of select="@uri"/></xsl:namespace>
			</xsl:for-each>
			
			<graph>
				<uri><xsl:value-of select="@uri"/></uri>
				<xsl:apply-templates select="t" mode="trix"/>
			</graph>
		</trix>
	</xsl:template>
	
	
	<!-- Creates the predicate/object pair. -->
	<xsl:template match="t" mode="trix" priority="3">
		<triple>
			<xsl:choose>
				<xsl:when test="matches(s, '_BN\d+')">
					<id><xsl:value-of select="s"/></id>
				</xsl:when>
				<xsl:otherwise>
					<uri><xsl:value-of select="s"/></uri>
				</xsl:otherwise>
			</xsl:choose>
			<uri><xsl:value-of select="p"/></uri>
			<xsl:next-match/>
		</triple>
	</xsl:template>
	
	
	<!-- Resources -->
	<xsl:template match="t[o/@datatype eq 'http://www.w3.org/2001/XMLSchema#anyURI']" mode="trix" priority="2">
		<uri><xsl:value-of select="o"/></uri>
	</xsl:template>
	
	
	<xsl:template match="t[o/@datatype ne 'http://www.w3.org/2001/XMLSchema#anyURI']" mode="trix" priority="2">
		<typedLiteral datatype="{o/@datatype}">
			<xsl:copy-of select="o/@xml:lang"/>
			<xsl:value-of select="o"/>
		</typedLiteral>
	</xsl:template>
	
	
	<xsl:template match="t[matches(o, '_BN\d+')]" mode="trix" priority="2">
		<id><xsl:value-of select="o"/></id>
	</xsl:template>
	
	
	<xsl:template match="t" mode="trix" priority="1">
		<plainLiteral>
			<xsl:copy-of select="o/@xml:lang"/>
			<xsl:value-of select="o"/>
		</plainLiteral>
	</xsl:template>
	
</xsl:transform>