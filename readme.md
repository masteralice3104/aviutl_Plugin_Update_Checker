# Plugin Update Checker

## 本文の前に
"patch.aul"の制作者のePiさんに多大なる感謝を申し上げます。
**このソフトはアルファ版です。設定やファイルが突然飛んだりする可能性が非常に高いです。十分ご注意ください。**



## どういうソフト？

patch.aulは**頻繁に更新していて、かつプラグインはとても素晴らしいもの**だと思います~~が、単純にアップデートが面倒~~ 。~~なんてことを言うんだ~~

しかしこのソフトを使えばpatch.aulの更新を自動で確認し、さらにダウンロード&展開までしてくれます！

しかもソースコードが公開されていて、どう通信しているのかを確認することができます！
~~クソコードなので読みやすいかどうかは別ですが~~

アップデート終了後にはAviutlを自動で起動する設定(変更可能)になっているので、Aviutlのショートカットを置き換えると起動時に毎回確認できるようになります。

## 導入方法
1. aviutl_Plugin_Update_Checkerフォルダを"aviutl.exeと同じフォルダ"に入れる
1. !_update_checker.batを開く

これだけでpatch.aulのアップデートがされます！

## 導入する利点
- ものぐさな人でもプラグインのアップデートについていける
- 余計な通信はしない
    - 見に行く場所はGithubのみ
- OSS
- PowershellとCMDのスクリプトなのでWindowsの標準で動く
    - テキストエディタで開けば中身がまるわかり


## ほかの機能
実はGithubのRelease/latestやTagsで公開されているプラグインであれば何でもいけます(下記参照)

## 注意事項
メイン機能はmain.ps1に集約されていますが、直接powershellなどで開かないようにしてください

アップデート処理や警告処理などが正常に走らず、最悪の場合プログラム自体が起動しなくなることがあります


## このソフト自体の設定の仕方：setting.jsonの仕様

    {
        "ver":4,
        "end_aviutl":  true,
        "aviutl_path":  "..\\aviutl.exe",
        "dialog_notview":   -1,
        "wait_sec":  2,
        "temp_dir":  ".\\temp\\",
        "temp_zip":  "temp.zip"
    }

**"ver":    4**
- ファイル形式のバージョンです
- ここのverがチェックされます
- 該当しないverのjsonは使わないようにしています

**"end_aviutl":  true**
- 終了時にAviutlを起動する設定です
- trueで起動、falseで起動しない設定になります


**"aviutl_path":  "..\\\\aviutl.exe"**
- "end_aviutl"で起動する際のAviutlのパスを設定します
- 絶対パスでもいけるはずです

**"dialog_notview":   -1**
- 最後に出る「処理が終了しました」ダイアログが出るかの設定
- -1　→ 未設定
- 0 → ダイアログを出す
- 1 → ダイアログを出さない

**"wait_sec":  2**
- "end_aviutl": falseの時、終了時にかかるウエイトの設定です
- 単位は秒です

**"temp_dir":  ".\\\\temp\\\\"**
- テンポラリフォルダのパスです
- このフォルダは自動生成・削除されるためこのパスに該当するフォルダ・ファイルは作成しないでください

**"temp_zip":  "temp.zip"**
- githubからダウンロードした際の保存パスです
- このファイルは自動生成・上書き・削除されるためこのパスに該当するファイルは作成しないでください。



## 更新を確認するプラグインの設定の仕方：check.jsonの仕様
デフォルトのcheck.jsonを簡略化したものは以下のとおりです

    {
        "ver":4,
        "plugin":  [
                    {
                        "name":  "patch.aul",
                        "use":  true,
                        "link":  "https://github.com/ePi5131/patch.aul",
                        "tag_name":  null,
                        "update_block":  false,
                        "copy_folder":  "..\\",
                        "copy_file":  "patch.aul"
                    },
                    {
                        "name":  "Plugin_Update_Checker",
                        "use":  true,
                        "link":"https://github.com/masteralice3104/aviutl_Plugin_Update_Checker",
                        "tag_name":  null,
                        "update_block":  false,
                        "copy_folder":  "..\\",
                        "copy_file":  [
                                            ".\\aviutl_Plugin_Update_Checker\\*"
                                        ],
                            "type":"releases"
                    }
                ]
    }
    



