# description: Update Nextcloud Client
# author: flo.alt@fa-netz.de
# version: 0.5

# setting the version to be updated to

$newversion = "2.6.1"
$unc_source = "\\serv-dc\deployment\nextcloud\"
$setupfile = "Nextcloud-2.6.0-setup.exe"

# check if Nextcloud-Client is installed and not up to date

$check_nc = Get-Package -Provider Programs | where {$_.Name -like "Nextcloud*"}
if (!$check_nc) {
    echo "Nextcloud is not installed. Exiting."
    exit 0
    }
else {
    echo $check_nc
    if ($check_nc.Version -lt $newversion) {
        echo "Installed Version is less than $newversion. Running for Update"
        }
    else {
        echo "Installed Version is up to date. Exiting"
        exit 0
        }
    }

# installing the update

$setup = $unc_source + $setupfile
& $setup "/s"
