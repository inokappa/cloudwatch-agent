#!/usr/bin/env bash

for file in ./plugin/*.sh
do
  source ${file}
done

export AWS_CREDENTIAL_FILE="Please set Your AWS API KEY Path"

declare -A M
M=( \
  ["load_average"]="get_load_average" \
  ["cpu_usage"]="get_cpu_usage" \
  ["mem_used"]="get_memory_used" \
  ["disk_used"]="get_disk_used"
)

REGION="Please set AWS Regeion"
NAMESPACE="Please set Namespace"
ARN="Please set AWS SNS Topic ARN"
THRESHHOLD="Please set Threshhold"

function metrics_param() {
  case "${1}" in
    "load_average" ) Unit="${u}";Threshold="${t}" ;;
    "cpu_usage" ) Unit="${u}";Threshold="${t}" ;;
    "mem_used" ) Unit="${u}";Threshold="${t}" ;;
    "disk_used" ) Unit="${u}";Threshold="${t}" ;;
  esac
}

# Get Instance ID and Hostname
get_instance_id
get_hostname
# Get Metrics and Put to Metrics
for metrics in ${!M[@]}
do
  # for debug
  #echo "${metrics} => ${M[$metrics]}"
  ${M[$metrics]}
  generate_json ${metrics} ${v}
  put_metrics_data ${metrics}
  if [ -f /tmp/${metrics}_alarm_created ];then
    echo "Alarm Exist"
  else
    create_alarm ${metrics}
  fi
done
