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
 : Function library that implements the W3C's RDF Interface: TripleAction.
 : TripleAction combines the functionality of TripleFilter and TripleCallback, 
 : given a test and an action, the run method will execute the action if, and 
 : only if, it passes the test.
 : @see http://www.w3.org/TR/rdf-interfaces
 : @author	Philip A. R. Fennell
 : @version 0.1
 :)

module namespace action = "http://www.w3.org/TR/rdf-interfaces/TripleAction"; 

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/TR/rdf-interfaces";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfi = "http://www.w3.org/TR/rdf-interfaces";




(:~
 : The action to call on triple which successfully pass the test.
 : @param $contextTripleAction
 : @return action.
 :)
declare function action:get-action($contextTripleAction as element(action)) 
	as item()
{
	$contextTripleAction/callback
};


(:~
 : An instance of TripleFilter used to test whether the action should be 
 : executed on a specific Triple.
 : @param $contextTripleAction
 : @return test.
 :)
declare function action:get-test($contextTripleAction as element(action)) 
	as item()
{
	$contextTripleAction/filter
};


(:~
 : This function will run the specified action on the specified Triple if it 
 : passes the test.
 : @param $contextTripleAction
 : @param $triple The triple to be tried.
 : @param $graph The graph which contains the triple.
 : @return Depending upon the action, it may, or may not, return a triple(s).
 :)
declare function action:run($contextTripleAction as element(action), 
		$triple as element(triple), $graph as element(graph)) 
	as element()*
{
	if (xdmp:eval(action:get-test($contextTripleAction), 
			(xs:QName('rdfi:triple'), $triple))) then 
		xdmp:eval(action:get-action($contextTripleAction), 
				(xs:QName('rdfi:triple'), $triple, 
						xs:QName('rdfi:graph'), $graph))
	else
		$triple
};

