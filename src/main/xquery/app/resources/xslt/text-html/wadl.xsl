<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:wadl="http://wadl.dev.java.net/2009/02"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		exclude-result-prefixes="wadl xhtml"
		version="2.0">
	
	<xsl:import href="xml-to-string.xsl"/>
	
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/html" 
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
	
	<xsl:strip-space elements="*"/>
	
	<!-- Mode takes four possible values: ('summary'|'detail'|'all'|'') 
		 'summary' and 'detail' speak for themselves, as does all, but the '' 
		 empty string is the same as 'all'. -->
	<xsl:param name="MODE"/>
	
	<!-- Prefix for heading links. -->
	<xsl:param name="PAGE_TITLE" select="'API'"/>
	
	
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
				xmlns:dcterms="http://purl.org/dc/terms/">
		<rdf:Description rdf:about="$Source: $">
			<dcterms:creator>Philip A. R. Fennell</dcterms:creator>
			<dcterms:hasVersion>$Revision: $</dcterms:hasVersion>
			<dcterms:dateSubmitted>$Date: $</dcterms:dateSubmitted>
			<dcterms:rights>Copyright 2009 All Rights Reserved.</dcterms:rights>
			<dcterms:format>text/xml</dcterms:format>
			<dcterms:description>Transforms a WADL RESTful Web Service Description document into a XHTML representation for documentation purposes.</dcterms:description>
		</rdf:Description>
	</rdf:RDF>
	
	
	
	
	<xsl:attribute-set name="table"/>
	
	<xsl:attribute-set name="th"/>
	
	<xsl:attribute-set name="td"/>
	
	<!--
	<xsl:template match="/" priority="1">
		<xsl:apply-templates select="wadl:application" mode="wadl:normalize"/>
	</xsl:template>
	-->
	
	<!--  -->
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<xsl:template match="wadl:application">
		<xsl:variable name="resolvedWADL">
			<xsl:apply-templates select="." mode="wadl:normalize"/>
		</xsl:variable>
		
		<html xml:lang="en-GB" lang="en-GB">
			<head profile="http://dublincore.org/documents/dcq-html/">
				<link rel="schema.dcterms" href="http://purl.org/dc/terms/" />
				<meta name="copyright" content=""/>
				<meta name="author" content=""/>
				<meta name="dcterms.created" content="2009-04-21T09:07:00Z" />
				<meta name="dcterms.modified" content="" />
				<!-- <link rel="stylesheet" type="text/css" href="" media="screen" /> -->
				<!-- <script type="text/javascript" src=""></script> -->
				<!-- <script type="text/javascript">
					
					</script> -->
				<style type="text/css">
					.method, .request, .response, .headers, .parameters {
						margin-left:1em
					}
						
					table {
						border-top:1px solid #000000;
						border-left:1px solid #000000;
					}
						
					th, td {
						border-bottom:1px solid #000000;
						border-right:1px solid #000000;
						padding:0.25em;
					}
					
					th {
						font-weight:bold;
						background-color:#CCCCCC;
					}
				</style>
				<title>
					<xsl:value-of select="wadl:doc/@title"/>
				</title>
			</head>
			<body>
				<h1>Service: <xsl:value-of select="wadl:doc/@title"/></h1>
				<p><span>Description: </span> <xsl:value-of select="wadl:doc"/></p>
				<p>Base URI: <code><xsl:value-of select="wadl:resources/@base"/></code></p>
				<xsl:if test="$MODE != 'detail'">
					<div>
						<h2 id="ServiceSummary">Service Summary</h2>
						<xsl:apply-templates select="$resolvedWADL/wadl:application/wadl:resources" mode="wadl:summary"/>
					</div>
				</xsl:if>
				<xsl:if test="$MODE != 'summary'">
					<div>
						<h2 id="ServiceDetails">Service Details</h2>
						<xsl:apply-templates select="$resolvedWADL/wadl:application/wadl:resources" mode="wadl:detail2"/>
					</div>
				</xsl:if>
				<xsl:if test="//wadl:*[xhtml:code]">
					<div>
						<h2 id="{translate($PAGE_TITLE, ' ', '')}-Appendix"><a name="{translate($PAGE_TITLE, ' ', '')}-Appendix">Appendix</a></h2>
						<h3 id="{translate($PAGE_TITLE, ' ', '')}-AppendixA"><a name="{translate($PAGE_TITLE, ' ', '')}-AppendixA">A: Examples</a></h3>
						<xsl:apply-templates select="//wadl:*[@id]" mode="wadl:examples"/>
					</div>
				</xsl:if>
				<p>
					<a href="http://validator.w3.org/check?uri=referer">
						<img src="http://www.w3.org/Icons/valid-xhtml10-blue"
							alt="Valid XHTML 1.0 Strict" height="31" 
							width="88" />
					</a>
				</p>
			</body>
		</html>
	</xsl:template>
	
	
	
	
	<!-- === Resolve internal references with the WADL. ==================== -->
	
	<!-- -->
	<xsl:template match="wadl:*[@href]" mode="wadl:normalize">
		<xsl:variable name="fragId" select="substring-after(@href, '#')"/>
		
		<xsl:apply-templates select="//wadl:*[@id = $fragId]" mode="wadl:resolve-refs"/>
	</xsl:template>
	
	
	<!-- Replicate nodes. -->
	<xsl:template match="*" mode="wadl:normalize">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="wadl:normalize"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="wadl:param[@id]" mode="wadl:normalize"/>
		
	
	
	
	<!-- Replicate referenced components. -->
	<xsl:template match="*" mode="wadl:resolve-refs">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="wadl:attrs"/>
			<xsl:apply-templates select="* | text()" mode="wadl:resolve-refs"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Ignore ID attributes as they are not required/valid once a reference 
		 has been resolved. -->
	<xsl:template match="@id" mode="wadl:attrs">
		<xsl:attribute name="ref"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	
	
	<!-- Replicate attributes. -->
	<xsl:template match="@*" mode="wadl:attrs">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Service Summary. ============================================== -->
	
	<!-- Table structure for API Summary. -->
	<xsl:template match="wadl:resources" mode="wadl:summary">
		<table summary="Service Desription Summary"
				xsl:use-attribute-sets="table">
			<thead>
				<tr>
					<th xsl:use-attribute-sets="th" id="description">Resource</th>
					<th xsl:use-attribute-sets="th" id="uri">URI Structure</th>
					<th xsl:use-attribute-sets="th" id="method">Method</th>
					<th xsl:use-attribute-sets="th" id="request">Request</th>
					<th xsl:use-attribute-sets="th" id="response">Response</th>
				</tr>
			</thead>
			<xsl:apply-templates select="wadl:resource" mode="wadl:summary"/>
		</table>
	</xsl:template>
	
	
	<!-- Place resources into 'conceptual' groupings. -->
	<xsl:template match="wadl:resource" mode="wadl:summary">
		<tbody>
			<xsl:apply-templates select="wadl:method" mode="wadl:methods">
				<xsl:with-param name="methodCount" select="count(wadl:method)"/>
			</xsl:apply-templates>
		</tbody>
	</xsl:template>
	
	
	<!-- Create a row for each method. As all methods have a parent URI, the URI
		 cell needs to span all method rows, as does its description. -->
	<xsl:template match="wadl:method" mode="wadl:methods">
		<xsl:param name="methodCount"/>
		
		<tr>
			<xsl:if test="position() = 1">
				<td xsl:use-attribute-sets="td" headers="description" rowspan="{$methodCount}">
					<xsl:value-of select="../wadl:doc"/>
				</td>
				<td xsl:use-attribute-sets="td" headers="uri" rowspan="{$methodCount}">
					<code class="requestURI">
						<!--<xsl:value-of select="../@path"/>-->
						<xsl:call-template name="wadl:processPathURI">
							<xsl:with-param name="resource" select="parent::wadl:resource"/>
						</xsl:call-template>
					</code>
				</td>
			</xsl:if>
			<td xsl:use-attribute-sets="td" headers="method">
				<code class="methodName"><xsl:value-of select="@name"/></code>
			</td>
			<td xsl:use-attribute-sets="td" headers="request">
				<xsl:apply-templates select="wadl:request" mode="wadl:request"/>
			</td>
			<td xsl:use-attribute-sets="td" headers="response">
				<xsl:apply-templates select="wadl:response" mode="wadl:response"/>
			</td>
		</tr>
	</xsl:template>
	
	
	<!-- Process path URI to resolve any URI Template variables. -->
	<xsl:template name="wadl:processPathURI">
		<xsl:param name="resource"/>
		<xsl:variable name="templateParams" select="$resource/wadl:param[@style = 'template']"/>
				
		<xsl:choose>
			<xsl:when test="not($resource/@path)">
				<xsl:value-of select="'/'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$resource/@path"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Returns a URI who's variables have been reolved with respect to the 
		 'template' params declared for the context resource. -->
	<xsl:template name="wadl:processURI">
		<xsl:param name="sourceURI"/>
		<xsl:param name="resultURI"/>
		<xsl:param name="templateParams"/>
		
		<xsl:choose>
			<xsl:when test="contains($sourceURI, '{')">
				<xsl:call-template name="wadl:processURI">
					<xsl:with-param name="sourceURI" select="substring-after($sourceURI, '}')"/>
					<xsl:with-param name="resultURI">
						<xsl:value-of select="$resultURI"/>
						<xsl:value-of select="substring-before($sourceURI, '{')"/>
						<xsl:call-template name="wadl:resolveVariable">
							<xsl:with-param name="variableName" select="substring-after(substring-before($sourceURI, '}'), '{')"/>
							<xsl:with-param name="templateParams" select="$templateParams"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="templateParams" select="$templateParams"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="concat($resultURI, '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="wadl:resolveVariable">
		<xsl:param name="variableName"/>
		<xsl:param name="templateParams"/>
		<xsl:variable name="contextParam" select="$templateParams[@name = $variableName]"/>
		
		<xsl:choose>
			<xsl:when test="$contextParam/@fixed">
				<xsl:text>&lt;span style="cursor:help;" title="Fixed"&gt;</xsl:text><xsl:value-of select="$contextParam/@fixed"/><xsl:text>&lt;/span&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&lt;em style="cursor:help;" title="Variable"&gt;</xsl:text><xsl:value-of select="$variableName"/><xsl:text>&lt;/em&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Request (Headers, Parameters and Body). -->
	<xsl:template match="wadl:request" mode="wadl:request">
		<div class="request">
			<div>
				<span>Headers:</span>
				<xsl:choose>
					<xsl:when test="wadl:param[@style = 'header']">
						<ul class="headers">
							<xsl:apply-templates select="wadl:param[@style = 'header']" mode="wadl:summary"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<em>Not Specified</em>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div>
				<span>Parameters:</span>
				<xsl:choose>
					<xsl:when test="wadl:param[@style = 'query']">
						<ul class="params">
							<xsl:apply-templates select="wadl:param[@style = 'query']" mode="wadl:summary"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<em>Not Specified</em>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div>
				<span>Body:</span>
				<xsl:choose>
					<xsl:when test="wadl:representation">
						<ul>
							<xsl:apply-templates select="wadl:representation" mode="wadl:request"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<em>Not Specified</em>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	
	
	<!-- Referenced request representation. -->
	<xsl:template match="wadl:*[@href]" mode="wadl:request" priority="2">
		<xsl:variable name="contextID" select="substring-after(@href, '#')"/>
		
		<xsl:apply-templates select="//wadl:*[@id = $contextID]" mode="wadl:request"/>
	</xsl:template>
	
	
	<!-- Request representation link to an example. -->
	<xsl:template match="wadl:representation[wadl:doc/xhtml:code]" priority="1" mode="wadl:request">
		<li>
			<a href="#{@ref}" title="Code example">
				<code><xsl:value-of select="@mediaType"/></code>
			</a>
		</li>
	</xsl:template>
	
	
	<!-- Request representation. -->
	<xsl:template match="wadl:representation" mode="wadl:request">
		<li>
			<code><xsl:value-of select="@mediaType"/></code>
		</li>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="wadl:response" mode="wadl:response">
		<div class="response">
		
			<div>
				<span>Status:</span> <xsl:value-of select="@status"/>
			</div>
			<div>
				<span>Headers:</span>
				<xsl:choose>
					<xsl:when test="wadl:param[@style = 'header']">
						<ul class="headers">
							<xsl:apply-templates select="wadl:param[@style = 'header']" mode="wadl:summary"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<em>Not Specified</em>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		
			<xsl:apply-templates select="wadl:representation" mode="wadl:response">
				<xsl:with-param name="parentNode" select="self::node()"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>
	
	
	<!-- Referenced response representations. -->
	<!-- <xsl:template match="wadl:representation[@href]" mode="wadl:response" priority="2">
		<xsl:variable name="contextID" select="substring-after(@href, '#')"/>
		
		<xsl:apply-templates select="//wadl:*[@id = $contextID]" mode="wadl:response">
			<xsl:with-param name="parentNode" select="parent::node()"/>
		</xsl:apply-templates>
	</xsl:template> -->
	
	
	<!-- The response information. -->
	<xsl:template match="wadl:representation" mode="wadl:response">
		<xsl:param name="parentNode"/>
		
		<div>
			<span>Body:</span>
			<xsl:choose>
				<xsl:when test="@mediaType">
					<a>
						<xsl:if test="wadl:doc[xhtml:code]">
							<xsl:attribute name="href">
								<xsl:value-of select="concat('#', @ref)"/>
							</xsl:attribute>
							<xsl:attribute name="title">Code Example</xsl:attribute>
						</xsl:if>
						<code><xsl:value-of select="@mediaType"/></code>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<em>Not Specified</em>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	
	<!-- Parameter list items. -->
	<xsl:template match="wadl:param[contains('|query|header|', @style)]" mode="wadl:summary">
		<xsl:variable name="paramClass">
			<xsl:choose>
				<xsl:when test="@style = 'query'">
					<xsl:value-of select="'param'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@style"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<li><code class="{$paramClass}Name"><xsl:value-of select="@name"/></code></li>
	</xsl:template>
	
	
	
	
	
	
	<!-- === Service Details - 2. ========================================== -->
	
	<!--  -->
	<xsl:template match="wadl:resources" mode="wadl:detail2">
		<xsl:apply-templates select="wadl:resource" mode="wadl:detail2"/>
	</xsl:template>
	
	
	
	
	<!-- Creates a table for each resource detail. -->
	<xsl:template match="wadl:resource" mode="wadl:detail2">
		<h3><a name="{translate($PAGE_TITLE, ' ', '')}-{translate(wadl:doc[1]/text(), ' ', '')}"></a><xsl:value-of select="wadl:doc[1]"/></h3>
		<table xsl:use-attribute-sets="table" summary="Web Service API Resource Details">
			<thead>
				<tr>
					<th xsl:use-attribute-sets="th"><strong>URI</strong></th>
					<th colspan="4" xsl:use-attribute-sets="th">
						<code><xsl:value-of select="concat(../@base, @path)"/></code>
					</th>
				</tr>
			</thead>
			<tbody>
				<xsl:variable name="templateParams" select="ancestor-or-self::*/wadl:param[@style = 'template']"/>
				<xsl:apply-templates select="$templateParams" mode="wadl:detail-template-params">
					<xsl:with-param name="paramCount" select="count($templateParams)"/>
				</xsl:apply-templates>
				<tr>
					<td xsl:use-attribute-sets="td"><strong>Methods</strong></td>
					<td colspan="4" xsl:use-attribute-sets="td">
						<xsl:apply-templates select="wadl:method" mode="wadl:methodNames"/>
					</td>
				</tr>
				<xsl:apply-templates select="wadl:method" mode="wadl:detail2"/>
			</tbody>
		</table>
	</xsl:template>
	
	
	<xsl:template match="wadl:method" mode="wadl:methodNames">
		<a href="#{generate-id()}" title="Jump to method"><xsl:value-of select="@name"/></a><xsl:if test="position() != last()">, </xsl:if>
	</xsl:template>
	
	
	<xsl:template match="wadl:param[@style = 'template']" mode="wadl:detail-template-params">
		<xsl:param name="paramCount"/>
		
		<tr>
			<xsl:if test="position() = 1">
				<td rowspan="{$paramCount}" xsl:use-attribute-sets="td"><strong>URI-Template Params</strong></td>
			</xsl:if>
			<td xsl:use-attribute-sets="td"><xsl:value-of select="@name"/></td>
			<td colspan="3" xsl:use-attribute-sets="td">
				<xsl:call-template name="wadl:paramDetails"/>
			</td>
		</tr>
	</xsl:template>
		
	
	<xsl:template match="wadl:method" mode="wadl:detail2">
		<xsl:variable name="requestHeaderParamCount">
			<xsl:choose>
				<xsl:when test="wadl:request/wadl:param[@style = 'header']">
					<xsl:value-of select="count(wadl:request/wadl:param[@style = 'header'])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="requestQueryParamCount">
			<xsl:choose>
				<xsl:when test="wadl:request/wadl:param[@style = 'query']">
					<xsl:value-of select="count(wadl:request/wadl:param[@style = 'query'])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="responseHeaderParamCount">
			<xsl:call-template name="wadl:countResponseParams">
				<xsl:with-param name="count" select="0"/>
				<xsl:with-param name="responseNode" select="wadl:response[1]"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="responseRows">
			<xsl:choose>
				<xsl:when test="count(wadl:response/wadl:param[@style = 'header']) = 0">
					<xsl:value-of select="count(wadl:response) * 2"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(wadl:response) + $responseHeaderParamCount"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="rowCount" select="1 + $requestHeaderParamCount + 
				$requestQueryParamCount + $responseRows"/>
		
		<tr>
			<td id="{generate-id()}" rowspan="{$rowCount + 1}" xsl:use-attribute-sets="td">
				<strong><xsl:value-of select="@name"/></strong>
			</td>
			<td colspan="4" xsl:use-attribute-sets="td">
				<xsl:choose>
					<xsl:when test="wadl:doc">
						<em><xsl:value-of select="wadl:doc"/></em>
					</xsl:when>
					<xsl:otherwise>
						<em style="color:red">*Documentation is required for this component.</em>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
		
		<!-- Request. -->
		<xsl:apply-templates select="wadl:request" mode="wadl:detail2">
			<xsl:with-param name="requestHeaderParamCount" select="$requestHeaderParamCount"/>
			<xsl:with-param name="requestQueryParamCount" select="$requestQueryParamCount"/>
		</xsl:apply-templates>
		
		<!-- Response. -->
		<xsl:apply-templates select="wadl:response" mode="wadl:detail2"/>
	</xsl:template>
	
	
	<!-- Recursively accumulate the number of  -->
	<xsl:template name="wadl:countResponseParams">
		<xsl:param name="count"/>
		<xsl:param name="responseNode"/>
		<xsl:variable name="paramCount">
			<xsl:choose>
				<xsl:when test="count($responseNode/wadl:param[@style = 'header']) = 0">
					<xsl:value-of select="1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count($responseNode/wadl:param[@style = 'header'])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$responseNode/following-sibling::wadl:response">
				<xsl:call-template name="wadl:countResponseParams">
					<xsl:with-param name="count" select="$count + $paramCount"/>
					<xsl:with-param name="responseNode" select="$responseNode/following-sibling::wadl:response"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$count + $paramCount"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="wadl:paramDetails">
		<div>
			<xsl:choose>
				<xsl:when test="wadl:doc[text()]">
					<em><xsl:value-of select="wadl:doc"/></em>
				</xsl:when>
				<xsl:otherwise>
					<em style="color:red">*Documentation is required for this component.</em>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<xsl:if test="@required = 'true'">
			<div>Required: Yes</div>
		</xsl:if>
		<xsl:if test="@fixed">
			<div>Fixed: '<xsl:value-of select="@fixed"/>'</div>
		</xsl:if>
		<xsl:if test="@default">
			<div>Default: '<xsl:value-of select="@default"/>'</div>
		</xsl:if>
		<xsl:if test="wadl:option">
			<xsl:variable name="options">
				<xsl:for-each select="wadl:option">
					<xsl:value-of select="@value"/>
					<xsl:if test="position() != last()">|</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<div>Options: (<xsl:value-of select="$options"/>)</div>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Generates request detail rows. -->
	<xsl:template match="wadl:request" mode="wadl:detail2">
		<xsl:param name="requestHeaderParamCount"/>
		<xsl:param name="requestQueryParamCount"/>
		
		<tr>
			<!-- 1 body row plus 'n' header and query param rows. -->
			<td rowspan="{1 + $requestHeaderParamCount + $requestQueryParamCount}" xsl:use-attribute-sets="td"><strong>Request</strong></td>
			<td rowspan="{$requestHeaderParamCount}" xsl:use-attribute-sets="td"><strong>Headers</strong></td>
			<xsl:choose>
				<xsl:when test="wadl:param[@style='header']">
					<xsl:apply-templates select="wadl:param[@style='header'][1]" mode="wadl:detail-header-params"/>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="2" xsl:use-attribute-sets="td">
						<em>Not Specified</em>
					</td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
		<xsl:apply-templates select="wadl:param[@style='header'][position() &gt; 1]" mode="wadl:wrapped-detail-header-params"/>
		
		<tr>
			<xsl:variable name="requestQueryParams" select="wadl:param[@style='query']"/>
			
			<td xsl:use-attribute-sets="td"><strong>Parameters</strong></td>
			<xsl:choose>
				<xsl:when test="$requestQueryParams">
					<xsl:apply-templates select="$requestQueryParams" mode="wadl:detail-query-params"/>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="2" xsl:use-attribute-sets="td">
						<em>Not Specified</em>
					</td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
		<tr>
			<td xsl:use-attribute-sets="td"><strong>Body</strong></td>
			<xsl:choose>
				<xsl:when test="wadl:representation">
					<td colspan="2" xsl:use-attribute-sets="td">
						<ul>
							<xsl:apply-templates select="wadl:representation" mode="wadl:detail2"/>
						</ul>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="2" xsl:use-attribute-sets="td"><em>Not Specified</em></td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>
	
	
	<xsl:template match="wadl:response" mode="wadl:detail2">
		<xsl:variable name="responseHeaderParamCount">
			<xsl:choose>
				<xsl:when test="count(wadl:param[@style = 'header']) = 0">
					<xsl:value-of select="1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(wadl:param[@style = 'header'])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<tr>
			<!-- 1 body row plus 'n' header and query param rows. -->
			<td rowspan="{1 + $responseHeaderParamCount}" xsl:use-attribute-sets="td"><strong>Response: <xsl:value-of select="@status"/></strong></td>
			<td rowspan="{$responseHeaderParamCount}" xsl:use-attribute-sets="td"><strong>Headers</strong></td>
			
			<xsl:choose>
				<xsl:when test="wadl:param[@style='header']">
					<xsl:apply-templates select="wadl:param[@style='header'][1]" mode="wadl:detail-header-params"/>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="2" xsl:use-attribute-sets="td">
						<em>Not Specified</em>
					</td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>

		<xsl:apply-templates select="wadl:param[@style='header'][position() &gt; 1]" mode="wadl:wrapped-detail-header-params"/>
		
		<tr>
			<td xsl:use-attribute-sets="td"><strong>Body</strong></td>
			<xsl:choose>
				<xsl:when test="wadl:representation">
					<td colspan="2" xsl:use-attribute-sets="td">
						<ul>
							<xsl:apply-templates select="wadl:representation" mode="wadl:detail2"/>
						</ul>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="2" xsl:use-attribute-sets="td"><em>Not Specified</em></td>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>
	
	
	<!-- Wraps the two table-cells for header name/details in a table-row. -->
	<xsl:template match="wadl:param[@style = 'header']" mode="wadl:wrapped-detail-header-params">
		<tr>
			<xsl:apply-templates select="self::node()" mode="wadl:detail-header-params"/>
		</tr>
	</xsl:template>
	
	
	<!-- Naked table-cells for header name/details. -->
	<xsl:template match="wadl:param[@style = 'header']" mode="wadl:detail-header-params">
		<td xsl:use-attribute-sets="td"><xsl:value-of select="@name"/></td>
		<td xsl:use-attribute-sets="td">
			<xsl:call-template name="wadl:paramDetails"/>
		</td>
	</xsl:template>
	
	
	<!-- Wraps the two table-cells for query name/details in a table-row. -->
	<xsl:template match="wadl:param[@style = 'query']" mode="wadl:wrapped-detail-query-params">
		<tr>
			<xsl:apply-templates select="self::node()" mode="wadl:detail-query-params"/>
		</tr>
	</xsl:template>
	
	
	<!-- Naked table-cells for query name/details. -->
	<xsl:template match="wadl:param[@style = 'query']" mode="wadl:detail-query-params">
		<td xsl:use-attribute-sets="td"><xsl:value-of select="@name"/></td>
		<td xsl:use-attribute-sets="td">
			<xsl:call-template name="wadl:paramDetails"/>
		</td>
	</xsl:template>
	
	
	<xsl:template match="wadl:representation[@href]" mode="wadl:detail2" priority="1">
		<xsl:variable name="fragId" select="substring-after(@href, '#')"/>
		
		<xsl:apply-templates select="//wadl:representation[@id = $fragId]" mode="wadl:detail2"/>
	</xsl:template>
	
	
	<xsl:template match="wadl:representation[@mediaType]" mode="wadl:detail2">
		<li>
			<code><xsl:value-of select="@mediaType"/></code>
			<xsl:if test="wadl:param">
				<ul>
					<xsl:apply-templates select="wadl:param" mode="wadl:representation-param"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="wadl:representation[not(@mediaType)]" mode="wadl:detail2">
		<li>
			<em>Not Specified</em>
		</li>
	</xsl:template>
		
	
	
	
	<!--  -->
	<xsl:template match="wadl:param[@href]" mode="wadl:representation-param" priority="1">
		<xsl:variable name="fragId" select="substring-after(@href, '#')"/>
		
		<xsl:apply-templates select="//wadl:param[@id = $fragId]" mode="wadl:representation-param"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="wadl:param[@style = 'query']" mode="wadl:representation-param">
		<li>
			<span><xsl:value-of select="@name"/>:</span>
			<xsl:call-template name="wadl:paramDetails"/>
		</li>
	</xsl:template>
	
	
	
	
	<!-- === Examples. ===================================================== -->
	
	<!-- Example representation mark-up. -->
	<xsl:template match="wadl:representation[wadl:doc/xhtml:code]" mode="wadl:examples">
		<div id="{@id}">
			<xsl:apply-templates select="*" mode="wadl:examples"/>
		</div>
	</xsl:template>
	
	
	<!-- Example documentation. -->
	<xsl:template match="wadl:doc[xhtml:code]" mode="wadl:examples">
		<h4><a name="{generate-id()}"></a><xsl:value-of select="@title"/></h4>
		<xsl:choose>
			<xsl:when test="text()">
				<p><xsl:value-of select="text()"/></p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*" mode="wadl:examples"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- All nodes not in the WADL namespace are to be treated as example mark-up. -->
	<xsl:template match="xhtml:code" mode="wadl:examples">
		<div class="code panel" style="border-width: 1px;">
			<div class="codeContent panelContent">
<pre class="code-java">
	<xsl:for-each select="* | text()">
		<xsl:call-template name="xml-to-string"/>
	</xsl:for-each>
</pre>
			</div>
		</div>
	</xsl:template>
	
	
	<!-- Ignore text nodes in these modes. -->
	<xsl:template match="text()" mode="wadl:detail"/>
	<xsl:template match="text()" mode="wadl:detail2"/>
	<xsl:template match="text()" mode="wadl:doc"/>
	<xsl:template match="text()" mode="wadl:examples"/>
	
</xsl:stylesheet>