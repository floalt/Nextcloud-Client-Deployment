# Nextcloud-Client-Deployment

## install-nextcloud.ps1

This script looks for the latest setup-file in the local deployment folder and performs an update or first install

**Do setup like this within the script. Make sure ``$logpath`` exists.**

````
$deploypath = "\\serv12-dc\deployment\nextcloud\"
$logpath = "\\serv12-dc\deployment\logs\nextcloud\"
$logfile =  $logpath + $env:COMPUTERNAME + ".log"
$logokfile = $logpath + "ok_" + $env:COMPUTERNAME + ".log"
$logfailfile = $logpath + "fail_" + $env:COMPUTERNAME + ".log"
````
