<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
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
		<gsp:namespaces>
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
		
		<rdf:RDF>
			<!-- Insert the namespace declarations into the RDF/XML serialisation. -->
			<xsl:for-each select="$NAMESPACES/gsp:namespace">
				<xsl:namespace name="{@prefix}"><xsl:value-of select="@uri"/></xsl:namespace>
			</xsl:for-each>
			
			<!-- Get the unique subject URIs in the graph. -->
			<xsl:for-each select="distinct-values(//s)">
				<rdf:Description rdf:about="{.}">
					<xsl:apply-templates select="$root//t[string(s) eq current()]" mode="rdf-xml"/>
				</rdf:Description>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>
	
	
	<!-- Creates the predicate/object pair. -->
	<xsl:template match="t" mode="rdf-xml" priority="3">
		<xsl:variable name="localName" as="xs:string" select="gsp:get-name(string(p))"/>
		<xsl:variable name="prefix" as="xs:string?" select="gsp:get-namespace-prefix(gsp:get-namespace(string(p)))"/>
		
		<xsl:element name="{concat($prefix, if (string-length($prefix) gt 0) then ':' else '', $localName)}" 
				namespace="{gsp:get-namespace(string(p))}">
			<xsl:next-match/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Resources -->
	<xsl:template match="t[o/@type eq 'http://www.w3.org/2001/XMLSchema#anyURI']" mode="rdf-xml" priority="2">
		<xsl:attribute name="rdf:resource" select="o"/>
	</xsl:template>
	
	
	<!-- Typed literals. -->
	<xsl:template match="t" mode="rdf-xml">
		<xsl:if test="o/@lang">
			<xsl:attribute name="xml:lang" select="o/@lang"/>
		</xsl:if>
		<xsl:if test="o/@type">
			<xsl:attribute name="rdf:datatype" select="concat(gsp:get-namespace-prefix(gsp:get-namespace(o/@type)), ':', gsp:get-name(o/@type))"/>
		</xsl:if>
		<xsl:value-of select="o"/>
	</xsl:template>
	
	
	<!-- Returns the local-name for the predicate. -->
	<xsl:function name="gsp:get-name" as="xs:string">
		<xsl:param name="predicateURI" as="xs:string"/>
		<xsl:variable name="lastStep" as="xs:string" 
				select="if (contains($predicateURI, '/')) then subsequence(reverse(tokenize($predicateURI, '/')), 1, 1) else $predicateURI"/>
		
		<xsl:value-of select="if (contains($lastStep, '#')) then substring-after($lastStep, '#') else $lastStep"/>
	</xsl:function>
	
	
	<!-- Returns the namespace URI for the predicate. -->
	<xsl:function name="gsp:get-namespace" as="xs:string">
		<xsl:param name="predicateURI" as="xs:string"/>
		
		<xsl:value-of select="substring-before($predicateURI, gsp:get-name($predicateURI))"/>
	</xsl:function>
	
	
	<!-- Returns the namespace prefix for the namespace URI. -->
	<xsl:function name="gsp:get-namespace-prefix" as="xs:string?">
		<xsl:param name="namespaceURI" as="xs:string"/>
		
		<xsl:value-of select="$NAMESPACES/gsp:namespace[@uri eq $namespaceURI]/@prefix"/>
	</xsl:function>
</xsl:transform>