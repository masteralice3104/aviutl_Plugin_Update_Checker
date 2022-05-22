

# 関数
function Temp_delete(){
    # JSONを読み込む
    $Json = (Get-Content -Path "./check.json" | ConvertFrom-Json)

    # 変数
    $temp_zipfile = $Json.temp_zip
    $temp_dir = $Json.temp_dir

    $exist = (Test-Path -Path $temp_dir)
    if( $exist -eq "True")
    {
        Remove-Item $temp_dir -Recurse
    }

    $exist = (Test-Path -Path $temp_zipfile)
    if( $exist -eq "True")
    {
        Remove-Item $temp_zipfile -Recurse
    }

}

# JSONを読み込む
$JsonContent = (Get-Content -Path "./check.json" | ConvertFrom-Json)

# 変数
$temp_zipfile = $JsonContent.temp_zip
$temp_dir = $JsonContent.temp_dir
$updated = @()

# 作業用tempフォルダを作る
Temp_delete

New-Item $temp_dir -ItemType Directory

# 通知する
Write-Output "`r`nプラグインのアップデートを確認します……"

foreach ($plugin_object in $JsonContent.plugin) {
    # $plugin_objectから読み取れるやつ

    # useじゃなかったら放置
    if($plugin_object.use -ne "True"){
        continue
    }

    # update-blockしてないか確認
    if($plugin_object."update_block"){
        # 通知する
        Write-Output ($plugin_object.name + "のアップデートはブロックされました`r`n(現在:"+$plugin_object.tag_name+")")
        continue
    }

    # githubのAPIを叩きに行く
    # latest読めばいいよね！
    $HTTPContent = ((Invoke-WebRequest $plugin_object.releases).Content | ConvertFrom-Json)


    # tag_nameを比較する
    if ($HTTPContent.tag_name -eq $plugin_object.tag_name){
        # 同じ時 = アップデートがないとき
        Write-Output ($plugin_object.name + "は最新です`r`n(現在:"+$plugin_object.tag_name+")")
        continue
    }

    Write-Output ($plugin_object.name + "のアップデートが見つかりました`r`n(現在:"+$plugin_object.tag_name+" -> 最新:"+$HTTPContent.tag_name+")")
    # アップデートがあるときは実行ファイルをtempフォルダに保存
    Invoke-WebRequest -Uri $HTTPContent.assets."browser_download_url" -OutFile $temp_zipfile

    # zipを解凍
    Expand-Archive -Path $temp_zipfile -DestinationPath $temp_dir

    # tempフォルダからコピーする
    foreach ($file in $plugin_object.copy_file){
        # コピー元ファイルパス
        $copy_moto = ($temp_dir + $file)

        # コピー先ファイルパス
        $copy_saki = ($plugin_object.copy_folder + $file)

        # 通知する
        Write-Output ("コピーします "+$copy_moto +" -> "+ $copy_saki)

        # 上書きしちゃう
        Copy-Item -Path $copy_moto -Destination $copy_saki -Force
    }

    # アップデートしたらjsonを書き換える
    $plugin_object.tag_name = $HTTPContent.tag_name
    ConvertTo-Json $JsonContent | Out-File "./check.json" -Encoding utf8

    # updatedに追加
    $updated += $plugin_object.name

    # 通知
    Write-Output ($plugin_object.name + "はアップデートされました`r`n(現在:"+$plugin_object.tag_name+")")
    
    # 後片付け
    Temp_delete
}


Write-Output ("`r`n`r`nアップデート処理終了")
Temp_delete



Add-Type -Assembly System.Windows.Forms
if ($JsonContent.end_aviutl -eq "True"){
    $dialog = "処理が終了しました`r`n"

    if ($updated){
        $dialog += "アップデートはありませんでした"
    }else{
        $dialog += "アップデートされたプラグイン`r`n"
        foreach ($updated_plugin in $updated){
            $dialog +="　"+$updated_plugin+"`r`n"
        }
    }

    [System.Windows.Forms.MessageBox]::Show($dialog, "Plugin Update Checker")
    Start-Process -FilePath $JsonContent.aviutl_path
}else{
    [System.Windows.Forms.MessageBox]::Show("処理が終了しました", "Plugin Update Checker")
    Start-Sleep -s [int]$JsonContent.wait_sec
}

