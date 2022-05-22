pushd %0\..

if exist main.update.ps1 (if exist main.ps1 del main.ps1)
if exist main.update.ps1 ren main.update.ps1 main.ps1


powershell  -ExecutionPolicy Unrestricted ./main.ps1