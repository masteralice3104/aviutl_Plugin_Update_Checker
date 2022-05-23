@echo off
chcp 65001
pushd %0\..

if exist main.update.ps1 (if exist main.ps1 del main.ps1)
if exist main.update.ps1 ren main.update.ps1 main.ps1

if exist setting.json.bak powershell -ExecutionPolicy Unrestricted ./jsoncheck.ps1


if exist setting.json (
    powershell  -ExecutionPolicy Unrestricted ./main.ps1
    goto end
) else (
    goto er
)

goto end
:er
    chcp 65001
    echo 自動更新ができない重大なアップデートがなされました
    echo https://github.com/masteralice3104/aviutl_Plugin_Update_Checker
    echo より再導入してください
    pause 

:end
