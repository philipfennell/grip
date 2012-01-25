(:~
 : Creates all application server for eNeurosurgery (HTTP, XDBC)
 :)

(:~
 : Creates the grip HTTP server
 :)
xquery version "1.0-ml";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
          
import module "http://marklogic.com/xdmp/security" at "/MarkLogic/security.xqy";

let $group as xs:string := "Default"
let $modulesDb as xs:string := "file-system"
let $contentDb as xs:string := "grip"
let $httpServer as xs:string := "8005-GRIP-HTTP"
let $httpPort as xs:integer := 8005
let $defaultUser as xs:string := "admin"
  
let $userId := xdmp:user($defaultUser)  
let $config := admin:get-configuration()
let $groupid := xdmp:group($group)
let $config := admin:http-server-create($config, $groupid, $httpServer, 
        "C:\Users\pfennell\Projects\SemanticWeb\grip\src\main\xquery\app", $httpPort, 
        		$modulesDb, xdmp:database($contentDb))  
let $config := admin:appserver-set-url-rewriter($config,
         admin:appserver-get-id($config, $groupid, $httpServer),
         "/framework/rewriter.xqy")
let $config := admin:appserver-set-error-handler($config,
         admin:appserver-get-id($config, $groupid, $httpServer),
         "/framework/error.xqy")        
let $config := admin:appserver-set-authentication($config,
         admin:appserver-get-id($config, $groupid, $httpServer),
         "application-level")
let $config := admin:appserver-set-default-user($config,
         admin:appserver-get-id($config, $groupid, $httpServer),
         $userId)
return
	admin:save-configuration($config);




(:~
 : Creates grip XDBC server 
 :)
xquery version "1.0-ml";

import module namespace admin = "http://marklogic.com/xdmp/admin" 
          at "/MarkLogic/admin.xqy";

let $group as xs:string := "Default"
let $modulesDb as xs:string := "file-system"
let $contentDb as xs:string := "grip"
let $xdbcServer as xs:string := "8006-GRIP-XDBC"
let $xdbcPort as xs:integer := 8006
let $defaultUser as xs:string := "admin"
  
let $config := admin:get-configuration()
let $groupid := admin:group-get-id($config, $group)  
let $config := admin:xdbc-server-create($config, $groupid, $xdbcServer, 
        "C:\Users\pfennell\Projects\SemanticWeb\grip\src\main\xquery\app", $xdbcPort, 
        		$modulesDb, xdmp:database($contentDb))
return admin:save-configuration($config)
