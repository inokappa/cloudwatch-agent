# EC2 上のリソースを CloudWatch に投げるスクリプト

## なんすかこれ？

`aws cli` の `Python` 版を使って EC2 インスタンス上の以下のリソースを `CloudWatch` のカスタムメトリクスに投げるスクリプト。

 * `CPU` 使用率
 * `Load Average`
 * メモリ使用率
 * `Root` パーティションのディスク使用率
 * 初回の動作時のみ `Alarm` を設定する（`SNS` の `Topic ARN` が必須なので事前に作成しておくこと）

***

## 使い方

#### git clone

監視したいサーバー上でスクリプトを `git clone` してくる

~~~~
git clone  https://github.com/inokappa/cloudwatch-agent.git
~~~~

#### 実行権限を設定する

~~~~
cd cloudwatch-agent
chmod 755 *.sh
chmod 755 ./plugins/*.sh
~~~~

#### 初期設定として aws-watch.sh 内の以下を環境に応じて設定する

 * REGION（リージョンを指定）
 * NAMESPACE（`CloudWatch` に登録したい監視グループ）
 * ARN（`AWS` の `SNS` で設定した `Topic ARN`）
 * THRESHHOLD（`CPU` 使用率、メモリ使用率、ディスク使用率のしきい値）

#### AWS_CREDENTIAL_FILE を修正

`API` の鍵ファイルを以下のように作成。

~~~~
AWSAccessKeyId=AKxxxxxxxxxxxxxxxxx
AWSSecretKey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
~~~~

作成した鍵ファイルのパスを指定する。

~~~~
export AWS_CREDENTIAL_FILE=/path/to/key
~~~~

尚、鍵ファイルの権限管理は適切に行うこと。

#### 適当に cron に仕掛けたりして...

~~~~
*/5 * * * * cd /path/to/cloudwatch-agent/ && ./cloudwatch-agent.sh >/dev/null 2>&1
~~~~

#### アラートのしきい値

現状は以下のような固定値となっている。

 * 監視対象の値が ${Threshold}％ 以上が 1 回以上続いたらアラート
 * `Load Average` は `CPU` のコア数を超える値が 1 回以上続いたらアラート

以下のシェル関数で定義されている。

~~~~
function create_alarm() {
  metrics_param ${1}
  aws --region ${REGION} cloudwatch put-metric-alarm \
    --actions-enabled \
    --alarm-name ${NAMESPACE}-${hostname}-${1} \
    --alarm-actions ${ARN} \
    --ok-actions ${ARN} \
    --metric-name ${1} \
    --namespace ${NAMESPACE} \
    --statistic Average \
    --period 300 \
    --evaluation-periods 1 \
    --threshold ${Threshold} \
    --unit ${Unit} \
    --comparison-operator GreaterThanOrEqualToThreshold \
    --dimensions Name=Instanceid,Value=${Instance_id} Name=Hostname,Value=${hostname}
  if [ $? = "0" ];then
    touch "/tmp/${1}_alarm_created"
  else
    echo "Create Alarm Failure."
  fi
}
~~~~

***

## 画面


***

## 参考

 * [AWS CLI CloudWatch](http://docs.aws.amazon.com/cli/latest/reference/cloudwatch/index.html)
 * [Regions and Endpoints](http://docs.aws.amazon.com/general/latest/gr/rande.html#cw_region)

***

## todo

***

## Chef

 * [cloudwatch-agent-chef]()
