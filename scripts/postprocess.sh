#!/bin/bash

ARC="$1"
MESH_LEVEL="$2"

if [[ $ARC == "leonardo" ]]; then
   source ./config_leonardo.sh $MESH_LEVEL
elif [[ $ARC == "thea" ]]; then
   source ./config_thea.sh $MESH_LEVEL
else
   echo "Select either 'leonardo' or 'thea'"
   exit
fi

# stop nvidia-smi on all nodes
for node in `scontrol show hostname`; do
  exe="${SCRIPTSDIR}/nvsmi_stop.sh"
  ssh ${node} "cd ${RUNDIR} && ${exe}"
done

