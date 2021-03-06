#! /bin/bash

set -e

HOST_NAME=$(hostname -s)
WEB_TASK_URL='https://wt-3c52d1a0af632076ec7752be78cc0421-0.sandbox.auth0-extend.com/gpu'
IP_ADDRESS=$(ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n')

declare -a percentageList
declare -a gpuNameList

function getGpu() {
  local output="$(nvidia-smi --format=csv,noheader --query-gpu=utilization.gpu | tr -d ' %')"
  local i=0
  for percentage in ${output}
  do
    percentageList[$i]=${percentage}
    let "i += 1"
  done
  for ((i=0; i < ${#percentageList[@]}; i++))
  do
    gpuNameList[$i]="${HOST_NAME}_$i"
  done
}

function updateByCurl() {
  for ((i = 0; i < ${#percentageList[@]}; i++))
  do
    param="${param} --data ${gpuNameList[$i]}=${percentageList[$i]}"
  done
  param="${param} --data ${HOST_NAME}_IP=${IP_ADDRESS}"
  echo $param
  ping "www.baidu.com" -c 3 > /dev/null
  # If online
  if [ $? -eq 0 ]
  then
    result=$(curl -s -k ${param} ${WEB_TASK_URL})
  else
    # Login campus net
    curl -d 'DDDDD=2017140433&upass=215035&AMKKey=' '10.3.8.211/a11.htm' > /dev/null
    result=$(curl -s -k ${param} ${WEB_TASK_URL})
    # Logout campus net
    curl 10.3.8.211/F.htm > /dev/null
  fi
  echo $result
}

getGpu
updateByCurl
