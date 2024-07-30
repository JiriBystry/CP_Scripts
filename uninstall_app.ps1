#> 
[cmdletbinding()]
param(
    [Parameter(Mandatory=$true)]
    [string[]]$displayName
)
function Uninstall-ApplicationLocalMachine() {
    foreach ($object in $displayName) {
        Write-Verbose -Verbose -Message "Running Uninstall-ApplicationLocalMachine function"
        Write-Verbose -Verbose -Message "Looking for installed application: $object"
        $registryPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        foreach ($path in $registryPaths) {
            Write-Verbose -Verbose -Message "Looping through $path"
            if (Test-Path -Path $path) {
                $installedApps = Get-ChildItem -Path $path -Recurse | Get-ItemProperty | Where-Object {$_.DisplayName -like "*$object*"} | Select-Object Displayname,UninstallString,PSChildName
                if ($installedApps) {
                    Write-Verbose -Verbose -Message "Installed applications matching '$object' found in $path"
                    foreach ($App in $installedApps) {
                        if ($App.UninstallString) {
                            if ($App.UninstallString.Contains("MsiExec.exe")) {
                                try {
                                    Write-Verbose -Verbose -Message "Uninstalling application: $($App.DisplayName) via $($App.UninstallString)"
                                    Start-Process 'cmd.exe' -ArgumentList ("/c" + "MsiExec.exe /x" + $($App.PSChildName) + " /quiet" + " /norestart") -Wait
                                    
                                } catch {
                                    Write-Error -Message "Failed to uninstall application: $($App.DisplayName)"
                                }
                            }
                            if ($App.UninstallString.Contains("unins000.exe")) {
                                try {
                                    Write-Verbose -Verbose -Message "Uninstalling application: $($App.DisplayName) via $($App.UninstallString)"
                                    Start-Process 'cmd.exe' -ArgumentList ("/c" + $($App.UninstallString) + " /SILENT" + " /NORESTART") -Wait
                                } catch {
                                    Write-Error -Message "Failed to uninstall application: $($App.DisplayName)"
                                }
                            }
                            else {
                                # If script reaches this point, the application is installed with an unsupported installer. Feel free to add further mechanisms.
                            }
                        }
                    }
                }
                else {
                    Write-Verbose -Verbose -Message "No installed apps that matches displayname: $object found in $path"
                }
            }
            else {
                Write-Verbose -Verbose -Message "Path: $path does not exist"
            }
        }
    }
}
try {
    Write-Verbose -Verbose -Message "Script is running"
    Uninstall-ApplicationLocalMachine
}
catch {
    Write-Verbose -Verbose -Message "Something went wrong during running of the script: $($_.Exception.Message)"
}
finally {
    Write-Verbose -Verbose -Message "Script is done running"
}
