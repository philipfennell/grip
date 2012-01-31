xquery version "1.0-ml" encoding "utf-8";

(:
 : Implements the 'get' action for the identified resource.
 : @author	Philip A. R. Fennell
 :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace service = "http://www.marklogic.com/rig/service" 
		at "/framework/service.xqy";
      
import module namespace resource = "http://www.marklogic.com/grip" at 
		"/root/resource.xqy";


$service:DESCRIPTION/*
