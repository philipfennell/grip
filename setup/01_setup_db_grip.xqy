(:~ 
 : This file includes a series of transactions that create a forest, database 
 : and configures them all
 : All the necessary indexes are configured for the database.
 :)


(:~
 : creates the forest, must be a separate transaction
 :)
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at 
		"/MarkLogic/admin.xqy";
let $contentForest1 as xs:string := "grip"
let $contentForestDir as xs:string := "D:\Data\MarkLogic\grip"
let $config :=   admin:forest-create(admin:get-configuration(), 
		$contentForest1, xdmp:host(),$contentForestDir)
return admin:save-configuration($config);




(:~
 : creates the database, must be a separate transaction
 :)
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at 
		"/MarkLogic/admin.xqy";
let $contentDb as xs:string := "grip"
let $config := admin:database-create(admin:get-configuration(), $contentDb, 
		xdmp:database("Security"), xdmp:database("Schemas"))
return admin:save-configuration($config);




(:~
 : Attaches the forest to the database, must be a separate transaction
 :)
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at 
		"/MarkLogic/admin.xqy";
let $contentDb as xs:string := "grip"
let $contentForest1 as xs:string := "grip"
let $config :=   admin:database-attach-forest(admin:get-configuration(), 
		xdmp:database($contentDb), xdmp:forest($contentForest1))
return admin:save-configuration($config);




 (:~
  : creates all needed element range indexes for the 'codepoint' collation.
 :)
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at 
		"/MarkLogic/admin.xqy";
let $contentDb as xs:string := "grip"
let $config := admin:get-configuration()
let $dbid := xdmp:database($contentDb)
for $name in ("s", "p", "o", "c")
let $rangespec := admin:database-range-element-index("string", "", $name, 
		"http://marklogic.com/collation/codepoint", fn:false())
let $config := admin:database-add-range-element-index($config, $dbid, $rangespec)
return admin:save-configuration($config);




(:
 : configures the changes to a default installation of ML 4.2.6
 :)
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
let $contentDb as xs:string := "grip"
let $config := admin:get-configuration()
let $dbid := xdmp:database($contentDb)

(: database config section 2
let $config := admin:database-set-word-searches($config, $dbid, fn:true())
let $config := admin:database-set-word-positions($config, $dbid, fn:true())
let $config := admin:database-set-fast-phrase-searches($config, $dbid, fn:true()) 
let $config := admin:database-set-fast-case-sensitive-searches($config, $dbid, fn:true()) 
let $config := admin:database-set-fast-diacritic-sensitive-searches($config, $dbid, fn:true()) 
 :)
(: database config section 3
let $config := admin:database-set-fast-element-word-searches($config, $dbid, fn:true()) 
let $config := admin:database-set-element-word-positions($config, $dbid, fn:true()) 
let $config := admin:database-set-fast-element-phrase-searches($config, $dbid, fn:true()) 
 :)
(: database config section 4
let $config := admin:database-set-element-value-positions($config, $dbid, fn:true()) 
 :)
(: database config section 5
let $config := admin:database-set-fast-element-character-searches($config, $dbid, fn:false()) 
 :)
(: database config section 6
let $config := admin:database-set-trailing-wildcard-searches($config, $dbid, fn:true())
let $config := admin:database-set-trailing-wildcard-word-positions($config, $dbid, fn:true())
 :)
(: database config section 9 :)
let $config := admin:database-set-uri-lexicon($config, $dbid, fn:true())
let $config := admin:database-set-collection-lexicon($config, $dbid, fn:true())

(: database config section 11 :)
let $config := admin:database-set-directory-creation($config, $dbid, "manual")
 (: let $config := admin:database-set-maintain-last-modified($config, $dbid, fn:false()) :)

(: database config section 13 :)
 (: let $config := admin:database-set-journaling($config, $dbid, "fast") :)
 (: let $config := admin:database-set-preallocate-journals($config, $dbid, fn:false()) :)

return admin:save-configuration($config), true()
