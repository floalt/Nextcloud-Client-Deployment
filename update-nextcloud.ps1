# description: Update Nextcloud Client
# author: flo.alt@fa-netz.de
# version: 0.6

# setting the version to be updated to

$newversion = "2.6.1"
$unc_source = "\\serv12-dc\deployment\nextcloud\"
$setupfile = "Nextcloud-2.6.1-setup.exe"
$logfile = "c:\nextlog.txt"

echo "Start logfile" >$logfile
echo "install version $newversion" >>$logfile
echo "install source $unc_source" >>$logfile
echo "install file $setupfile" >>$logfile


# check if Nextcloud-Client is installed and not up to date

$check_nc = Get-Package -Provider Programs | where {$_.Name -like "Nextcloud*"}
if (!$check_nc) {
    echo "Nextcloud is not installed. Exiting." >>$logfile
    exit 0
    }
else {
    echo $check_nc
    if ($check_nc.Version -lt $newversion) {
        echo "Installed Version is less than $newversion. Running for Update" >>$logfile
        }
    else {
        echo "Installed Version is up to date. Exiting" >>$logfile
        exit 0
        }
    }

# installing the update

echo "beginning to install the update" >>$logfile
$setup = $unc_source + $setupfile
echo $setup >>$logfile
& $setup "/S" >>$logfile
echo "End" >>$logfile