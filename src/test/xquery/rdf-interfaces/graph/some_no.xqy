xquery version "1.0-ml" encoding "utf-8";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default element namespace "http://www.w3.org/TR/rdf-interfaces";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";

import module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"
	at "/lib/rdf-interfaces/Graph.xqy";


(: The some of the predicates should be a plain literal (but know are so this should fail. :)
declare function local:test($triple as element()?)
		as xs:boolean
{
	$triple/*[2] instance of element(rdfi:plainLiteral)
};


let $graph as element() := 
<graph xmlns="http://www.w3.org/TR/rdf-interfaces" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#"><uri>#default</uri>
	<uri>#default</uri>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Prisoner Of Azkaban</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<id>A0</id>
	</triple>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book3</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<plainLiteral>1999-07-08</plainLiteral>
	</triple>
	<triple>
		<id>A0</id>
		<uri>http://www.w3.org/2001/vcard-rdf/3.0#FN</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
	<triple>
		<id>A0</id>
		<uri>http://www.w3.org/2001/vcard-rdf/3.0#N</uri>
		<id>A1</id>
	</triple>
	<triple>
		<uri>http://example.org/book/book7</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Deathly Hallows</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book7</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book7</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book7</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<plainLiteral>2001-07-21</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book2</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Chamber of Secrets</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book2</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<id>A0</id>
	</triple>
	<triple>
		<uri>http://example.org/book/book2</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book2</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<plainLiteral>1998-07-02</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book5</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Order of the Phoenix</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book5</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book5</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book5</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<plainLiteral>2003-06-21</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book4</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Goblet of Fire</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book4</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book4</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<plainLiteral>2000-07-08</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book6</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral>Harry Potter and the Half-Blood Prince</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book6</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book6</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book6</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<plainLiteral>2005-07-16</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/title</uri>
		<plainLiteral xml:lang="en-GB">Harry Potter and the Philosopher's Stone</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/creator</uri>
		<plainLiteral>J.K. Rowling</plainLiteral>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/publisher</uri>
		<uri>http://live.dbpedia.org/page/Bloomsbury_Publishing</uri>
	</triple>
	<triple>
		<uri>http://example.org/book/book1</uri>
		<uri>http://purl.org/dc/elements/1.1/date</uri>
		<typedLiteral datatype="http://www.w3.org/2001/XMLSchema#date">2001-11-04</typedLiteral>
	</triple>
	<triple>
		<id>A1</id>
		<uri>http://www.w3.org/2001/vcard-rdf/3.0#Family</uri>
		<plainLiteral>Rowling</plainLiteral>
	</triple>
	<triple>
		<id>A1</id>
		<uri>http://www.w3.org/2001/vcard-rdf/3.0#Given</uri>
		<plainLiteral>Joanna</plainLiteral>
	</triple>
</graph>
return
	graph:some($graph, xdmp:function(xs:QName('local:test'))) eq false()

