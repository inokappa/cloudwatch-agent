function create_alarm() {
  metrics_param ${1}
  # 監視対象の値が ${Threshold}% 以上で 1 回以上続いたらアラートを投げる
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
