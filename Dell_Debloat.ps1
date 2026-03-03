$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$apps = Get-ItemProperty $paths -ErrorAction SilentlyContinue

# Definujeme seznam klíčových slov, která chceme zachovat (whitelist)
$excludedNames = @(
    "Dell Command | Update*",
    "*Touchpad*",
    "*Pointing Device*"
)

$targets = $apps | Where-Object {
    $displayName = $_.DisplayName
    
    # Podmínka: Musí obsahovat "Dell"
    $displayName -like "*Dell*" -and 
    # A ZÁROVEŇ nesmí odpovídat žádné položce v našem whitelistu
    -not ($excludedNames | Where-Object { $displayName -like $_ })
}

foreach ($app in $targets) {
    Write-Host "Odeberu: $($app.DisplayName)" -ForegroundColor Yellow

    $cmd = if ($app.QuietUninstallString) { $app.QuietUninstallString } else { $app.UninstallString }

    if (-not $cmd) { continue }

    if ($cmd -match "msiexec") {
        $cmd = $cmd -ireplace "/I", "/X"
        if ($cmd -notmatch "/qn|/quiet") { $cmd += " /qn" }
        if ($cmd -notmatch "/norestart") { $cmd += " /norestart" }
        
        $parts = $cmd -split " ", 2
        Start-Process $parts[0] -ArgumentList $parts[1] -Wait
    } 
    else {
        # U EXE souborů přidáváme -NoNewWindow, aby proces běžel v aktuální konzoli
        Start-Process "cmd.exe" -ArgumentList "/c $cmd" -Wait -NoNewWindow
    }
}
