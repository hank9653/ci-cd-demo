# Docker on Amazon ECS using AWS CloudFormation & CLI

## 前置準備

- GitHub 帳號
- Travis CI 帳號
- AWS 帳號
  - 需先裝好 aws cli

## Step

1. 修改 `./scripts/infra/web.yml` line 18
```
// 格式
{aws_accountId}.dkr.ecr.{aws_default_region}.amazonaws.com/repo:latest

// 例:
013686061143.dkr.ecr.ap-northeast-1.amazonaws.com/repo:latest
```

2. 建立所需要的 infra
```
$ sh ./scripts/create-infra.sh
```

3. 設定 Travis CI 環境變數 `AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`

4. 修改 `server.js` 的 `Hello World!` 為 `Demo`

5. 當程式碼推到 GitHub 上時會觸發 Travis CI 進行 CI / CD 流程

6. 結束記得刪除 infra
```
$ sh ./scripts/delete-infra.sh
```

## CI/CD 架構圖

![CI/CD 架構圖](https://drive.google.com/uc?export=view&id=1818yGRrzYMWxomZ5u6qG2Efomu5GBQME)
