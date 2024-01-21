# 自動CMカット, HWエンコード対応版 docker-epgstation

[fork元の本家](https://github.com/l3tnun/docker-mirakurun-epgstation) と比べて以下の変更があります。
- [追加]　AArch64/Arm64 専用 (Raspberry Pi 3 ~ など)
- [追加]　[JoinLogoScpTrialSetLinux](https://github.com/tobitti0/JoinLogoScpTrialSetLinux) をベースとした自動CMカット対応
- [追加]　~~vaapi~~ v4l2m2 (Video for Linux2 Memory to Memory I/F) によるハードウェアエンコード (h264, ~~hevc~~) 対応
- [追加]　ffmpeg の opus, fdkaac 対応
- [削除]　mirakurun コンテナ周り

<br>
<br>


# 利用方法
基本的には本家のインストール手順に従ってください。
以下、いくつかの差分, 留意点です。


## AArch64/Arm64
Raspberry Pi 4B で動作確認。
docker イメージのビルドは 25分くらい掛かったと思います。

AArch64 であれば良いので、例えば M1 以降の Apple シリコン搭載 Mac でビルドを行うと、
３分程度でビルドでき、問題なく動作します。



## epgstation/config/*.js
適当なパラメータを設定した状態で置いてあります。
かなりサイズを小さくする方向に振った設定になっているので、適当に変更, 調整してください。
- enc: CMカットなし, x264 ソフトウェアエンコード
- enc_h264-v4l2m2m: CMカットなし, h264_v4l2m2m ハードウェアエンコード
- jlse_h264-v4l2m2m: CMカット**あり**, h264_v4l2m2m ハードウェアエンコード


## ~~vaapi~~ v4l2m2m ハードウェアエンコードについて
Raspberry Pi 4B で動作確認。

エンコードは vf など無しで 67fps, load: 50-60%、
CMカットあり, 720p で 38fps, load: 40% 程度でした。

ライブ視聴は「外部アプリで開く」を有効にして `m2ts 1080p` を選択すると、
load: 30-40% で遅延なく再生できました。



## epgstation/config/config.yml(.template)
`encode`: 上記エンコードスクリプトを参照する設定(例) が書き加えられています。
また `stream` についても vaapi, opus, fdkaac など似たような設定が追加, 変更されています。

`mirakurunPath`: 下記の通り mirakurn コンテナは起動しないので自分の環境に合わせて適宜書き換えてください。


## join_logo_scp 関連
お住まいの地域により放送局の構成が異なることにも関連して、
正しく動作させるには以下について確認, 変更が必要です。

### join_logo_scp_trial/settings/ChList.csv
(m2)ts ファイル名に含まれる放送局名 と logoファイル名との対応表です。

### join_logo_scp_trial/logo/*.lgd
ロゴファイル(*.lgd) は配布できないので空です。
[Amatsukaze](https://github.com/nekopanda/Amatsukaze) などで用意してください。

<br>
<br>

詳しくは [JoinLogoScpTrialSetLinux](https://github.com/tobitti0/JoinLogoScpTrialSetLinux)、およびその改造元を参照してください。


## mirakurun 周り
mirakurun コンテナ周りは動作しないようになっているので、必要に応じて追加してください。


<br>
<br>
以下、fork 元の Readme.md

---
---
---
<br>
<br>



# docker-mirakurun-epgstation

[Mirakurun](https://github.com/Chinachu/Mirakurun) + [EPGStation](https://github.com/l3tnun/EPGStation) の Docker コンテナ

## 前提条件

- Docker, docker-compose の導入が必須
- ホスト上の pcscd は停止する
- チューナーのドライバが適切にインストールされていること

## インストール手順

```sh
curl -sf https://raw.githubusercontent.com/l3tnun/docker-mirakurun-epgstation/v2/setup.sh | sh -s
cd docker-mirakurun-epgstation

#チャンネル設定
vim mirakurun/conf/channels.yml

#コメントアウトされている restart や user の設定を適宜変更する
vim docker-compose.yml
```

## 起動

```sh
sudo docker-compose up -d
```

## チャンネルスキャン地上波のみ(取得漏れが出る場合もあるので注意)

```sh
curl -X PUT "http://localhost:40772/api/config/channels/scan"
```

mirakurun の EPG 更新を待ってからブラウザで http://DockerHostIP:8888 へアクセスし動作を確認する

## 停止

```sh
sudo docker-compose down
```

## 更新

```sh
# mirakurunとdbを更新
sudo docker-compose pull
# epgstationを更新
sudo docker-compose build --pull
# 最新のイメージを元に起動
sudo docker-compose up -d
```

## 設定

### Mirakurun

* ポート番号: 40772

### EPGStation

* ポート番号: 8888
* ポート番号: 8889

### 各種ファイル保存先

* 録画データ

```./recorded```

* サムネイル

```./epgstation/thumbnail```

* 予約情報と HLS 配信時の一時ファイル

```./epgstation/data```

* EPGStation 設定ファイル

```./epgstation/config```

* EPGStation のログ

```./epgstation/logs```

## v1からの移行について

[docs/migration.md](docs/migration.md)を参照