**"ver":    4**
- ファイル形式のバージョンです
- ここのverがチェックされます
- 該当しないverのjsonは使わないようにしています

**"plugin":**
- プラグインに関する配列型です
- patch.aulの想定しかしていませんが、他のプラグインでも以下の条件に当てはまれば同様に設定することで自動アップデート可能となります
    - Github
    - release/latestの公開をしている
        - デフォルトはこちらの設定です
        - "type":"tags"を指定した場合に限り、最新のtagsがついたreleaseを見に行くことができます
    - Assetsが以下の条件
        - 一番上のファイルをダウンロードする場合
        - Source codeではない場合
            - ~~プラグインをSource codeで広めようとするな~~
            - zip内のフォルダ名の固定ができないので自動でアップデートできない

**"name":  "patch.aul"**
- 表示名です
- 様々な表示の際に使われます
- 読みやすい名前にするもよし、プロジェクトページからコピペしてくるのもよしです

**"use":   true**
- 使っているというフラグです
- trueでなければ更新のチェックすらされません

**"link":  "https://github.com/masteralice3104/aviutl_Plugin_Update_Checker"**
- 更新を確認するべきプラグインのGithubのURLです
- 最後に"/"、"/tags"、"/releases/latest"などを入れないでください

**"tag_name":  "r20"**
- タグ名です
- 一致するかどうかだけ判別しています
- アップデート後、この項目は自動で書き換えられます

**"update_block":  false**
- アップデートをブロックする際にtrueにしてください
- 不具合が発生した際などにtrueにすると良いです
    - 不具合が直った後falseに戻すのを忘れないようにしましょう

**"copy_folder":  "..\\"**
- スクリプトのインストール先のパスです。
- 必ず最後に"\\"(バックスラッシュ2コ)を入れてください
    - 入れないと大変なことになります
- patch.aulはaviutl.exeと同じパスに置くべきらしいので、このパスになっています
- 普通のプラグインとかは"../plugins/"とかがいいんじゃないでしょうか

**"copy_file":  ["patch.aul"]**
- コピーするべきスクリプトのファイル自体のパスです
- 配列型扱いです
- zipの中身をそのまま"temp_dir"にぶちまけるので、そこからコピーするべきファイルを指定してください
- "copy_folder"で指定された先にコピーされます
- 2つ以上のファイルを指定する際には[]で配列にするのを忘れないでください
    - ファイルが1つだけだと、起動時にカッコを取られる編集をされてしまいます(動作には支障ありません)
- ".\\\\aviutl_Plugin_Update_Checker\\\\*"みたいにするとフォルダごとコピーできます
    - フォルダごとコピーする機能は以前不具合が多発していた(特にver0.5.0)ので自己責任において使用してください

**"type":   "releases"**
- 更新確認の際にどこを見に行くかを指定できます
- 必須ではありません
    - releases  : デフォルト動作、releases/latestを見に行きます
    - tags      : tagsページの一番上に表示されるバージョンを見に行きます



### 廃止されたもの
**"tags":"https://github.com/masteralice3104/aviutl_Plugin_Update_Checker/tags"**
- json ver 4で廃止されました

**"releases":  "https://github.com/ePi5131/patch.aul/releases/latest"**
- json ver 4で廃止されました


## その他
### スクリプトの中身について
- スクリプトなのでテキストエディタで開けば読めます
    - どんな通信しているのかを知りたい方はInvoke-WebRequestの部分を是非見てください
    - ~~怪しい通信するソフトは嫌いです~~

### 免責について
- このソフトを使用したことによる損害は保証しません
    - 自己責任の上で使用してください

### プルリクについて
- 作者は**ぽんこつ**なため行き当たりばったりなコードを書いています
    - なのでプルリク歓迎です

### ライセンスについて
- MITライセンスです

### これ作った人ってどんな人だよ
- https://dic.nicovideo.jp/a/%E7%B9%B0%E3%82%8A%E4%B8%8A%E3%81%92p
- 片手間に作ってるので対応遅れたらすみません
