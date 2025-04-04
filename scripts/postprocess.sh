#!/bin/bash

arc="$1"

if [[ $arc == "leonardo" ]]; then
   source ./config_leonardo.sh
elif [[ $arc == "thea" ]]; then
   source ./config_thea.sh
else
   echo "Select either 'leonardo' or 'thea'"
   exit
fi

# stop nvidia-smi on all nodes
for node in `scontrol show hostname`; do
  exe="${SCRIPTSDIR}/nvsmi_stop.sh"
  ssh ${node} "cd ${RUNDIR} && ${exe}"
done

