# openai-forwarder

このリポジトリはOpenAIのAPIキーを隠蔽するためのlambdaのリソースとそのソースコードが置かれています。

## terraform

terraformは他のAWSリソースに影響を与えないように、このリポジトリで使うためだけのIAM Roleを用意した。

tfstateもs3にtfstate-openai-forwarderを用意していて、他から独立している。

## 動作確認
### ローカルでopenai-forwarder.pyの動作確認

ファイルの末尾に以下のように書いて `poetry run python openai-forwarder.py`で実行できる。

```python
if __name__ == '__main__':
  # write any code
```

### lambdaの動作確認
テストイベント `test` が保存されていて、簡単なpromptを投げる。
ログはCloudWatchで確認できる。
terraformのiam_role_pollicyはCloudWatchに書き込むためのもの。

### lambdaにtestというテストイベントが
## デプロイ

アプリケーションの変更はtaskで行う。AWSのリソースを変更した場合はterraformを使う。

- task deploy
    - lambda用にソースコードをzipにかためてデプロイする
- terraform apply
    - AWSのリソースを変更した場合はterraformコマンドを使う

## secrets

Githubシークレットに必要なキーを登録してある。伝搬ルールは以下。

1. Github Secrets
2. Github Actions{{ seacrets.hogehoge }}でアクセスする
3. Taskfile taskコマンド実行前に環境変数として渡す
4. 各コマンド