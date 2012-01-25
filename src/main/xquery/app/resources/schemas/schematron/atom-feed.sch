<?xml version="1.0" encoding="UTF-8"?>
<iso:schema xmlns:iso="http://purl.oclc.org/dsdl/schematron">
	<iso:ns prefix="atom" uri="http://www.w3.org/2005/Atom"/>
	<iso:title>Simple Atom Feed Rules</iso:title>
	<iso:pattern>
		<iso:title>Atom Feed Root</iso:title>
		<iso:rule context="/">
			<iso:assert test="atom:feed">The document root must be an atom:feed element.</iso:assert>
		</iso:rule>
	</iso:pattern>
	<iso:pattern>
		<iso:title>Required Feed Elements</iso:title>
		<iso:rule context="/atom:feed">
			<iso:assert test="atom:title">The feed must have a title.</iso:assert>
			<iso:assert test="atom:id">The feed must have an id.</iso:assert>
			<iso:assert test="atom:updated">The feed must have an updated date.</iso:assert>
		</iso:rule>
	</iso:pattern>
	<iso:pattern>
		<iso:title>Feed Link Rules</iso:title>
		<iso:rule context="/atom:feed">
			<iso:report test="not(atom:link[@rel = 'self'])">The feed should have a link of relation 'self'.</iso:report>
		</iso:rule>
	</iso:pattern>
	<iso:pattern>
		<iso:title>Feed Authors Rules</iso:title>
		<iso:rule context="/atom:feed[not(atom:author)]">
			<iso:assert test="(count(atom:entry) &gt; 0) and (count(atom:entry[atom:author]) = count(atom:entry))">The feed must have an author if not all of the entries do.</iso:assert>
		</iso:rule>
	</iso:pattern>
	<iso:pattern>
		<iso:title>Required Entry Elements</iso:title>
		<iso:rule context="/atom:feed[not(atom:author)]/atom:entry">
			<iso:assert test="atom:author">An entry must have an author if the parent feed does not.</iso:assert>
		</iso:rule>
	</iso:pattern>
	<!--<iso:pattern>
		<iso:rule context="/atom:feed/atom:entry[not(atom:link[@rel = 'alternate'])]">
			<iso:assert test="atom:content">An entry must provide content if there is no alternate link.</iso:assert>
		</iso:rule>
	</iso:pattern>
	<iso:pattern>
		<iso:rule context="/atom:feed/atom:entry[not(atom:summary)]">
			<iso:report test="not(atom:content)">An entry should provide content if there is no summary.</iso:report>
		</iso:rule>
	</iso:pattern>-->
	<iso:pattern>
		<iso:rule context="/atom:feed/atom:entry[not(atom:content)]">
			<iso:assert test="atom:link">An entry must provide content if there is no alternate link.</iso:assert>
			<iso:report test="not(atom:summary)">An entry should provide a summary if there is no content.</iso:report>
		</iso:rule>
	</iso:pattern>
</iso:schema>