# Graph Store Implementation (grip)

The name 'grip' comes from **GR**aph store **I**m**P**lementation. The project aims to 
provide the ability to get to grips with graph data, stored in an instance of 
MarkLogic, via a the W3C's Graph Store Protocol and SPARQL 1.1 protocols.

* http://www.w3.org/TR/sparql11-http-rdf-update/
* http://www.w3.org/TR/sparql11-protocol/
* http://www.marklogic.com

The sibling project to this is grasp:

https://github.com/philipfennell/grasp

Instructions for deployment are on their way.

Note: I have had a rather good idea...

> _I'm going to re-write the under-lying library that interacts with the triples, as stored in MarkLogic, by creating an XQuery language binding to the [RDF Interfaces 1.0](http://www.w3.org/TR/rdf-interfaces/). That'll have two positive effects. One it will create a _standard_ library for interacting with RDF triples stored in MarkLogic and two, it provide a _standard_ API upon which to build the SPARQL 1.1 Graph Store Protocol implementation._

More to come so: _watch this space..._ (and/or the wiki)