# description: This ist the login script for Nextcloud clients
# author: flo.alt@fa-netz.de
# ver: 0.6

# Config the script here:

$deploy_dir = "\\serv12-dc\deployment\nextcloud"

$conf_dir = "$env:APPDATA\Nextcloud"
$conf_file = "nextcloud.cfg"


# check if nextcloud client is installed

$check_nc = Get-Package -Provider Programs | where {$_.Name -like "Nextcloud*"}
if (!$check_nc) {
    echo "Nextcloud is not installed. Exiting."
    exit 0
    }
else {
    # get install path
    if (Test-Path "C:\Program Files (x86)\Nextcloud") {$inst_path = "C:\Program Files (x86)\Nextcloud"}
    if (Test-Path "C:\Program Files\Nextcloud") {$inst_path = "C:\Program Files\Nextcloud"}
}

# check if exist config file
if (!(Test-Path $conf_dir\$conf_file)) {
    
    # deplay default nextcloud config file
    if (!(Test-Path $conf_dir)) {
        mkdir $conf_dir
        }
    cp $deploy_dir\$conf_file $conf_dir
    
    # delete autostart in registry if exist
    $checkreg = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\
    if ($checkreg -like "*Nextcloud*") {
       Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\ -Name Nextcloud
       }
    }

else {
    # check if account is configured
    $config = [IO.File]::ReadAllLines("$conf_dir\$conf_file")
    if ($config -like "*Accounts*") {
        
        # check if nextcloud folder exists
        if (!(Test-Path $env:USERPROFILE\Nextcloud)) {
            mkdir $env:USERPROFILE\Nextcloud
            }

        # check if nextcloud client starts with confdir switch and remove confidir switch
        $checkreg = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\
        if ($checkreg -like "*Nextcloud*") {
            if ((Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\ -Name Nextcloud).Nextcloud -like "*--confdir*") {
                Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\ -Name Nextcloud
                }
            }
        else {
            New-ItemProperty -Type String -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name Nextcloud -value "$inst_path\nextcloud.exe"
            }
        }
    }
