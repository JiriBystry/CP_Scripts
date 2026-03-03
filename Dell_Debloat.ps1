# Odinstaluje vše "Dell*" kromì "Dell Command | Update"

$paths = @(
  "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$apps = foreach ($p in $paths) {
  Get-ItemProperty $p -ErrorAction SilentlyContinue
}

# vše co obsahuje Dell, ale vynechat Dell Command | Update
$targets = $apps | Where-Object {
  $_.DisplayName -and
  $_.DisplayName -like "*Dell*" -and
  $_.DisplayName -ne "Dell Command | Update"
}

$targets | ForEach-Object {
  Write-Host "Odinstaluji: $($_.DisplayName)"

  # 1) Preferuj QuietUninstallString (když existuje)
  if ($_.QuietUninstallString) {
    $cmd = $_.QuietUninstallString
  }
  elseif ($_.UninstallString) {
    $cmd = $_.UninstallString
  }
  else {
    Write-Host "  -> Nelze odinstalovat (chybí UninstallString)"
    return
  }

  # 2) MSI: pøepnout /I -> /X a vynutit tichý režim
  if ($cmd -match "(?i)msiexec") {
    $cmd = $cmd -replace "(?i)/I", "/X"
    if ($cmd -notmatch "(?i)/quiet|/qn") { $cmd += " /qn" }
    if ($cmd -notmatch "(?i)/norestart") { $cmd += " /norestart" }
  }

  # 3) Spustit (pozn.: pokud to není MSI a nemá silent parametry, mùže vyskoèit GUI)
  Start-Process "cmd.exe" -ArgumentList "/c $cmd" -Wait -NoNewWindow
}