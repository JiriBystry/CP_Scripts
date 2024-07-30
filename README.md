<h1>Usage</h1>

<h2>Following commands in correct order</h2>
<ol>
<li>mkdir C:\tmp</li>
<li>powershell -command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/JiriBystry/Zoom_Uninstall/main/zoom_uninstall -OutFile C:\tmp\zoom_uninstall.ps1"</li>
<li>powershell -executionpolicy bypass -File "C:\tmp\zoom_uninstall.ps1"</li>
<li>timeout /t 2</li>
<li>rmdir /s /q C:\tmp</li>
</ol>
