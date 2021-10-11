<#

    description: Update Nextcloud Client
    author: flo.alt@fa-netz.de
    version: 0.8

before runnin this script: download nextcloud setup file and store it in a path this script can access ($deploypath).

#>

### -------- setup --------

$app_name = "Nextcloud Client"
$search_name = "Nextcloud"
$deploypath = "\\serv12-dc\deployment\nextcloud\"
$setup_param_exe = "/S"
$setup_param_msi = "REBOOT=ReallySuppress"

$setup_file = ""
$setup_version = ""
$setup = ""

$logpath = "\\serv12-dc\deployment\logs\nextcloud\"
$logname = "ncupdate"


###   -------- finish setup --------


###   -------- functions --------


# basic functions

function start-logfile {

    $script:log_tempfile =  "C:\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "ok_" + $env:COMPUTERNAME + ".log"
    $script:log_errorfile = $logpath + "fail_" + $env:COMPUTERNAME + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}

function end-logfile {

    "End: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
    
    if ($errorcount -eq 0) {
        mv $log_tempfile $log_okfile -Force
        if (test-path $log_errorfile) {rm $log_errorfile -Force}

    } else {
        mv $log_tempfile $log_errorfile -Force
        if (test-path $log_okfile) {rm $log_okfile -Force}
    }
}

function errorcheck {

    if ($?) {
        $yeah >> $log_tempfile
    } else {
        $shit >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
    }
}



# get version from installed app

function get-version-app {
    
    # first check registry for 64bit software
        $version = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ? DisplayName -like "*$search_name*").DisplayVersion

    # then check registry for 32bit software
        if (!$version) {
            $version = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ? DisplayName -like "*$search_name*").DisplayVersion
        }
    
    # last try this way:
        if (!$version) {
            $version = (Get-Package -Provider Programs | where {$_.Name -like "*$search_name*"}).Version
        }

    return $version
}


# convert version-variable

function convert-version ($version) {

    if (($version.GetType()).Name -eq "String") {
        echo "This is a string"
        $version_str = $version

    } elseif (($version.GetType()).Name -eq "Version") {
        echo "This is a version, converting to string"
        $version_str = $version.ToString()

    } else {
        echo "FAIL: This is not a string or a version"
    }

    $version_short = '{0}.{1}.{2}' -f $version_str.split('.')
        
    return $version_short
}


# install the desired app

function install-app {

    "OK: Starting installation of $app_name..." >> $log_tempfile
    $ext = (Get-Item $setup).extension
        
    $yeah = "OK: Starting to install $app_name $setup_version successfully."
    $shit = "FAIL: Installing $app_name ver $setup_version failed"
    
    # installing exe file

    if ($ext -eq ".exe") {
        if ($setup_param_exe -eq "") {
            Start-Process $setup -Wait
            errorcheck
        } else {
            Start-Process $setup -Wait -ArgumentList $setup_param_exe
            errorcheck
        }

    # installing msi file
    
    } elseif ($ext -eq ".msi") {
        if ($setup_param_msi -eq "") {
            Start-Process msiexec.exe -Wait -ArgumentList "/passive /i $setup"
            errorcheck
        } else {
            Start-Process msiexec.exe -Wait -ArgumentList "/passive /i $setup $setup_param_msi"
            errorcheck
        }
    
    # fail if neither exe nor msi
    
    } else {
            "FAIL: setup file has no vaild extension (exe or msi)" >> $log_tempfile
            $script:errorcount = $script:errorcount + 1
        }

    errorcheck-app
}


# check if installation went all right

function errorcheck-app {
    
    $installed_version = (get-version-app)
    
    if ($installed_version) {
        $installed_version = (convert-version $installed_version)[1]
    }

    if ($installed_version -eq $setup_version) {
        "OK: $app_name ver $setup_version is installed successfully." >> $log_tempfile
    } else {
        "FAIL: $app_name ver $setup_version could not be installed." >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
        $script:instfail = $script:instfail +1
    }
}

###   -------- finish functions --------



###   -------- start the action --------

# "$(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" > $logpath\touchtest.txt

$errorcount = 0
$instfail = 0

# begin logfile:

    start-logfile
    

# look for most recent setup file

    $setup_fileinfo = Get-ChildItem -File $deploypath\* -Include $search_name*.exe, $search_name*.msi | Sort-Object Name | select -Last 1
    $setup_file = $setup_fileinfo.name
    $setup = $deploypath + $setup_file

    "INFO: setup file path is $setup" >> $log_tempfile


# get version from setup-file
    
    if ($setup_fileinfo.VersionInfo.FileVersion) {
        
        $setup_version = (convert-version ($setup_fileinfo.VersionInfo.FileVersion))[1]
    
    } else {
    
        # if version info is not in the setup-file: read from txt version-file

        "INFO: There is no version-info within the setup file. Reading from version-file..." >> $log_tempfile
        $version_file = $deploypath + $setup_fileinfo.BaseName + ".version"
        $setup_version = cat $version_file
    }

    "INFO: setup file version is $setup_version" >> $log_tempfile


# get version from installed app

    $installed_version = (get-version-app)
    
    if ($installed_version) {

        $installed_version = (convert-version $installed_version)[1]
        "INFO: $app_name version already installed is $installed_version" >> $log_tempfile
    }


# perform the action

    # app is not installed

        if (!$installed_version) {
            "INFO: $app_name is not installed. Nothing to do." >> $log_tempfile
        }
    
    # installed version in older than setup version

        elseif ($installed_version -lt $setup_version) {
            "INFO: Installed version is older than $setup_version. Running for Update..." >> $log_tempfile
            install-app

            # try once again if installation fails
        
            if ($instfail -eq 1) {
                "INFO: Trying again to install $app_name..." >> $log_tempfile
                install-app
            
                if ($instfail -eq 1) {
                    "OK: 2. attempt of installation was successful." >> $log_tempfile
                    $script:errorcount = $script:errorcount - 1
                    $script:instfail = 0
                
                } elseif ($instfail -eq 2) {
                    "FAIL: 2. attempt of installation failed. Giving up." >> $log_tempfile
                }
            }
        }

    # installed version is same than setup version
    
        elseif ($installed_version -eq $setup_version) {
            "INFO: $app_name is up to date. Nothing to do." >> $log_tempfile
        }

    # installed version is newer than setup version
    
        elseif ($installed_version -gt $setup_version) {
            "INFO: $app_name is already newer then this update. Nothing to do." >> $log_tempfile
        }
    
    # i dont know about versions

        else {
            "FAIL: i cannot say anything about versions?!" >> $log_tempfile
        }


# end of script

    end-logfile