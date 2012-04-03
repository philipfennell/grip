xquery version "1.0-ml" encoding "utf-8";

(:
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:~
 : Function library that implements the W3C's RDF Interface: Graph.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace graph = "http://www.w3.org/TR/rdf-interfaces/Graph"; 

import module namespace triple = "http://www.w3.org/TR/rdf-interfaces/Triple"
	at "/lib/rdf-interfaces/Triple.xqy";

import module namespace rdfnode = "http://www.w3.org/TR/rdf-interfaces/RDFNode"
	at "/lib/rdf-interfaces/RDFNode.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";




(:~
 : An array of actions to run when a Triple is added to the graph, each new 
 : triple is passed to the run method of each TripleAction in the array.
 : @param $contextGraph 
 : @return 
 :)
declare function graph:get-actions($contextGraph as element(graph)) 
	as item()*
{
	error(xs:QName('NOT_IMPLEMENTED'), 'The function ''graph:get-actions'' is not implemented.')
};


(:~
 : Adds a new TripleAction to the sequence of actions, if the run argument is 
 : specified as true() then each Triple in the Graph must be passed to the 
 : TripleAction before this method returns.
 : @param $contextGraph 
 : @param $action 
 : @param $run  
 : @return the graph instance it was called on.
 :)
declare function graph:add-action($contextGraph as element(graph), 
		$action as item(), $run as xs:boolean) 
	as element(graph)
{
	error(xs:QName('NOT_IMPLEMENTED'), 'The function ''graph:add-actions'' is not implemented.')
};


(:~
 : Adds a new TripleAction to the sequence of actions, if the run argument is 
 : specified as true() then each Triple in the Graph must be passed to the 
 : TripleAction before this method returns.
 : @param $contextGraph 
 : @param $action 
 : @return the graph instance it was called on.
 :)
declare function graph:add-action($contextGraph as element(graph), 
		$action as item()) 
	as element(graph)
{
	graph:add-action($contextGraph, $action, false())
};


(:~
 : Adds the specified triple to the graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function graph:add($contextGraph as element(graph), 
		$triple as element(triple)) 
	as element(graph)
{
	(: Need to add new namespaces that don't exist in the graph document. :)
	element {xs:QName(name($contextGraph))} {
		( $contextGraph/@*,
		$triple,
		$contextGraph/triple)
	}
};


(:~
 : Imports the graph in to this graph. 
 : @param $contextGraph 
 : @param $graph 
 : @return the graph instance it was called on.
 :)
declare function graph:add-all($contextGraph as element(graph), 
		$graph as element(graph)) 
	as element(graph)
{
	element {xs:QName(name($contextGraph))} {
		( $contextGraph/@*,
		$graph/triple,
		$contextGraph/triple )
	}
};


(:~
 : Universal quantification method, tests whether every Triple in the Graph 
 : passes the test implemented by the provided TripleFilter. 
 : @param $contextGraph 
 : @param $callback the TripleFilter to test each Triple in the Graph against. 
 : @return false() when the first Triple is found that does not pass the test.
 :)
declare function graph:every($contextGraph as element(graph), 
		$callback as item()) 
	as xs:boolean
{
	(: This'll test all triples before returning.
	not(false() eq (
		for $triple in graph:to-array($contextGraph)
		return
			xdmp:apply($callback, ($triple))
	)):)
	
	(: Whereas this'll return on the first test that returns false(). :)
	graph:assert(graph:to-array($contextGraph), $callback, false())
};


(:~
 : Creates a new Graph with all the Triples which pass the test implemented by 
 : the provided TripleFilter. 
 : @param $contextGraph 
 : @param $filter the TripleFilter to test each Triple in the Graph against. 
 : @return false() when the first Triple is found that does not pass the test.
 :)
declare function graph:filter($contextGraph as element(graph), 
		$filter as item()) 
	as element(graph)
{
	let $filteredTiples as element(triple)* := 
		for $triple in graph:to-array($contextGraph)
		where xdmp:apply($filter, ($triple))
		return
			$triple
	return
		element {QName('http://www.w3.org/TR/rdf-interfaces', name($contextGraph))} {
			$contextGraph/namespace::*,
			$contextGraph/@*,
			<uri xmlns="http://www.w3.org/TR/rdf-interfaces"/>,
			$filteredTiples
		}
};


(:~
 : Executes the provided TripleCallback once on each Triple in the Graph. 
 : @param $contextGraph 
 : @param $callback the TripleCallback to execute for each Triple. 
 : @return an empty sequence
 :)
declare function graph:for-each($contextGraph as element(graph), 
		$callback as item()) 
	as empty-sequence()
{
	for $triple in graph:to-array($contextGraph)
	return
		xdmp:apply($callback, ($triple))
};


(:~
 : A non-negative integer that specifies the number of Triples in the set.
 : @param $contextGraph 
 : @return unsigned long
 :)
declare function graph:get-length($contextGraph as element(graph)) 
	as xs:unsignedLong 
{
	(:xdmp:estimate(collection(graph:uri($contextGraph))):)
	count($contextGraph/triple)
}; 


(:~
 : This method returns a new Graph which is comprised of all those triples in 
 : the current instance which match the given arguments, that is, for each 
 : triple in this graph, it is included in the output graph, if:
 : * calling triple.subject.equals with the specified subject as an argument 
 :   returns true, or the subject argument is null, AND
 : * calling triple.predicate.equals with the specified predicate as an 
 :   argument returns true, or the predicate argument is null, AND
 : * calling triple.object.equals with the specified object as an argument 
 :   returns true, or the object argument is null
 : This method implements AND functionality, so only triples matching all of 
 : the given non-null arguments will be included in the result.
 : Note, this method always returns a new Graph, even if that Graph contains no 
 : Triples.
 : Note, Graphs represent Sets of Triples, the order is arbitrary, so this 
 : method may result in differing results when called repeatedly with a limit.
 : @param $contextGraph 
 : @param $subject The subject value to match against, may be null.
 : @param $predicate The predicate value to match against, may be null.
 : @param $object The object value to match against, may be null.
 : @param $limit An optional limit to the amount of triples returned, if 0 is 
 :               passed or the argument is set to null then all matching triples 
 :               will be contained in the resulting graph.
 : @return a new Graph.
 :)
declare function graph:match($contextGraph as element(graph), 
		$subject as item()?, $predicate as item()?, $object as item()?, 
				$limit as xs:unsignedLong) 
	as element(graph)
{
	let $size as xs:unsignedLong := 
		if ($limit eq 0) then graph:get-length($contextGraph) else $limit
	let $matchedTriples as element(triple)* := 
		for $triple in graph:to-array($contextGraph)[1 to $size]
		where ( (if (exists($subject)) then deep-equal($subject, triple:get-subject($triple)) else true()) and 
				(if (exists($predicate)) then deep-equal($predicate, triple:get-predicate($triple)) else true()) and 
					(if (exists($object)) then deep-equal($object, triple:get-object($triple)) else true()) )
		return
			$triple
	return
		element {QName('http://www.w3.org/TR/rdf-interfaces', name($contextGraph))} {
			$contextGraph/namespace::*,
			$contextGraph/@*,
			<uri xmlns="http://www.w3.org/TR/rdf-interfaces"/>,
			$matchedTriples
		}
};


(:~
 : This method returns a new Graph which is comprised of all those triples in 
 : the current instance which match the given arguments.
 : @param $contextGraph 
 : @param $subject The subject value to match against, may be null.
 : @param $predicate The predicate value to match against, may be null.
 : @param $object The object value to match against, may be null.
 : @return a new Graph.
 :)
declare function graph:match($contextGraph as element(graph), 
		$subject as item()?, $predicate as item()?, $object as item()?) 
	as element(graph)
{
	graph:match($contextGraph, $subject, $predicate, $object, 0)
};


(:~
 : Returns a new Graph which is a concatenation of this graph and the graph 
 : given as an argument.
 : @param $contextGraph 
 : @param $graph 
 : @return a new graph.
 :)
declare function graph:merge($contextGraph as element(graph), 
		$graph as element(graph)) 
	as element(graph)
{
	$contextGraph
};


(:~
 : Removes the specified Triple from the graph.
 : @param $contextGraph 
 : @param $triple 
 : @return the graph instance it was called on.
 :)
declare function graph:remove($contextGraph as element(graph), 
		$triple as element(triple)) 
	as element(graph)
{
	let $subject as xs:string := rdfnode:to-string(triple:get-subject($triple))
	let $predicate as xs:string := rdfnode:to-string(triple:get-predicate($triple))
	let $object as item()* := rdfnode:to-string(triple:get-object($triple))
	let $targetTriple := graph:uri-for-quad($subject, $predicate, $object, ())
	return
		element {xs:QName(name($contextGraph))} {
			$contextGraph/@*,
			for $t in $contextGraph/triple
			let $s as xs:string := rdfnode:to-string(triple:get-subject($t))
			let $p as xs:string := rdfnode:to-string(triple:get-predicate($t))
			let $o as item()* := rdfnode:to-string(triple:get-object($t))
			where not($targetTriple eq graph:uri-for-quad($s, $p, $o, ()))
			return
				$t
		}
};


(:~
 : This method removes those triples in the current instance which match the 
 : given arguments, that is, for each triple in this graph, it is removed, if:
 : * calling triple.subject.equals with the specified subject as an argument 
 :   returns true, or the subject argument is null, AND
 : * calling triple.predicate.equals with the specified predicate as an 
 :   argument returns true, or the predicate argument is null, AND
 : * calling triple.object.equals with the specified object as an argument 
 :   returns true, or the object argument is null
 : @param $contextGraph 
 : @param $subject The subject value to match against, may be null.
 : @param $predicate The predicate value to match against, may be null.
 : @param $object The object value to match against, may be null.
 : @return a new Graph.
 :)
declare function graph:remove-matches($contextGraph as element(graph), 
		$subject as item()?, $predicate as item()?, $object as item()?)
	as element(graph)
{
	let $matchesForRemoval as xs:string* := 
		for $t in graph:match($contextGraph, $subject, $predicate, $object)/triple
		let $s as xs:string := rdfnode:to-string(triple:get-subject($t))
		let $p as xs:string := rdfnode:to-string(triple:get-predicate($t))
		let $o as item()* := rdfnode:to-string(triple:get-object($t))
		return
			graph:uri-for-quad($s, $p, $o, ())
	return
		element {xs:QName(name($contextGraph))} {
			$contextGraph/@*,
			for $t in $contextGraph/triple
			let $s as xs:string := rdfnode:to-string(triple:get-subject($t))
			let $p as xs:string := rdfnode:to-string(triple:get-predicate($t))
			let $o as item()* := rdfnode:to-string(triple:get-object($t))
			where not(graph:uri-for-quad($s, $p, $o, ()) = $matchesForRemoval)
			return
				$t
		}
};


(:~
 : Existential quantification method, tests whether some Triple in the Graph 
 : passes the test implemented by the provided TripleFilter.
 : @param $contextGraph 
 : @param $callback the TripleFilter to test each Triple in the Graph against. 
 : @return true() when the first Triple is found that passes the test.
 :)
declare function graph:some($contextGraph as element(graph), 
		$callback as item()) 
	as xs:boolean 
{
	graph:assert(graph:to-array($contextGraph), $callback, true())
};


(:~
 : Returns the set of Triples within the Graph as a host language native 
 : sequence, for example an XPath 2.0 sequence.
 : If the context Graph has a Base URI then it is a Persistant Graph and its 
 : associated tirples can be found in the database, otherwise it is a Transient 
 : Graph and the triples are child elements of the graph.
 : @param $contextGraph 
 : @return sequence of triple elements.
 :)
declare function graph:to-array($contextGraph as element(graph)) 
	as (:element(triple)*:)item()*
{
	if (exists(base-uri($contextGraph))) then 
	xdmp:xslt-invoke('xslt/ml-tuples-to-graph.xsl', 
		document { 
			element {xs:QName(name($contextGraph))} {
				$contextGraph/@*,
				$contextGraph/uri,
				collection(graph:uri($contextGraph))/*
			}
		}
	)//triple
	else
		$contextGraph/triple
};


(:~
 : Recursively apply the callback function to the context Triple.
 : @param $triples a sequence of triples to be tested.
 : @param $callback the function to test against the triples.
 : @param $condition the boolean value that the callback will match in order to 
 : stop processing the sequence.
 : @return if the callback function returns false(), else returns true()
 :)
declare private function graph:assert($triples as element(triple)*, 
		$callback as item(), $condition as xs:boolean)
	as xs:boolean
{
	let $head as element()? := subsequence($triples, 1, 1)
	let $tail as element()* := subsequence($triples, 2)
	return
		if (exists($head)) then 
			if (xdmp:apply($callback, ($head)) ne $condition) then 
				graph:assert($tail, $callback, $condition)
			else
				$condition
		else 
			not($condition)
};


(:~
 : Build a deterministic uri for a quad. 
 : @param $subject 
 : @param $predicate 
 : @param $object 
 : @param $context
 : @return a URI string.
 :)
declare private function graph:uri-for-quad($subject as xs:string, 
		$predicate as xs:string, $object as xs:string, $context as xs:string?)
	as xs:string
{
  xdmp:integer-to-hex(
    xdmp:hash64(
      string-join(($subject, $predicate, $object, $context), '|') ) )
};


(:~
 : Returns the context graph's URI.
 : @param $contextGraph 
 : @return xs:string.
 :)
declare private function graph:uri($contextGraph as element(graph)) 
	as xs:string
{
	string($contextGraph/uri)
};

