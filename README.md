# PR Issue Nofitication
自分に紐づいた GitHub の Pull Request（レビュー依頼）や Issue を取得し、Discord の Webhook へ通知します。

※このツールは現在開発中です

毎日0時(JST)に現在レビュー依頼が出ているプルリクエストをリポジトリごとに送信します

## セットアップ
### リポジトリのコピー
forkなどを用いてリポジトリを作成してください

### 環境変数の準備
#### GitHub Personal Access Token (PAT) の取得

1. **プロフィール画像 -> Settings -> Developer settings -> Personal access tokens -> Tokens (classic) -> Generate new token -> Generate new token (classic)** と進む
2. 必要に応じて次の項目にチェックを入れる
  - **repo** (プライベートリポジトリにアクセスする場合)
  - **read:org** (Organizationにアクセスする場合)
3. **Generate token**をクリックしてトークンを作成、コピー

#### Discord Webhookの作成
1. **通知を送りたいチャンネルの設定 -> 連携サービス -> ウェブフック -> 新しいウェブフック** と進む
2. 名前、アイコン等を適宜設定
3. **ウェブフックURLをコピー**

#### Discord ユーザーIDの取得(Optional)
メッセージでメンションを行いたい場合に行ってください

1. **詳細設定 -> 開発者モード** を有効化
2. **マイ アカウント** -> ユーザー名の右側にある3点リーダーをクリック
3. **ユーザーIDをコピー** をクリック
### GitHub Secretsに環境変数を設定
1. リポジトリの**Settings**にアクセス
2. **Secrets and variables -> Actions** を選択
3. New repository secret をクリックして以下の値を追加

| Name | Secret | 説明 |
| ---  | ---    | --- |
| `GH_TOKEN` | `ghp_xxxxx` | 取得したPAT |
| `WEBHOOK_URL` | `https://discord/com/api/webhooks/...` | Discord WebhookのURL |
| `DISCORD_UID` | `123456...` | (Optional) メンション先のDiscordユーザーID |
## 動作
### 手動テスト
1. **Actions** を開く
2. **Post Issues/Pull Requests** -> **Run workflow**を選択して実行

### 自動実行
毎日0時 (JST)にワークフローが実行されます

## ライセンス
MIT License
