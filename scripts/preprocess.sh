#!/bin/bash
# start nvidia-smi on all nodes

arc="$1"

if [[ $arc == "leonardo" ]]; then
   source ./config_leonardo.sh
elif [[ $arc == "thea" ]]; then
   source ./config_thea.sh
else
   echo "Select either 'leonardo' or 'thea'"
   exit
fi

for node in `scontrol show hostname`; do
  echo $node >> "${RUNDIR}/nodelist.txt"
done

for node in `scontrol show hostname`; do
  exe="${SCRIPTSDIR}/nvsmi_start.sh"
  ssh ${node} "cd ${RUNDIR} && ${exe}" &
done


