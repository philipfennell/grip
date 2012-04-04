<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
		xmlns="http://www.w3.org/2004/03/trix/trix-1/"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xs"
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
	
	
	<xsl:output encoding="UTF-8" indent="yes" 
			media-type="application/xml" method="xml"/>
	
	
	<xsl:template match="/">
		<trix>
			<xsl:apply-templates select="*" mode="trix"/>
		</trix>
	</xsl:template>
	
	
	<xsl:template match="*" mode="trix">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="* | text()" mode="#current"/>
		</xsl:element>
	</xsl:template>
</xsl:transform>