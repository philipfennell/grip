<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/ns/formats/Turtle"
		xmlns:err="http://www.marklogic.com/rdf/error"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:ttl="http://www.w3.org/ns/formats/Turtle"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:trix="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:xdmp="http://marklogic.com/xdmp"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="#all"
		version="2.0">
	
	<xsl:strip-space elements="*"/>
	
	<xsl:output encoding="UTF-8" indent="yes" media-type="application/xml" method="xml"/>
	
	<xsl:param name="GRAPH_URI" as="xs:string" select="'#default'"/>
	
	
	
	
	<!--  -->
	<xsl:template match="/">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template match="ttl:RDF">
		<turtle-doc>
			<xsl:call-template name="ttl:parse-statements">
				<xsl:with-param name="turtleDoc" as="xs:string" select="."/>
			</xsl:call-template>
		</turtle-doc>
		<!--<xsl:value-of select="ttl:match-turtle-doc()" disable-output-escaping="yes"/>-->
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-statements">
		<xsl:param name="turtleDoc" as="xs:string"/>
		<!-- Directives: -->
		<!-- Prefixes. -->
		
		<xsl:message>[XSLT] turtleDoc: &#10;<xsl:value-of select="$turtleDoc"/>&#10;</xsl:message>
		<xsl:analyze-string select="$turtleDoc" regex="{concat(ttl:match-prefix-id(), ttl:match-ws('*'), '\.', ttl:match-ws('*'))}">
			<xsl:matching-substring>
				<statement>
					<directive>
						<prefix-id>
							<prefix-name><xsl:value-of select="ttl:get-prefix-name(regex-group(2))"/></prefix-name>
							<uriref><xsl:value-of select="regex-group(6)"/></uriref>
						</prefix-id>
					</directive>
				</statement>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<!-- Base URI. -->
				<xsl:analyze-string select="string(.)" regex="{concat(ttl:match-base(), ttl:match-ws('*'), '\.', ttl:match-ws('*'))}">
					<xsl:matching-substring>
						<base><uriref><xsl:value-of select="ttl:get-uri(regex-group(2))"/></uriref></base>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<!-- Triples. -->
						<xsl:call-template name="ttl:parse-triples">
							<xsl:with-param name="triples" as="xs:string" select="."/>
						</xsl:call-template>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-triples">
		<xsl:param name="triples" as="xs:string"/>
		
		<xsl:message>[XSLT] triples: &#10;<xsl:value-of select="$triples"/>&#10;</xsl:message>
		<xsl:analyze-string select="$triples" regex="{ttl:match-triples()}">
			<xsl:matching-substring>
				<statement>
					<triple>
						<xsl:call-template name="ttl:parse-subject">
							<xsl:with-param name="subject" select="regex-group(1)"/>
						</xsl:call-template>
						<xsl:call-template name="ttl:parse-predicate-object-list">
							<xsl:with-param name="predicateObjectList" as="xs:string" select="regex-group(438)"/>
						</xsl:call-template>
					</triple>
					<!--<xsl:value-of select="ttl:match-triples()" disable-output-escaping="yes"/>-->
				</statement>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-subject">
		<xsl:param name="subject" as="xs:string"/>
		
		<xsl:message>[XSLT] subject: &#10;<xsl:value-of select="$subject"/>&#10;</xsl:message>
		<subject>
			<xsl:analyze-string select="$subject" regex="{ttl:match-subject()}">
				<xsl:matching-substring>
					<xsl:call-template name="ttl:parse-resource">
						<xsl:with-param name="resource" select="regex-group(0)"/>
					</xsl:call-template>
				</xsl:matching-substring>
				<xsl:non-matching-substring/>
			</xsl:analyze-string>
			<xsl:analyze-string select="$subject" regex="{ttl:match-blank()}">
				<xsl:matching-substring>
					<xsl:call-template name="ttl:parse-blank">
						<xsl:with-param name="blank" select="regex-group(0)"/>
					</xsl:call-template>
				</xsl:matching-substring>
				<xsl:non-matching-substring/>
			</xsl:analyze-string>
		</subject>
		<!--<xsl:value-of select="ttl:match-subject()"/>-->
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-resource">
		<xsl:param name="resource" as="xs:string"/>
		
		<xsl:message>[XSLT] resource: &#10;<xsl:value-of select="$resource"/>&#10;</xsl:message>
		<xsl:analyze-string select="$resource" regex="{ttl:match-resource()}">
			<xsl:matching-substring>
				<resource>
					<xsl:analyze-string select="regex-group(0)" regex="{ttl:match-uriref()}">
						<xsl:matching-substring>
							<uriref><xsl:value-of select="regex-group(2)"/></uriref>
						</xsl:matching-substring>
						<xsl:non-matching-substring/>
					</xsl:analyze-string>
					<xsl:analyze-string select="regex-group(0)" regex="{ttl:match-qname()}">
						<xsl:matching-substring>
							<qname>
								<xsl:call-template name="ttl:parse-qname">
									<xsl:with-param name="qname" select="."/>
								</xsl:call-template>
							</qname>
						</xsl:matching-substring>
						<xsl:non-matching-substring/>
					</xsl:analyze-string>
				</resource>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-blank">
		<xsl:param name="blank" as="xs:string"/>
		<xsl:message>[XSLT] blank: &#10;<xsl:value-of select="$blank"/>&#10;</xsl:message>
		
		<blank></blank>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-qname">
		<xsl:param name="qname" as="xs:string"/>
		
		<xsl:message>[XSLT] qname: &#10;<xsl:value-of select="$qname"/>&#10;</xsl:message>
		<xsl:analyze-string select="$qname" regex="{ttl:match-qname()}">
			<xsl:matching-substring>
				<prefix-name><xsl:value-of select="ttl:get-prefix-name(regex-group(1))"/></prefix-name>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
		<xsl:analyze-string select="$qname" regex="{ttl:match-qname()}">
			<xsl:matching-substring>
				<name><xsl:value-of select="regex-group(4)"/></name>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-predicate-object-list">
		<xsl:param name="predicateObjectList" as="xs:string"/>

			<xsl:message>[XSLT] predicateObjectList: &#10;<xsl:value-of select="$predicateObjectList"/>&#10;</xsl:message>
			<xsl:analyze-string select="$predicateObjectList" regex="{ttl:match-predicate-object-list()}">
			<xsl:matching-substring>
				<predicate-object-list>
					<xsl:call-template name="ttl:parse-verb">
						<xsl:with-param name="verb" select="regex-group(1)"/>
					</xsl:call-template>
					<xsl:call-template name="ttl:parse-object-list">
						<xsl:with-param name="objectList" select="regex-group(13)"/>
					</xsl:call-template>
				</predicate-object-list>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
		<!--<xsl:value-of select="ttl:match-predicate-object-list()" disable-output-escaping="no"/>-->
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-verb">
		<xsl:param name="verb" as="xs:string"/>
		
		<xsl:message>[XSLT] verb: &#10;<xsl:value-of select="$verb"/>&#10;</xsl:message>
		<verb>
			<xsl:analyze-string select="$verb" regex="{ttl:match-predicate()}">
				<xsl:matching-substring>
					<xsl:call-template name="ttl:parse-resource">
						<xsl:with-param name="resource" as="xs:string" select="regex-group(0)"/>
					</xsl:call-template>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:analyze-string select="$verb" regex="a">
						<xsl:matching-substring>
							<rdf:type/>
						</xsl:matching-substring>
						<xsl:non-matching-substring/>
					</xsl:analyze-string>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</verb>
		<!--<xsl:value-of select="ttl:match-verb()"/>-->
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-object-list">
		<xsl:param name="objectList" as="xs:string"/>
		
		<xsl:message>[XSLT] objectList: &#10;<xsl:value-of select="$objectList"/>&#10;</xsl:message>
		<object-list>
			<xsl:analyze-string select="$objectList" regex="{ttl:match-object()}">
				<xsl:matching-substring>
					<xsl:call-template name="ttl:parse-object">
						<xsl:with-param name="object" as="xs:string" select="regex-group(0)"/>
					</xsl:call-template>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</object-list>
		<!--<xsl:value-of select="ttl:match-object-list()"/>-->
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-object">
		<xsl:param name="object" as="xs:string"/>
		
		<xsl:message>[XSLT] object: &#10;<xsl:value-of select="$object"/>&#10;</xsl:message>
		<object>
			<xsl:analyze-string select="$object" regex="{ttl:match-literal()}">
				<xsl:matching-substring>
					<literal>
						<xsl:call-template name="ttl:parse-quoted-string">
							<xsl:with-param name="quotedString" as="xs:string" select="regex-group(0)"/>
						</xsl:call-template>
					</literal>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</object>
		<!--<xsl:value-of select="ttl:match-object()" disable-output-escaping="yes"/>-->
	</xsl:template>
	
	
	<!--  -->
	<xsl:template name="ttl:parse-quoted-string">
		<xsl:param name="quotedString" as="xs:string"/>
		
		<xsl:message>[XSLT] quotedString: &#10;<xsl:value-of select="$quotedString"/>&#10;</xsl:message>
		<xsl:analyze-string select="$quotedString" regex="{concat(ttl:match-quoted-string(), '(@(', ttl:match-language(), '))?')}">
			<xsl:matching-substring>
				<quoted-string>
					<string>
						<xsl:value-of select="regex-group(1)"/>
					</string>
					<xsl:if test="regex-group(4)">
						<language>
							<xsl:value-of select="regex-group(4)"/>
						</language>
					</xsl:if>
				</quoted-string>
			</xsl:matching-substring>
			<xsl:non-matching-substring/>
		</xsl:analyze-string>
		<!--<xsl:value-of select="concat(ttl:match-quoted-string(), '(@(', ttl:match-language(), '))?')"/>-->
	</xsl:template>
	
	
	
	
	<!-- === Pattern Matching Expressions. ================================= -->
	
	<!-- Turtle Documents. -->
	<xsl:function name="ttl:match-turtle-doc" as="xs:string">
		<xsl:value-of select="concat('(', ttl:match-statement(), ')*')"/>
	</xsl:function>
	
	
	<!-- Statements. -->
	<xsl:function name="ttl:match-statement" as="xs:string">
		<xsl:value-of select="concat(ttl:match-directive(), '\.|', ttl:match-triples(), '\.|', ttl:match-ws('+'))"/>
	</xsl:function>
	
	
	<!-- Directives. -->
	<xsl:function name="ttl:match-directive" as="xs:string">
		<xsl:value-of select="concat(ttl:match-prefix-id(), '|', ttl:match-base())"/>
	</xsl:function>
	
	
	<!-- Base URI Declarations. -->
	<xsl:function name="ttl:match-base" as="xs:string">
		<xsl:value-of select="concat('@base', ttl:match-ws('+'), ttl:match-uriref())"/>
	</xsl:function>
	
	
	<!-- Triples. -->
	<xsl:function name="ttl:match-triples" as="xs:string">
		<xsl:value-of select="concat('(', ttl:match-subject(), ')', ttl:match-ws('*'), '(', ttl:match-predicate-object-list(), ')')"/>
	</xsl:function>
	
	
	<!-- Subjects. -->
	<xsl:function name="ttl:match-subject" as="xs:string">
		<!--<xsl:value-of select="concat(ttl:match-resource(), '|', ttl:match-blank())"/>-->
		<xsl:value-of select="concat(ttl:match-resource(), '|', ttl:match-blank())"/>
	</xsl:function>
	
	
	<!-- Predicate Object Lists. -->
	<xsl:function name="ttl:match-predicate-object-list" as="xs:string">
			<xsl:value-of select="concat('(', ttl:match-verb(), ')', ttl:match-ws('+'), ttl:match-object-list(), '(', ttl:match-ws('*'), ';', ttl:match-ws('*'), '(', ttl:match-verb(), ')', ttl:match-ws('+'), ttl:match-object-list(), ')*', '(', ttl:match-ws('*'), ';', ')?', ttl:match-ws('*'))"/>
	</xsl:function>
	
	
	<!-- Verbs. -->
	<xsl:function name="ttl:match-verb" as="xs:string">
		<xsl:value-of select="concat(ttl:match-resource(), '|', '(', ttl:match-ws('+'), 'a', ')')"/>
	</xsl:function>
	
	
	<!-- Object Lists. -->
	<xsl:function name="ttl:match-object-list" as="xs:string">
		<xsl:value-of select="concat('(', ttl:match-object(), ttl:match-ws('*'), '(,', ttl:match-ws('*'), ttl:match-object(), ')*)')"/>
	</xsl:function>
	
	
	<!-- Objects -->
	<xsl:function name="ttl:match-object" as="xs:string">
		<xsl:value-of select="concat('(', ttl:match-resource(), '|', '(_:[A-Za-z_]([A-Za-z_\-0-9])*|\[\]|\[((&lt;(.*)&gt;)|((([A-Za-z_]([A-Za-z_\-0-9])*)?):([A-Za-z_]([A-Za-z_\-0-9])*))|((\t|\n|\r|\s)+a))(\t|\n|\r|\s)*(((&lt;(.*)&gt;)|((([A-Za-z_]([A-Za-z_\-0-9])*)?):([A-Za-z_]([A-Za-z_\-0-9])*))|(&quot;([A-Za-z0-9-_.''\s])*&quot;))(\t|\n|\r|\s)*(,(\t|\n|\r|\s)*((&lt;(.*)&gt;)|((([A-Za-z_]([A-Za-z_\-0-9])*)?):([A-Za-z_]([A-Za-z_\-0-9])*))|(&quot;([A-Za-z0-9-_.''\s])*&quot;)))*)(\t|\n|\r|\s)*(;(\t|\n|\r|\s)*((&lt;(.*)&gt;)|((([A-Za-z_]([A-Za-z_\-0-9])*)?):([A-Za-z_]([A-Za-z_\-0-9])*))|((\t|\n|\r|\s)+a))(\t|\n|\r|\s)*(((&lt;(.*)&gt;)|((([A-Za-z_]([A-Za-z_\-0-9])*)?):([A-Za-z_]([A-Za-z_\-0-9])*))|(&quot;([A-Za-z0-9-_.''\s])*&quot;))(\t|\n|\r|\s)*(,(\t|\n|\r|\s)*((&lt;(.*)&gt;)|((([A-Za-z_]([A-Za-z_\-0-9])*)?):([A-Za-z_]([A-Za-z_\-0-9])*))|(&quot;([A-Za-z0-9-_.''\s])*&quot;)))*))*(\t|\n|\r|\s)*(;)?(\t|\n|\r|\s)*\])', '|', ttl:match-literal(), ')')"/>
	</xsl:function>
	
	
	<!-- Literals. -->
	<xsl:function name="ttl:match-literal" as="xs:string">
		<xsl:value-of select="concat(ttl:match-quoted-string(), '(@', ttl:match-language(), ')?')"/>
	</xsl:function>
	
	
	<!-- ISO Language Codes -->
	<xsl:function name="ttl:match-language" as="xs:string">
		<xsl:value-of select="'[a-z]+(-[a-z0-9]+)*'"/>
	</xsl:function>
	
	
	<!-- Literals. -->
	<xsl:function name="ttl:match-quoted-string" as="xs:string">
		<xsl:value-of select="concat(ttl:match-string(), '' (: , '|', ttl:match-long-string() :))"/>
	</xsl:function>
	
	
	<!-- Literals. -->
	<xsl:function name="ttl:match-string" as="xs:string">
		<xsl:value-of select="'(&quot;([A-Za-z0-9-_.''\s])*&quot;)'"/>
	</xsl:function>
	
	
	<!-- Literals. -->
	<xsl:function name="ttl:match-long-string" as="xs:string">
		<xsl:value-of select="''"/>
	</xsl:function>
	
	
	<!-- Predicates. -->
	<xsl:function name="ttl:match-predicate" as="xs:string">
		<xsl:value-of select="ttl:match-resource()"/>
	</xsl:function>
	
	
	<!-- Resources. -->
	<xsl:function name="ttl:match-resource" as="xs:string">
		<xsl:value-of select="concat(ttl:match-uriref(), '|', '(', ttl:match-qname(), ')')"/>
	</xsl:function>
	
	
	<!-- QNames. -->
	<xsl:function name="ttl:match-qname" as="xs:string">
		<xsl:value-of select="concat('((', ttl:match-prefix-name(), ')?)', ':', '(', ttl:match-name(), ')')"/>
	</xsl:function>
	
	
	<!-- Blank nodes. -->
	<xsl:function name="ttl:match-blank" as="xs:string">
		<xsl:value-of select="concat(ttl:match-node-id(), '|', '\[\]', '|', '\[', ttl:match-predicate-object-list(), '\]' (:, '|', ttl:match-collection() :))"/>
	</xsl:function>
	
	
	<!-- RDF nodeIDs. -->
	<xsl:function name="ttl:match-node-id" as="xs:string">
		<xsl:value-of select="concat('_:', ttl:match-name())"/>
	</xsl:function>
	
	
	<!-- Collections. -->
	<xsl:function name="ttl:match-collection" as="xs:string">
		<xsl:value-of select="''"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-prefix-id" as="xs:string">
		<xsl:value-of select="concat('@prefix', ttl:match-ws('+'), '(', ttl:match-prefix-name(), ')?', ':', ttl:match-ws('*'), ttl:match-uriref())"/>
	</xsl:function>
	
	
	<!--  -->
	
	
	<!--  -->
	<xsl:function name="ttl:match-uriref" as="xs:string">
		<xsl:value-of select="'(&lt;(.*)&gt;)'"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-prefix-name" as="xs:string">
		<xsl:value-of select="concat(ttl:match-name-start-char(), '(', ttl:match-name-char(), ')*')"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name" as="xs:string">
		<xsl:value-of select="concat(ttl:match-name-start-char(), '(', ttl:match-name-char(), ')*')"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name-start-char" as="xs:string">
	<!-- <xsl:value-of select="'[A-Z]|_|[a-z]|[&#x00C0;-&#x00D6;]|[&#x00D8;-&#x00F6;]|[&#x00F8;-&#x02FF;]|[&#x0370;-&#x037D;]|[&#x037F;-&#x1FFF;]|[&#x200C;-&#x200D;]|[&#x2070;-&#x218F;]|[&#x2C00;-&#x2FEF;]|[&#x3001;-&#xD7FF;]|[&#xF900;-&#xFDCF;]|[&#xFDF0;-&#xFFFD;]|[&#x10000;-&#xEFFFF;]'"/>-->
		<xsl:value-of select="'[A-Za-z_]'"/>
	</xsl:function>
	
	
	<!--  -->
	<xsl:function name="ttl:match-name-char" as="xs:string">
		<!--<xsl:value-of select="concat(ttl:match-name-start-char(), '|-|[0-9]|&#x00B7;|[&#x0300;-&#x036F;]|[&#x203F;-&#x2040;]')"/>-->
		<xsl:value-of select="concat('[', translate(ttl:match-name-start-char(), '[]', ''), '\-0-9]')"/>
	</xsl:function>
	
	
	<!-- Match whitespace characters. -->
	<xsl:function name="ttl:match-ws" as="xs:string">
		<xsl:param name="c" as="xs:string?"/>
		
		<xsl:value-of select="concat('(\t|\n|\r|\s)', $c)"/><!-- , '|', ttl:match-comment() -->
	</xsl:function>
	
	
	<!-- Match comments. -->
	<xsl:function name="ttl:match-comment" as="xs:string">
		<xsl:value-of select="'(^#.*)'"/>
	</xsl:function>
	
	
	
	
	<!-- === Other Functions. ============================================== -->
	
	<!-- Extracts the URI from its start/end tags. -->
	<xsl:function name="ttl:get-uri" as="xs:string">
		<xsl:param name="uriRef" as="xs:string"/>
		
		<xsl:value-of select="substring($uriRef, 2, string-length($uriRef) - 2)"/>
	</xsl:function>
	
	
	<!-- Returns the prefix name or '_' if none is provided. -->
	<xsl:function name="ttl:get-prefix-name" as="xs:string?">
		<xsl:param name="name" as="xs:string?"/>
		
		<!--<xsl:value-of select="if (string-length($name) gt 0) then $name else '_'"/>-->
		<xsl:value-of select="$name"/>
	</xsl:function>
	
</xsl:transform>