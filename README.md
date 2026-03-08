# multibook-terraform

multibook の AWS インフラを Terraform で管理するリポジトリです。

## ディレクトリ構成

```
/
├── modules/             # 共通Terraformモジュール
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
├── prod/                # 本番環境用 Terraformソース
├── stg/                 # ステージング環境用 Terraformソース
└── README.md
```

## 環境構成

本プロジェクトでは、以下の2つの環境を使用しています：

- **本番環境 (Production)**: 本番用AWSアカウントで管理され、`prod/`配下のTerraformソースで構成
- **ステージング環境 (Staging)**: 開発・検証用AWSアカウントで管理され、`stg/`配下のTerraformソースで構成

各環境は独立したAWSアカウントで運用され、Terraformによってインフラストラクチャがコード管理されています。

## 技術スタック

### インフラストラクチャ
- AWS (EC2, ALB, CloudFront, S3, Route53, ACM など)
- Terraform

## セットアップ

### 前提条件
- Terraformがインストールされていること（[インストール方法](./terraform-install.md)を参照）
- 各環境のAWSアカウントへのアクセス権限が設定されていること
- AWS CLIが設定されていること（[設定方法](./aws-credentials.md)を参照）

### Terraform State管理

TerraformのstateファイルはS3バケットで管理されています。

| 環境 | S3バケット | リージョン |
|------|-----------|-----------|
| ステージング | `terraform-state-stg-20c4f2da-888b-fb2b-9b8f-bac50c649cb7` | `ap-northeast-1` |
| 本番 | `terraform-state-prod-20c4f2da-888b-fb2b-9b8f-bac50c649cb7` | `ap-northeast-1` |

stateファイルは暗号化されて保存され、S3ネイティブのロック機構（`use_lockfile`）で同時実行を防止します。

> **Note**: Terraform 1.10以降では、S3ネイティブのステートロック機能を使用しており、DynamoDBテーブルは不要です。

#### 初回セットアップ（S3バケットの作成）

初めてTerraformを使用する場合、stateファイル保存用のS3バケットを事前に作成する必要があります：

```bash
# ステージング環境用
aws sso login --profile multibook-stg
export AWS_PROFILE=multibook-stg && aws s3api create-bucket \
  --bucket terraform-state-stg-20c4f2da-888b-fb2b-9b8f-bac50c649cb7 \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

export AWS_PROFILE=multibook-stg && aws s3api put-bucket-versioning \
  --bucket terraform-state-stg-20c4f2da-888b-fb2b-9b8f-bac50c649cb7 \
  --versioning-configuration Status=Enabled

# 本番環境用
aws sso login --profile multibook-prod
export AWS_PROFILE=multibook-prod && aws s3api create-bucket \
  --bucket terraform-state-prod-20c4f2da-888b-fb2b-9b8f-bac50c649cb7 \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

export AWS_PROFILE=multibook-prod && aws s3api put-bucket-versioning \
  --bucket terraform-state-prod-20c4f2da-888b-fb2b-9b8f-bac50c649cb7 \
  --versioning-configuration Status=Enabled
```

### インフラストラクチャのデプロイ

#### 初回デプロイ時の注意事項

SSL証明書の発行にはDNS検証が必要なため、以下の手順でデプロイを行ってください：

1. **ホストゾーンの先行作成**

   まず、Route53のホストゾーンのみを作成します：
   ```bash
   cd [環境]  # prod または stg
   aws sso login --profile [プロファイル名]
   export AWS_PROFILE=[プロファイル名] && terraform init
   export AWS_PROFILE=[プロファイル名] && terraform plan -target=module.hosted_zone
   export AWS_PROFILE=[プロファイル名] && terraform apply -target=module.hosted_zone
   ```

2. **ドメインレジストラでNSレコードの設定**

   上記コマンド実行後に出力されるネームサーバー情報を、ドメインレジストラ側で設定してください。
   DNSの伝播には数分から48時間程度かかる場合があります。

3. **残りのリソースのデプロイ**

   NSレコードの設定が完了し、DNSの伝播を確認したら、残りのリソースをデプロイします：
   ```bash
   export AWS_PROFILE=[プロファイル名] && terraform plan
   export AWS_PROFILE=[プロファイル名] && terraform apply
   ```

#### ステージング環境
(例)
```bash
cd stg
aws sso login --profile multibook-stg
export AWS_PROFILE=multibook-stg && terraform init
export AWS_PROFILE=multibook-stg && terraform plan
export AWS_PROFILE=multibook-stg && terraform apply
```

#### 本番環境
(例)
```bash
cd prod
aws sso login --profile multibook-prod
export AWS_PROFILE=multibook-prod && terraform init
export AWS_PROFILE=multibook-prod && terraform plan
export AWS_PROFILE=multibook-prod && terraform apply
```

### 変数ファイルの作成

各環境の `terraform.tfvars` は `.gitignore` 対象のため、`terraform.tfvars.sample` をコピーして作成してください。

```bash
# ステージング環境
cp stg/terraform.tfvars.sample stg/terraform.tfvars

# 本番環境
cp prod/terraform.tfvars.sample prod/terraform.tfvars
```

コピー後、各ファイルの値を環境に合わせて設定してください。

## 注意事項

- 本番環境への変更は慎重に行ってください
- Terraformの実行前には必ず`plan`で変更内容を確認してください
- 機密情報（SSH公開鍵など）はリポジトリにコミットしないでください
- `terraform.tfvars` には機密情報が含まれるため `.gitignore` で管理外となっています
