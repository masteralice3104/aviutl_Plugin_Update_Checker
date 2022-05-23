# Plugin Update Checker

## 本文の前に
"patch.aul"の制作者のePiさんに多大なる感謝を申し上げます。
**このソフトはアルファ版です。設定が突然飛んだりする可能性が非常に高いです。ご注意ください**

## どういうソフト？

patch.aulは**頻繁に更新していて、かつプラグインはとても素晴らしいもの**だと思います~~が、単純にアップデートが面倒~~ 。~~なんてことを言うんだ~~

しかしこのソフトを使えばpatch.aulの更新を自動で確認し、さらにダウンロード&展開までしてくれます！

アップデート終了後にはAviutlを自動で起動する設定(変更可能)になっているので、Aviutlのショートカットを置き換えると起動時に毎回確認できるようになります。

## 導入方法
1. aviutl_Plugin_Update_Checkerフォルダを"aviutl.exeと同じフォルダ"に入れる
1. !_update_checker.batを開く

これだけでpatch.aulのアップデートがされます！


## ほかの機能
実はGithubのRelease/latestで公開されているプラグインであれば何でもいけます(下記参照)

## 注意事項
間違ってもmain.ps1を直接開かないようにしてください

アップデート処理が正常に走らずに起動しなくなることがあります


## このソフト自体の設定の仕方：setting.jsonの仕様

    {
        "end_aviutl":  true,
        "aviutl_path":  "../aviutl.exe",
        "dialog_notview":   false,
        "wait_sec":  2,
        "temp_dir":  "./temp/",
        "temp_zip":  "temp.zip"
    }

**"end_aviutl":  true**
- 終了時にAviutlを起動する設定です
- trueで起動、falseで起動しない設定になります


**"aviutl_path":  "../aviutl.exe"**
- "end_aviutl"で起動する際のAviutlのパスを設定します

**"dialog_notview":   -1**
- 最後に出る「処理が終了しました」ダイアログが出るかの設定
- -1　→ 未設定
- 0 → ダイアログを出す
- 1 → ダイアログを出さない

**"wait_sec":  2**
- "end_aviutl": falseの時、終了時にかかるウエイトの設定です
- 単位は秒です

**"temp_dir":  "./temp/"**
- テンポラリフォルダのパスです
- このフォルダは自動生成・削除されるためこのパスに該当するフォルダ・ファイルは作成しないでください

**"temp_zip":  "temp.zip"**
- githubからダウンロードした際の保存パスです
- このファイルは自動生成・上書き・削除されるためこのパスに該当するファイルは作成しないでください。



## 更新を確認するプラグインの設定の仕方：check.jsonの仕様
デフォルトのcheck.jsonを簡略化したものは以下のとおりです
    {

        "plugin":  [
                    {
                        "name":  "patch.aul",
                        "use":   true,
                        "releases":  "https://github.com/ePi5131/patch.aul/releases/latest",
                        "tag_name":  "r20",
                        "update_block":  false,
                        "copy_folder":  "..\/",
                        "copy_file":  ["patch.aul"]
                    }
                ]

    }
    



**"plugin":**
- プラグインに関する配列型です
- patch.aulの想定しかしていませんが、他のプラグインでも以下の条件に当てはまれば同様に設定することでおそらく自動アップデート可能となります
    - Github
    - release/latestの公開をしている
    - pre-releaseではない 

**"name":  "patch.aul"**
- 表示名です

**"use":   true**
- 使っているというフラグです
- trueでなければ更新のチェックすらされません

**"releases":  "https://github.com/ePi5131/patch.aul/releases/latest"**
- releasesのURLです。
- "https://github.com/～～～～/～～～～/releases/latest"の形式であれば読み込みに行けます
- apiのレート制限にひっかかるため、apiではなくHTMLを読みに行くようにしました
- ~~～～/tag/＊＊＊＊で終わるURLでも読めるはずですがアップデートされないのでやめましょう~~

**"tag_name":  "r20"**
- タグ名です
- 一致するかどうかだけ判別しています
- アップデート後、この項目は自動で書き換えられます

**"update_block":  false**
- アップデートをブロックする際にtrueにしてください
- 不具合が発生した際などにtrueにすると良いです
    - 不具合が直った後falseに戻すのを忘れないようにしましょう

**"copy_folder":  "..\/"**
- スクリプトのインストール先のパスです。
- 必ず最後に"/"(スラッシュ)を入れてください
    - 入れないと大変なことになります
    - エスケープは意味がなさそうです
- patch.aulはaviutl.exeと同じパスに置くべきらしいので、このパスになっています
- 普通のプラグインとかは"../plugins/"とかがいいんじゃないでしょうか

**"copy_file":  ["patch.aul"]**
- コピーするべきスクリプトのファイル自体のパスです
- 配列型扱いです
- zipの中身をそのまま"temp_dir"にぶちまけるので、そこからコピーするべきファイルを指定してください
- "copy_folder"で指定された先にコピーされます
- 2つ以上のファイルを指定する際には[]で配列にするのをお忘れなく
    - ファイルが1つだけだと、起動時にカッコを取られる編集をされてしまいます(動作には支障ありません)


## その他
- スクリプトなのでテキストエディタで開けば読めます
- どんな通信しているのかを知りたい方はInvoke-WebRequestの部分を是非見てください
- ~~怪しい通信するソフトは嫌いです~~
- MITライセンスです
