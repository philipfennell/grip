<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/TR/rdf-interfaces"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:rdfi="http://www.w3.org/TR/rdf-interfaces"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	
	<!-- =======================================================================
		
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	
	You may obtain a copy of the License at
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	======================================================================== -->
	
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<!-- Default namespaces.
	<xsl:param name="NAMESPACES" as="element(gsp:namespaces)">
		<gsp:namespaces xmlns="">
			<gsp:namespace prefix="rdf"	uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
			<gsp:namespace prefix="dc"	uri="http://purl.org/dc/elements/1.1/"/>
			<gsp:namespace prefix="xs"	uri="http://www.w3.org/2001/XMLSchema#"/>
		</gsp:namespaces>
	</xsl:param> -->
	
	
	
	
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<xsl:template match="rdfi:graph">
		<xsl:variable name="root" as="element()" select="current()"/>
		
		
			<!-- Insert the namespace declarations.
			<xsl:for-each select="namespace::*">
				<xsl:namespace name="{name(.)}"><xsl:value-of select="."/></xsl:namespace>
			</xsl:for-each> -->
			
			<graph>
				<xsl:copy-of select="rdfi:uri"/>
				<xsl:apply-templates select="t" mode="rdfi"/>
			</graph>
		
	</xsl:template>
	
	
	<!-- Creates the predicate/object pair. -->
	<xsl:template match="t" mode="rdfi" priority="3">
		<triple xml:base="{base-uri(.)}">
			<xsl:choose>
				<xsl:when test="matches(s, '_:\w+')">
					<id><xsl:value-of select="substring-after(s, '_:')"/></id>
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
	<xsl:template match="t[o/@datatype][ends-with(o/@datatype, '#anyURI')]" mode="rdfi" priority="2">
		<uri><xsl:value-of select="o"/></uri>
	</xsl:template>
	
	
	<!-- XML Literals -->
	<xsl:template match="t[o/@datatype][ends-with(o/@datatype, '#XMLLiteral')]" mode="rdfi" priority="2.5">
		<typedLiteral>
			<xsl:copy-of select="o/@*"/>
			<xsl:copy-of select="o/(* | text())" copy-namespaces="no"/>
		</typedLiteral>
	</xsl:template>
	
	
	<!-- Type Literals that aren't URIs. -->
	<xsl:template match="t[o/@datatype][not(ends-with(o/@datatype, '#anyURI'))]" mode="rdfi" priority="2">
		<typedLiteral datatype="{o/@datatype}">
			<xsl:copy-of select="o/@xml:lang"/>
			<xsl:value-of select="o"/>
		</typedLiteral>
	</xsl:template>
	
	
	<xsl:template match="t[matches(o, '_:\w+')]" mode="rdfi" priority="2">
		<id><xsl:value-of select="substring-after(o, '_:')"/></id>
	</xsl:template>
	
	
	<xsl:template match="t" mode="rdfi" priority="1">
		<plainLiteral>
			<xsl:copy-of select="o/@xml:lang"/>
			<xsl:value-of select="o"/>
		</plainLiteral>
	</xsl:template>
	
</xsl:transform>