# Terraform 構成手順

## 構成概要

このリポジトリは multibook の AWS インフラを Terraform で管理します。
`infrastructure/` ディレクトリ以下に環境別のソースとモジュールが配置されています。

```
infrastructure/
├── bootstrap/   # Terraform state 用 S3 バケット作成
├── modules/     # 共通モジュール
│   ├── acm-certificate/
│   ├── cloudfront-alb/
│   ├── cloudfront-s3/
│   ├── compute/
│   ├── loadbalancer/
│   ├── network/
│   ├── route53-hosted-zone/
│   ├── route53-records/
│   ├── s3-image/
│   └── security/
├── stg/         # ステージング環境
└── prod/        # 本番環境
```

---

## 事前準備

### 1. Terraform のインストール

[Terraformのインストール方法](./terraform-install.md) を参照してください。

### 2. AWS CLI 認証情報の設定

[AWS CLI認証情報の設定方法](./aws-credentials.md) を参照してください。

### 3. Terraform state 用 S3 バケットの作成

state ファイルを保存する S3 バケットを事前に作成します。
`infrastructure/bootstrap/` は Terraform の remote backend を使わずにローカル state で動かします。

```sh
cd infrastructure/bootstrap

# terraform.tfvars を作成（.gitignore 対象）
cat > terraform.tfvars <<EOF
stg_state_bucket_name  = "terraform-state-stg-<一意のID>"
prod_state_bucket_name = "terraform-state-prod-<一意のID>"
EOF

terraform init
terraform apply
```

作成後、`infrastructure/stg/main.tf` と `infrastructure/prod/main.tf` の backend ブロックにバケット名を設定してください。

### 4. Route53 ホストゾーンの先行構築と NS レコードの設定

Route53 ホストゾーンは Terraform で作成しますが、**ドメインレジストラへの NS レコード登録は手動で行う必要があります**。

手順：

1. 対象環境の `terraform apply` を実行してホストゾーンを作成する
2. `terraform output hosted_zone_name_servers` でネームサーバーを確認する
3. お名前ドットコム等のドメイン管理画面で、上記ネームサーバーを NS レコードとして登録する
4. DNS 伝播（最大 48 時間）を待ってから、ACM 証明書の検証が完了することを確認する

> **注意**: NS レコードが正しく設定されていないと ACM 証明書の DNS 検証がタイムアウトします。

---

## 変数ファイルの作成

各環境の `terraform.tfvars` は `.gitignore` 対象です。
初回セットアップ時は以下を参考に作成してください。

**stg 環境 (`infrastructure/stg/terraform.tfvars`):**
```hcl
zone_domain     = "multibook-test.makedara.work"
app_domain      = "app.multibook-test.makedara.work"
image_domain    = "img.multibook-test.makedara.work"
image_s3_bucket = "makedara-multibook"
public_key      = "ssh-rsa AAAA..."
```

**prod 環境 (`infrastructure/prod/terraform.tfvars`):**
```hcl
zone_domain     = "multibook.makedara.work"
app_domain      = "app.multibook.makedara.work"
image_domain    = "img.multibook.makedara.work"
image_s3_bucket = "makedara-multibook-prod"
public_key      = "ssh-rsa AAAA..."
```

---

## 環境の操作

### ステージング環境

```sh
cd infrastructure/stg
terraform init
terraform plan
terraform apply
```

### 本番環境

```sh
cd infrastructure/prod
terraform init
terraform plan
terraform apply
```

---

## 注意事項

- ACM 証明書の DNS 検証には Route53 ホストゾーンへの NS レコード設定が必要です。
- `stg/` と `prod/` はそれぞれ独立した Terraform state を持ちます。
- `terraform.tfvars` には秘密情報（SSH 公開鍵など）が含まれるため `.gitignore` で管理外となっています。
