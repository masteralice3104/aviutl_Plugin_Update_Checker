# ver
$ver = "0.0.9"

# タイトル
Write-Output ("Plugin Update Checker ver" + $ver)


# アセンブリ
Add-Type -Assembly System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# テンポラリフォルダとかを削除する関数
function Temp_delete(){
    # JSONを読み込む
    $Json = (Get-Content -Path "./setting.json" | ConvertFrom-Json)

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


#releases/latestからタグ名を探し出す関数
function TagGet($URL)
{ 
    

    $Obj = Invoke-Webrequest -Uri $URL
    
    foreach($Link in $Obj.Links){
        if($Link.class -eq "Link--muted" ){
            if(!$Link."data-hovercard-type"){
                Add-Type -AssemblyName Microsoft.VisualBasic
                $tag = [Microsoft.VisualBasic.Strings]::Left($Link.outerText,$Link.outerText.Length-1)
                return $tag
            }
        }
    }
    return $null
}

# tagsページから
# 一番上のhttps://github.com/～/～/releases/tag/タグ名
# ページURLを検索する関数
function Tags_URL($TagsPageURL){
    $Obj = Invoke-Webrequest -Uri $TagsPageURL
    
    # outerText           : r24
    # tagName             : A
    # class               : Link--muted
    #これを探し出す
    foreach($Link in $Obj.Links){
        if($Link.class -eq "Link--muted" ){
            if($Link.innerText -like "*Downloads*"){
                $hrefURL = "https://github.com"+$Link.href
                return $hrefURL
            }
        }
    }
    return $null
    
}


function TagGet2($URL){

    $releaseURL = Tags_URL -TagsPageURL $URL

    $releaseURL
    if (!$releaseURL){
        return $null
    }
    
    $Tag = [regex]::Matches($releaseURL,"tag/[A-Za-z0-9._/]*")


    $Tagreturn = [Microsoft.VisualBasic.Strings]::Right($Tag,$Tag.Length-4)
    return $Tagreturn 

}

# tags/タグ名 もしくは release/latest のページの
# Assetsの一番上のファイルのURLを探し出す関数
# なおSource codeは排除する
function DLURLGet($URL){
    
    $Obj = Invoke-Webrequest -Uri $URL
    
    foreach($Link in $Obj.Links){
        if($Link.rel -eq "nofollow" ){
            if($Link.innerHTML -like '<SPAN class="px-1 text-bold">*'){
                if(!($Link.innerText -like 'Source code*')){
                    return ("https://github.com"+ $Link.href)
                }
            }
        }
    }
    return $null
}

function Download($plugin_object,$URL,$temp_zipfile,$temp_dir){
    
    # https://github.com/masteralice3104/aviutl_Plugin_Update_Checker/issues/3
    # ありがとうございます

    # アップデートがあるときは実行ファイルをtempに保存
    Invoke-WebRequest -Uri (DLURLGet -URL $URL) -OutFile $temp_zipfile

    # zipを解凍
    Expand-Archive -Path $temp_zipfile -DestinationPath $temp_dir

    # tempフォルダからコピーする
    foreach ($file in $plugin_object.copy_file){
        # コピー元ファイルパス
        $copy_moto = ($temp_dir + $file)

        # コピー先ファイルパス
        $copy_saki = ($plugin_object.copy_folder+ $file).Replace('*','')

        # 通知する
        Write-Output ("コピーします "+$copy_moto +" -> "+ $copy_saki)

        # 上書きしちゃう
        Copy-Item -Path $copy_moto -Destination $copy_saki -Force -Recurse
    }
}


# JSONを読み込む
$JsonContent = (Get-Content -Path "./check.json" | ConvertFrom-Json)
$SettingJson = (Get-Content -Path "./setting.json" | ConvertFrom-Json)

# 変数
$temp_zipfile = $SettingJson.temp_zip
$temp_dir = $SettingJson.temp_dir
$updated = @()
$this_app = "https://github.com/masteralice3104/aviutl_Plugin_Update_Checker/*"

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

    # URLを作る
    
    # tags
    $URL_tags = $plugin_object.link + "/tags"

    # releases/latest
    $URL_latest = $plugin_object.link + "/releases/latest"


    
    # https://github.com/masteralice3104/aviutl_Plugin_Update_Checker/issues/3
    # ありがとうございます
    $DLpageURL = ""
    $Latest_tag_name = ""
    if($plugin_object.type -eq "tags"){
        $Latest_tag_list = TagGet2 -URL $URL_tags
        $Latest_tag_name =$Latest_tag_list[1]
        $DLpageURL = Tags_URL -TagsPageURL $URL_tags
    }else{
        $Latest_tag_name = TagGet -URL $URL_latest
        $DLpageURL = $URL_latest
    }





    # tag_nameを比較する
    if ($Latest_tag_name -eq $plugin_object.tag_name){
        # 同じ時 = アップデートがないとき
        Write-Output ($plugin_object.name + "は最新です`r`n(現在:"+$plugin_object.tag_name+")")
        continue
    }

    Write-Output ($plugin_object.name + "のアップデートが見つかりました`r`n(現在:"+$plugin_object.tag_name+" -> 最新:"+$Latest_tag_name+")")
    

    # 例外処理
    # 自身をアップデートする前にかならずjsonのバックアップをとる
    if ($URL_latest -like $this_app){
        # タグ名を更新
        $plugin_object.tag_name = $Latest_tag_name

        # 保存
        ConvertTo-Json -InputObject $JsonContent -Depth 32 | Out-File "./check.json.bak" -Encoding utf8
        ConvertTo-Json -InputObject $SettingJson -Depth 32 | Out-File "./setting.json.bak" -Encoding utf8
    }
    
    Download -plugin_object $plugin_object -URL $DLpageURL -temp_zipfile $temp_zipfile -temp_dir $temp_dir
    
    if ($URL_latest -like $this_app){
        # 例外処理
        # 自身をアップデートした際にはjsoncheck.ps1を起動する
        .\jsoncheck.ps1
    }else{
        # 自身のアプデではない場合は
        # アップデートしたらjsonを書き換える
        $plugin_object.tag_name = $Latest_tag_name
        ConvertTo-Json -InputObject $JsonContent -Depth 32 | Out-File "./check.json" -Encoding utf8
    }



    # updatedに追加
    $updated += $plugin_object.name

    # 通知
    Write-Output ($plugin_object.name + "はアップデートされました`r`n(現在:"+$plugin_object.tag_name+")")
    
    # 後片付け
    Temp_delete
}


