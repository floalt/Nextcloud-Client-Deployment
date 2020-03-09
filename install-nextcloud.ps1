# description: Install Nextcloud Client
# author: flo.alt@fa-netz.de
# version: 0.70

# bevore runnin this script: download nextcloud setup file and store it in a path this script can access ($deploypath).

# setup here:
$deploypath = "\\serv-dc\deployment\nextcloud\"
$logpath = "\\serv-dc\deployment\logs\nextcloud\"
$logfile =  $logpath + $env:COMPUTERNAME + ".log"
$logokfile = $logpath + "ok_" + $env:COMPUTERNAME + ".log"
$logfailfile = $logpath + "fail_" + $env:COMPUTERNAME + ".log"

# install nextcloud-client if not present or just update
# set 'install' or 'update'
$type = "update"

# look for most recent setup file:
$setupfileinfo = Get-ChildItem -File $deploypath | Sort-Object VersionInfo | select -Last 1
$filename = $setupfileinfo.name
$version = $setupfileinfo.VersionInfo.FileVersion
$setup = $deploypath + $filename


# logfile entry:
(Get-Date -Format yyyy-MM-dd-HH:mm:ss) + " START logfile`n" >> $logfile
"try to install Nextcloud $version" >>  $logfile
"from $setup" >>  $logfile

$check_nc = Get-Package -Provider Programs | where {$_.Name -like "Nextcloud*"}

# if Nexcloud is not installed yet
if (!$check_nc) {
    if ($type -eq "install") {
        (Get-Date -Format HH:mm:ss) + " Nextcloud is not installed. Installing Nexcloud Client now." >> $logfile
        & $setup "/S" *>> $logfile
    } elseif ($type -eq "update") {
        (Get-Date -Format HH:mm:ss) + " Nextcloud is not installed. Exiting." >> $logfile
    } else {
        (Get-Date -Format HH:mm:ss) + " Variable is neighter set to update nor set to install. Exiting." >> $logfile
    }

#    # check if Installation went all right
#    if ($check_nc.Version -eq $version) {
#        (Get-Date -Format HH:mm:ss) + " Installation of Nexcloud Client $version DONE. Exiting" >> $logfile
#        (Get-Date -Format yyyy-MM-dd-HH:mm:ss) + " Nextcloud Client $version is installed." > $logokfile
#    } else {
#        (Get-Date -Format HH:mm:ss) + " Installation of Nexcloud Client $version FAILED. Exiting" >> $logfile
#        (Get-Date -Format yyyy-MM-dd-HH:mm:ss) + " Installation of Nexcloud Client $version FAILED." > $logfailfile
#    }
} else {
    echo $check_nc
    # if Nextcloud is already installed, but older version
    if ($check_nc.Version -lt $version) {
        (Get-Date -Format HH:mm:ss) + " Installed Version is less than $version. Running for Update" >> $logfile
        & $setup "/S" *>> $logfile
    # if Nextcloud is already installed and up to date
    } else {
        (Get-Date -Format HH:mm:ss) + " Installed Version is up to date. Exiting" >> $logfile
        (Get-Date -Format yyyy-MM-dd-HH:mm:ss) + " Nextcloud Client $version is installed." > $logokfile
    }
}

"`n" + (Get-Date -Format yyyy-MM-dd-HH:mm:ss) + " END logfile" >> $logfile
"`n===================================== `n" >> $logfile
