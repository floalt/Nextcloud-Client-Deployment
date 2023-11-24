<#
config file for update-nextcloud.ps1 and check-setup.ps1
#>

$app_name = "Nextcloud Client"
$search_name = "Nextcloud"
$deploypath = "\\[domain].local\shared\deployment\nextcloud\"
$setup_param_exe = "/S"
$setup_param_msi = "REBOOT=ReallySuppress"

$setup_file = ""
$setup_version = ""
$setup = ""

$logpath = "\\[domain].local\shared\deployment\logs\nextcloud\"
$logname = "ncupdate"

$autoupdate = 1