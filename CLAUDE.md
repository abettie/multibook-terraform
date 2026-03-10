# CLAUDE.md

## 概要

multibook の AWS インフラを Terraform で管理するリポジトリ。ステージング (`stg/`) と本番 (`prod/`) の2環境を、それぞれ独立した AWS アカウントで運用している。

## ディレクトリ構成
.
├── modules/
│   ├── network/
│   ├── security/
│   ├── compute/
│   └── ...
├── stg/          # ステージング環境
└── prod/         # 本番環境

## バージョン
- Terraform: >= 1.x.x
- AWS Provider: ~> 5.x

## コマンド

```bash
# フォーマット (リポジトリ全体)
terraform fmt -recursive

# 構文検証 (各環境ディレクトリで実行)
cd stg && terraform validate

# ステージング環境
cd stg
aws sso login --profile multibook-stg
export AWS_PROFILE=multibook-stg && terraform init
export AWS_PROFILE=multibook-stg && terraform plan
export AWS_PROFILE=multibook-stg && terraform apply

# 本番環境
cd prod
aws sso login --profile multibook-prod
export AWS_PROFILE=multibook-prod && terraform init
export AWS_PROFILE=multibook-prod && terraform plan
export AWS_PROFILE=multibook-prod && terraform apply
```

## アーキテクチャ

### モジュール構成

`modules/` 配下のモジュールを `stg/` と `prod/` から呼び出す構造。各環境の `main.tf` がルートモジュール。各モジュールは `main.tf` / `variables.tf` / `outputs.tf` の3ファイルで構成する。

| モジュール | 役割 |
|---|---|
| `network` | VPC、パブリックサブネット、IGW |
| `security` | Security Group |
| `compute` | EC2 |
| `loadbalancer` | ALB |
| `acm-certificate` | ACM証明書 |
| `cloudfront-alb` | CloudFront → ALB |
| `cloudfront-s3` | CloudFront → S3 |
| `s3-image` | 画像保存用 S3 バケット |
| `route53-hosted-zone` | Route53 ホストゾーン |
| `route53-records` | Route53 Aレコード |

### 通信フロー

```
ユーザー → CloudFront (Webアプリ用) → ALB (HTTPS) → EC2 (nginx)
ユーザー → CloudFront (画像用) → S3
```

CloudFront → ALB 間は IPv6 (HTTPS only, TLSv1.2)。EC2 はパブリック IP を持たない。

### ACM 証明書のリージョン

- ALB 用: `ap-northeast-1` (`module.acm_tokyo`)
- CloudFront 用: `us-east-1` (CloudFront の要件、`aws.us_east_1` プロバイダー使用)

### State 管理

S3 バックエンド + ネイティブロック (`use_lockfile = true`、Terraform 1.10以降)。DynamoDB は不要。

## 禁止事項
- terraform apply を自動実行しない（plan まで）
- シークレットをコードにハードコードしない

## 初回デプロイ時の注意

SSL 証明書の DNS 検証のため、必ず以下の順序でデプロイする：

1. `terraform apply -target=module.hosted_zone` でホストゾーンを先に作成
2. 出力された NS レコードをドメインレジストラに設定し、DNS 伝播を待つ
3. `terraform apply` で残りのリソースをデプロイ
