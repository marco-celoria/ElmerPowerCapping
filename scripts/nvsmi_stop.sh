#!/bin/bash
# shut down energy monitoring
#
pkill nvidia-smi



# An alternative version based on process id (PID), follows
#node=$(hostname | awk -F. '{print $1}')
#ITXT="$node.nvsmi.pid"
#nvpid=$(< $ITXT)
#kill $nvpid
#kill -9 $nvpid
#echo "killed process $nvpid on $node"


#eof






