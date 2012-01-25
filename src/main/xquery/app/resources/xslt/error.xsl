<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:err="http://www.eoi-portal.org/error"
		xmlns:error="http://marklogic.com/xdmp/error"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="err error xs"
		version="2.0">
	
	<xsl:import href="text-html/common.xsl"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<xsl:strip-space elements="*"/>
	
	
	
	
	<!-- Wraps and XHTML fragment in an XHTML document. -->
	<xsl:template match="/" priority="1">
		<html lang="en">
			<xsl:copy-of select="$HEADER" copy-namespaces="no"/>
			<body>
				<div id="container">
					<div id="header">
						<h1 id="logo"><a href="/"><span>Exchange of Information Portal</span></a></h1>
					</div>
					<div id="content">	
						<h2><xsl:value-of select="error:errors/error:response-message"/></h2>
						
						
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
	
	
	<xsl:template match="error:code" mode="error">
		<h3><xsl:value-of select="."/></h3>
	</xsl:template>
	
	
	<xsl:template match="error:stack" mode="error"/>
	
	
	<xsl:template match="text()" mode="error"/>
		
</xsl:transform>