Write-Output ("`r`n`r`nアップデート処理終了")
Temp_delete




if ($SettingJson.end_aviutl -eq "True"){
    $dialog = "処理が終了しました`r`n"

    if ($updated){
        $dialog += "アップデートされたプラグイン`r`n"
        foreach ($updated_plugin in $updated){
            $dialog +="　"+$updated_plugin+"`r`n"
        }
    }else{
        $dialog += "アップデートはありませんでした"
    }
    if ($SettingJson.dialog_notview -ne 1){
        [System.Windows.Forms.MessageBox]::Show($dialog, "Plugin Update Checker")
    }
    
    if ($SettingJson.dialog_notview -eq -1){
        $dialog = "次回以降もアップデート結果についてのダイアログを表示しますか？"

        $YesNoInput = [System.Windows.Forms.MessageBox]::Show($dialog, "Plugin Update Checker","YesNo","Question")
        switch ($YesNoInput) {
            'Yes'{
                $SettingJson.dialog_notview=0
            }
            'No'{
                $SettingJson.dialog_notview=1            
            }
            'Default'{
    
            }
        }
    }
    
    
    ConvertTo-Json -InputObject $SettingJson -Depth 32 | Out-File "./setting.json" -Encoding utf8


    Start-Process -FilePath $SettingJson.aviutl_path
}else{
    $dialog = "処理が終了しました"

    if ($SettingJson.dialog_notview -ne 1){
        [System.Windows.Forms.MessageBox]::Show($dialog, "Plugin Update Checker")
    }
    
    if ($SettingJson.dialog_notview -eq -1){
        $dialog = "次回以降もアップデート結果についてのダイアログを表示しますか？"

        $YesNoInput = [System.Windows.Forms.MessageBox]::Show($dialog, "Plugin Update Checker","YesNo","Question")
        switch ($YesNoInput) {
            'Yes'{
                $SettingJson.dialog_notview=0
            }
            'No'{
                $SettingJson.dialog_notview=1            
            }
            'Default'{
    
            }
        }
    }

    ConvertTo-Json -InputObject $SettingJson -Depth 32 | Out-File "./setting.json" -Encoding utf8

    Start-Sleep -s [int]$JsonContent.wait_sec
}

