# これは
# 1.    Jsonのverを見る
# 2.    ハードコードされたverと一緒なら.bakを元に戻す
# 3.    verが違うなら警告を出す
#

# アセンブリ
Add-Type -Assembly System.Windows.Forms

# バージョン
$Jsonver = 3

# check
$check_json_path = "./check.json"
$check_json_bak_path = $check_json_path + ".bak"

# setting
$setting_json_path = "./setting.json"
$setting_json_bak_path = $setting_json_path + ".bak"


function noti_dialog($json,$bak){

    # 通知
    $dialog += $bak + "のバージョンは適正ではありません`r`n`r`n"
    $dialog +="以前の設定は" + $bak + "に保存されています`r`n"
    $dialog +="適宜"+$json+"を書換えてください`r`n"
    $dialog +="※次回アップデート時に" + $bak + "は上書きされてしまうため、注意してください`r`n"
    [System.Windows.Forms.MessageBox]::Show($dialog, "Plugin Update Checker")
}







# 通知
Write-Output "設定ファイルのアップデートを確認します……"


$JsonContent = (Get-Content -Path $check_json_bak_path | ConvertFrom-Json)
$SettingJson = (Get-Content -Path $setting_json_bak_path | ConvertFrom-Json)

if($JsonContent.ver -eq $Jsonver){
    # 通知
    Write-Output ($check_json_path + "のバージョンは適正です")

    Remove-Item $check_json_path -Recurse
    Rename-Item $check_json_bak_path $check_json_path
}else{
    if($SettingJson.setting_noti_dialog){
        noti_dialog -json $check_json_path -bak $check_json_bak_path
    }
}
if($SettingJson.ver -eq $Jsonver){
    # 通知
    Write-Output ($setting_json_path + "のバージョンは適正です")

    Remove-Item $setting_json_path -Recurse
    Rename-Item $setting_json_bak_path $setting_json_path
}else{
    if($SettingJson.setting_noti_dialog){
        noti_dialog -json $setting_json_path -bak $setting_json_bak_path
    }
}

Write-Output ("設定ファイル確認終了")