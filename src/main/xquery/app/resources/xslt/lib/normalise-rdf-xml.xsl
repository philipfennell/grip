<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns:err="http://www.marklogic.com/rdf/error"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	
	<!-- Normalises RDF/XML into some form of canonical representation. -->
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/rdf+xml" method="xml"/>
	
	<xsl:param name="BASE_URI" as="xs:string" select="base-uri(/*)"/>
	
	
	
	
	<!-- Document root. -->
	<xsl:template match="/" priority="2">
		<xsl:apply-templates select="*" mode="rdf"/>
	</xsl:template>
	
	
	<!-- The RDF root. -->
	<xsl:template match="/rdf:RDF" mode="rdf" priority="1">
		<xsl:copy>
			<xsl:copy-of select="@* except (@xml:base)"/>
			<xsl:apply-templates select="*" mode="rdf:node-elements"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Root element that's not rdf:RDF. -->
	<xsl:template match="/*" mode="rdf">
		<rdf:RDF>
			<xsl:apply-templates select="." mode="rdf:node-elements"/>
		</rdf:RDF>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:Bag | rdf:Seq | rdf:Alt" mode="rdf:node-elements" priority="3">
		<rdf:Description>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about | @rdf:ID)), @rdf:nodeID, rdf:generate-node-id-attr(.))[1]"/>
			<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			<xsl:apply-templates select="*" mode="rdf:container"/>
		</rdf:Description>	
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*[rdf:is-typed-element-node(.)][rdf:li]" mode="rdf:node-elements" priority="3">
		<rdf:Description>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about | @rdf:ID)), @rdf:nodeID, rdf:generate-node-id-attr(.))[1]"/>
			<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			<xsl:apply-templates select="*" mode="rdf:container"/>
		</rdf:Description>	
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:li" mode="rdf:container rdf:node-elements rdf:property-elements" priority="3">
		<xsl:element name="rdf:_{count(preceding-sibling::rdf:li) + 1}">
			<xsl:apply-templates select="* | text()" mode="rdf:node-elements"/>
		</xsl:element>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:li[@rdf:resource]" mode="rdf:container rdf:node-elements rdf:property-elements" priority="4">
		<xsl:element name="rdf:_{count(preceding-sibling::rdf:li) + 1}">
			<xsl:copy-of select="@rdf:resource"/>
		</xsl:element>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:li[rdf:Description]" mode="rdf:container rdf:property-elements" priority="3">
		<xsl:element name="rdf:_{count(preceding-sibling::rdf:li) + 1}">
			<xsl:attribute name="rdf:nodeID" select="generate-id(rdf:Description)"/>
		</xsl:element>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:*[matches(local-name(), '_\d+')]" mode="rdf:container">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="rdf:node-elements"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Node Elements with no child Node ELements. -->
	<xsl:template match="rdf:Description[not(*)]" mode="rdf:node-elements" priority="2">
		<xsl:copy>
			<xsl:copy-of select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), rdf:generate-node-id-attr(..))[1]"/>
			<xsl:copy-of select="@xml:*"/>
			<xsl:apply-templates select="@* except (@rdf:about, @rdf:ID, @rdf:nodeID, @xml:*)" mode="rdf:property-attributes"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Node Elements. -->
	<xsl:template match="rdf:Description" mode="rdf:node-elements" priority="1">
		<xsl:param name="nodeIDAttr" as="attribute()?" select="@rdf:nodeID"/>
		<xsl:variable name="subjectAttr" as="attribute()" 
				select="(rdf:resolve-uri-reference((@rdf:about | @rdf:ID)), $nodeIDAttr, rdf:generate-node-id-attr(.))[1]"/>
		
		<xsl:copy>
			<xsl:copy-of select="$subjectAttr"/>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="rdf:property-attributes"/>
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
		</xsl:copy>
		<xsl:apply-templates select="*[element()]" mode="rdf:referred-node-element"/>
		<xsl:apply-templates select="*" mode="rdf:reify-if-required">
			<xsl:with-param name="subjectAttr" as="attribute()" select="$subjectAttr"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="*" mode="rdf:property-elements-property-attributes"/>
	</xsl:template>
	
	
	<!-- Other elements in the RDF namespace that aren't rdf:Description. -->
	<xsl:template match="rdf:*" mode="rdf:node-elements">
		<xsl:param name="nodeIDAttr" as="attribute()?">
			<xsl:attribute name="nodeID" select="generate-id(..)"/>
		</xsl:param>
		<xsl:variable name="subjectAttr" as="attribute()" 
				select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), $nodeIDAttr)[1]"/>
		
		<rdf:Description>
			<xsl:copy-of select="$subjectAttr"/>
			<xsl:if test="not(../*[@rdf:parseType eq 'Resource'])">
				<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			</xsl:if>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="rdf:property-attributes"/>
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
		</rdf:Description>
		<xsl:apply-templates select="*[element()]" mode="rdf:referred-node-element"/>
		<xsl:apply-templates select="*" mode="rdf:reify-if-required">
			<xsl:with-param name="subjectAttr" as="attribute()" select="$subjectAttr"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!-- Typed Element Nodes. -->
	<xsl:template match="*[rdf:is-typed-element-node(.)]" mode="rdf:node-elements">
		<xsl:param name="nodeIDAttr" as="attribute()?">
			<xsl:attribute name="rdf:nodeID" select="generate-id(..)"/>
		</xsl:param>
		<xsl:variable name="subjectAttr" as="attribute()" 
				select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), $nodeIDAttr)[1]"/>
		
		<rdf:Description>
			<xsl:copy-of select="$subjectAttr"/>
			<xsl:if test="not(../*[@rdf:parseType eq 'Resource'])">
				<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			</xsl:if>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="rdf:property-attributes"/>
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
		</rdf:Description>
		<xsl:apply-templates select="*[element()]" mode="rdf:referred-node-element"/>
		<xsl:apply-templates select="*" mode="rdf:reify-if-required">
			<xsl:with-param name="subjectAttr" as="attribute()" select="$subjectAttr"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!-- Typed Element Nodes. -->
	<xsl:template match="*[rdf:is-typed-element-node(.)]" mode="rdf:typed-node-elements">
		<xsl:param name="nodeIDAttr" as="attribute()?">
			<xsl:attribute name="rdf:nodeID" select="generate-id(..)"/>
		</xsl:param>
		<xsl:variable name="subjectAttr" as="attribute()" 
				select="(rdf:resolve-uri-reference((@rdf:about|@rdf:ID)), $nodeIDAttr)[1]"/>
		
		<rdf:Description>
			<xsl:copy-of select="$subjectAttr"/>
			<xsl:if test="not(../*[@rdf:parseType eq 'Resource'])">
				<rdf:type rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			</xsl:if>
		</rdf:Description>
	</xsl:template>
	
	
	<!-- Expand property attributes into property elements. -->
	<xsl:template match="@rdf:type" mode="rdf:property-attributes">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:attribute name="rdf:resource" select="."/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- Expand property attributes into property elements. -->
	<xsl:template match="@*" mode="rdf:property-attributes">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- rdfms-seq-representation/test001 ??? -->
	<xsl:template match="rdf:type[@rdf:parseType eq 'Resource']" mode="rdf:property-elements" priority="3">
		<xsl:copy>
			<xsl:attribute name="rdf:nodeID" select="generate-id(.)"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Resource References -->
	<xsl:template match="*[@rdf:resource][not(*)]" mode="rdf:property-elements" priority="2">
		<xsl:copy>
			<xsl:copy-of select="rdf:resolve-uri-reference(@rdf:resource)"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Collections. -->
	<xsl:template match="*[@rdf:parseType = 'Collection']" mode="rdf:property-elements" priority="3">
		<xsl:copy>
			<xsl:if test="not(@rdf:nodeID)">
				<xsl:attribute name="rdf:nodeID" select="generate-id(*[1])"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[rdf:is-typed-element-node(.) and *[@rdf:about]]" mode="rdf:property-elements" priority="2">
		<xsl:copy>
			<xsl:attribute name="rdf:resource" select="rdf:resolve-uri(*/@rdf:about)"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[rdf:Description[@rdf:about]]" mode="rdf:property-elements" priority="2">
		<xsl:copy>
			<xsl:attribute name="rdf:resource" select="rdf:Description/@rdf:about"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[rdf:Description[@rdf:nodeID]]" mode="rdf:property-elements" priority="2">
		<xsl:copy>
			<xsl:attribute name="rdf:nodeID" select="generate-id(rdf:Description)"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- XML Literals. -->
	<xsl:template match="*[@rdf:parseType = 'Literal'][element()]" mode="rdf:property-elements" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="rdf:literal-attributes"/>
			<xsl:copy-of select="* | text()" copy-namespaces="yes"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Generate reference to a Resource. -->
	<xsl:template match="*[@rdf:parseType eq 'Resource']" mode="rdf:property-elements" priority="2">
		<xsl:copy>
			<xsl:copy-of select="@rdf:parseType"/>
			<xsl:if test="not(@rdf:nodeID)">
				<xsl:attribute name="rdf:nodeID" select="generate-id()"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Property Elements with Property Attributes. -->
	<xsl:template match="*[not(* | text())][@* except (@rdf:*, @xml:*)]" mode="rdf:property-elements" priority="1">
		<xsl:copy>
			<xsl:attribute name="rdf:nodeID" select="generate-id()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Typed and Plain Literals -->
	<xsl:template match="*[not(element())]" mode="rdf:property-elements">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="rdf:literal-attributes"/>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Ignore lists in this mode. -->
	<xsl:template match="rdf:List | rdf:li | *[@rdf:parseType eq 'Collection']" mode="rdf:property-elements-property-attributes" priority="1"/>
	
	
	<!-- Ignore element and typed element nodes that have only RDF attributes. -->
	<xsl:template match="*[not(exists(@* except (@rdf:*)))]" mode="rdf:property-elements-property-attributes" priority="2"/>
	 
	
	<!-- Property Elements with Property Attributes. -->
	<xsl:template match="*[@*[contains(name(), ':')]][not(@xml:* | @rdf:datatype | @rdf:nodeID | @rdf:parseType)]" mode="rdf:property-elements-property-attributes">
		<rdf:Description>
			<xsl:choose>
				<xsl:when test="@rdf:resource">
					<xsl:attribute name="rdf:about" select="@rdf:resource"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="rdf:nodeID" select="generate-id()"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="@* except (@rdf:*, @xml:*)" mode="#current"/>
		</rdf:Description>
	</xsl:template>
	
	
	<!-- Empty Property Elements require reification. -->
	<xsl:template match="*[@rdf:ID][not(* | text())]" mode="rdf:reify-if-required">
		<xsl:param name="subjectAttr" as="attribute()"/>
		
		<rdf:Description rdf:about="{rdf:resolve-uri-reference(@rdf:ID)}">
			<rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement"/>
			<rdf:subject>
				<xsl:choose>
					<xsl:when test="$subjectAttr instance of attribute(rdf:nodeID)">
						<xsl:copy-of select="$subjectAttr"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="rdf:resource" select="string($subjectAttr)"></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</rdf:subject>
			<rdf:predicate rdf:resource="{concat(namespace-uri-from-QName(resolve-QName(name(), .)), local-name())}"/>
			<xsl:choose>
				<xsl:when test="@rdf:parseType eq 'Resource'">
					<rdf:object>
						<xsl:copy-of select="rdf:generate-node-id-attr(.)"/>
					</rdf:object>
				</xsl:when>
				<xsl:when test="@rdf:nodeID">
					<rdf:object>
						<xsl:copy-of select="@rdf:nodeID"/>
					</rdf:object>
				</xsl:when>
				<xsl:otherwise>
					<rdf:object/>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:Description>
	</xsl:template>
	
	
	<!-- Expand datatype references on literals. -->
	<xsl:template match="@rdf:datatype" mode="rdf:literal-attributes">
		<xsl:attribute name="{name()}">
			<xsl:choose>
				<xsl:when test="starts-with(., 'xs:')">
					<xsl:value-of select="concat('http://www.w3.org/2001/XMLSchema#', substring-after(., 'xs:'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	
	<!-- Replicate all other literal attributes (normally just @xml:lang) -->
	<xsl:template match="@*" mode="rdf:literal-attributes">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<!-- Property Attributes on Property Elements. -->
	<xsl:template match="@*" mode="rdf:property-elements-property-attributes">
		<xsl:element name="{name()}" namespace="{namespace-uri()}">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- rdfms-seq-representation/test001 ??? -->
	<xsl:template match="rdf:type[@rdf:parseType eq 'Resource'][element()]" mode="rdf:referred-node-element" priority="2">
		<rdf:Description rdf:nodeID="{generate-id(.)}">
			<xsl:apply-templates select="*" mode="rdf:property-elements"/>
		</rdf:Description>
		<xsl:apply-templates select="*" mode="rdf:referred-node-element"/>
	</xsl:template>
	
	
	<!-- Prevent processing of Resources on type declarations.
	<xsl:template match="rdf:type[@rdf:parseType eq 'Resource']" mode="rdf:referred-node-element" priority="2"/> -->
	
	
	<!-- Prevent processing of XML Literals as RDF/XML. -->
	<xsl:template match="*[@rdf:parseType eq 'Literal']" mode="rdf:referred-node-element" priority="2"/>
	
	
	<!-- RDF Collections -->
	<xsl:template match="*[@rdf:parseType eq 'Collection']" mode="rdf:referred-node-element" priority="2">
		<xsl:apply-templates select="*" mode="rdf:collection"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:Description[following-sibling::rdf:Description]" mode="rdf:collection">
		<rdf:Description rdf:nodeID="{generate-id(.)}">
			<rdf:first rdf:resource="{@rdf:about}"/>
			<rdf:rest rdf:nodeID="{generate-id(following-sibling::rdf:Description[1])}"/>
		</rdf:Description>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="rdf:Description[not(following-sibling::rdf:Description)]" mode="rdf:collection">
		<rdf:Description rdf:nodeID="{generate-id(.)}">
			<rdf:first rdf:resource="{@rdf:about}"/>
			<rdf:rest rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"/>
		</rdf:Description>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*[rdf:is-typed-element-node(*) and */@rdf:about]" mode="rdf:referred-node-element" priority="2">
		<xsl:apply-templates select="*" mode="rdf:typed-node-elements">
			<xsl:with-param name="nodeIDAttr" as="attribute()?">
				<xsl:attribute name="rdf:about" select="rdf:resolve-uri(*/@rdf:about)"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="*[not(rdf:Description)]" mode="rdf:referred-node-element" priority="1">
		<xsl:apply-templates select="." mode="rdf:node-elements">
			<xsl:with-param name="nodeIDAttr" as="attribute()?">
				<!-- When the rdf:Description is a child of a Typed Property Element ignore its rdf:nodeID. -->
				<xsl:attribute name="rdf:nodeID" select="(if (@rdf:*) then () else @rdf:nodeID, generate-id())[1]"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!-- Suppress unwanted text nodes. -->
	<xsl:template match="text()" mode="rdf:referred-node-element rdf:reify-if-required rdf:property-elements rdf:property-elements-property-attributes"/>
	
	
	<!-- Resolves a relative URI against the xml:base or the Static Base URI 
		 if no @xml:base can be found. -->
	<xsl:function name="rdf:resolve-uri" as="xs:string">
		<xsl:param name="uriAttr" as="attribute()"/>
		<xsl:variable name="baseURI" as="xs:anyURI" select="xs:anyURI(($uriAttr/ancestor-or-self::*[@xml:base][1]/@xml:base, $BASE_URI)[1])"/>
		
		<xsl:choose>
			<!-- Deal with fragment identifiers. -->
			<xsl:when test="$uriAttr instance of attribute(rdf:ID)">
				<xsl:value-of select="resolve-uri(concat('#', string($uriAttr)), $baseURI)"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Ensure that http://example.com is resolved as http://example.com/ -->
				<xsl:choose>
					<xsl:when test="matches($baseURI, '/\w+/?$')">
						<xsl:value-of select="resolve-uri(string($uriAttr), $baseURI)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="resolve-uri(string($uriAttr), concat($baseURI, if (starts-with(string($uriAttr), '#')) then '' else '/'))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- Process URI references (absolute or relative to an xml:base). -->
	<xsl:function name="rdf:resolve-uri-reference" as="attribute()?">
		<xsl:param name="refAttr" as="attribute()?"/>
		
		<xsl:apply-templates select="$refAttr" mode="rdf:ref-attr"/>
	</xsl:function>
	
	
	<!-- Copy the about attribute. -->
	<xsl:template match="@rdf:about" mode="rdf:ref-attr">
		<xsl:attribute name="rdf:about" select="rdf:resolve-uri(.)"/>
	</xsl:template>
	
	
	<!-- Resolve the relative URI in the ID attribute. -->
	<xsl:template match="@rdf:ID" mode="rdf:ref-attr">
		<xsl:attribute name="rdf:about" select="rdf:resolve-uri(.)"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="@rdf:resource" mode="rdf:ref-attr">
		<xsl:attribute name="rdf:resource" select="rdf:resolve-uri(.)"/>
	</xsl:template>
	
	
	<!-- Generates an rdf:nodeID attribute with ID value with respect to the passed context node. -->
	<xsl:function name="rdf:generate-node-id-attr" as="attribute(rdf:nodeID)">
		<xsl:param name="contextNode" as="node()"/>
		
		<xsl:attribute name="rdf:nodeID" select="generate-id($contextNode)"/>
	</xsl:function>
	
	
	<!-- Returns true if the context node is not in the RDF namespace. -->
	<xsl:function name="rdf:is-typed-element-node" as="xs:boolean">
		<xsl:param name="contextNode" as="element()"/>
		
		<xsl:value-of select="namespace-uri-from-QName(resolve-QName(name($contextNode), $contextNode)) ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'"/>
	</xsl:function>
	
	
	
	
	<!-- === Errors or Unsupported. ======================================== -->
	
	
</xsl:transform>