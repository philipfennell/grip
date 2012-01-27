<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:gsp="http://www.w3.org/TR/sparql11-http-rdf-update/"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:test="http://www.w3.org/ns/xproc/test"
		xml:base="../../"
		exclude-inline-prefixes="#all"
	 	version="1.0">
	
	<p:output port="result"/>
	
	<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>
	
	<p:import href="test/resources/xproc/lib-gsp.xpl"/>
	<p:import href="test/resources/xproc/test.xpl"/>
	
	
	<gsp:add-graph name="test" uri="http://localhost:8005/test/data" 
			graph="http://sandbox.com/test/skos" content-type="application-rdf+xml">
		<p:input port="source">
			<p:inline exclude-inline-prefixes="#all">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:skos="http://www.w3.org/2004/02/skos/core#">
	<skos:Concept rdf:about="http://www.my.com/#canals">
		<skos:definition>A feature type category for places such as the Erie Canal</skos:definition>
		<skos:prefLabel>canals</skos:prefLabel>
		<skos:altLabel>canal bends</skos:altLabel>
		<skos:altLabel>canalized streams</skos:altLabel>
		<skos:altLabel>ditch mouths</skos:altLabel>
		<skos:altLabel>ditches</skos:altLabel>
		<skos:altLabel>drainage canals</skos:altLabel>
		<skos:altLabel>drainage ditches</skos:altLabel>
		<skos:broader rdf:resource="http://www.my.com/#hydrographic%20structures"/>
		<skos:related rdf:resource="http://www.my.com/#channels"/>
		<skos:related rdf:resource="http://www.my.com/#locks"/>
		<skos:related rdf:resource="http://www.my.com/#transportation%20features"/>
		<skos:related rdf:resource="http://www.my.com/#tunnels"/>
		<skos:scopeNote>Manmade waterway used by watercraft or for drainage, irrigation, mining, or water power</skos:scopeNote>
	</skos:Concept>
</rdf:RDF>
			</p:inline>
		</p:input>
	</gsp:add-graph>
	
</p:declare-step>