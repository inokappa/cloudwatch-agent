function get_instance_id() {
  Instance_id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
}

function get_hostname() {
  hostname=`curl -s http://169.254.169.254/latest/meta-data/hostname`
}

function get_load_average() {
  v=`uptime |awk '{print $10}' | cut -d ',' -f 1`
}

function get_cpu_usage() {
  v=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
}

function get_memory_used() {
  t=`free -m | grep 'Mem' | tr -s ' ' | cut -d ' ' -f 2`
  f=`free -m | grep 'buffers/cache' | tr -s ' ' | cut -d ' ' -f 4`
  let "v=100-f*100/t"
}

function get_disk_used() {
  # Root Partition only...orz
  v=`df -m / | tail -n+2 | while read fs size used rest ; do if [[ $rest ]] ; then echo $rest; fi; done | awk '{print $2}' | sed s/\%//g`
}

function generate_json() {
  metrics_param ${1}
  cat << EOT > /tmp/${1}.json
[
  {
    "MetricName": "${1}",
    "Value": ${2},
    "Unit": "${Unit}",
    "Dimensions": [
      {
        "Name": "Instanceid",
        "Value": "${Instance_id}"
      },
      {
        "Name": "Hostname",
        "Value": "${hostname}"
      }
    ]
  }
]
EOT
}

function put_metrics_data() {
  aws --region ${REGION} cloudwatch put-metric-data \
    --namespace "${NAMESPACE}" \
    --metric-data file:///tmp/${1}.json
}
