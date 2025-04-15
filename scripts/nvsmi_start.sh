#!/bin/bash
#This script does 2 things:
# 1 - dump configuration settings (.log, .cfg)
# 2 - start the monitoring process (.txt)

CURRENTDIR=$(pwd)

node=$(hostname | awk 'BEGIN { FS = "." } ; {print $1}')

############################
# GPU Configuration settings
# composed by two parts:
# 1 - generic and complete (human friendly)
# 2 - specific (computer friendly)
############################

nvidia-smi -q    > ${CURRENTDIR}/${node}.nvsmi.log

# Define queries

# clocks.current.sm or clocks.sm
# Current frequency of SM (Streaming Multiprocessor) clock.

# clocks.current.graphics or clocks.gr
# Current frequency of graphics (shader) clock.

# clocks.current.memory or clocks.mem
# Current frequency of memory clock.

# clocks.max.sm or clocks.max.sm
# Maximum frequency of SM (Streaming Multiprocessor) clock.

# clocks.max.graphics or clocks.max.gr
# Maximum frequency of graphics (shader) clock.

# clocks.max.memory or clocks.max.mem
# Maximum frequency of memory clock.

# clocks.applications.graphics or clocks.applications.gr
# User specified frequency of graphics (shader) clock.

# clocks.applications.memory or clocks.applications.mem
# User specified frequency of memory clock.

# clocks.default_applications.graphics or clocks.default_applications.gr
# Default frequency of applications graphics (shader) clock.

# clocks.default_applications.memory or clocks.default_applications.mem
# Default frequency of applications memory clock.

# enforced.power.limit
# The power management algorithm's power ceiling, in watts.
# Total board power draw is manipulated by the power management algorithm such that it stays under this value.
# This value is the minimum of various power limiters.

# power.limit
# The software power limit in watts. Set by software like nvidia-smi.
# On Kepler devices Power Limit can be adjusted using [-pl | --power-limit=] switches.

# power.default_limit
# The default power management algorithm's power ceiling, in watts.
# Power Limit will be set back to Default Power Limit after driver unload.

queries=""
queries+="index"
queries+=",timestamp"
queries+=",clocks.sm"      # current
queries+=",clocks.gr"      # current
queries+=",clocks.mem"     # current
queries+=",clocks.video"   # current
queries+=",clocks.max.sm"  # max
queries+=",clocks.max.gr"  # max
queries+=",clocks.max.mem" # max
queries+=",clocks.applications.gr"          # base (when running)
queries+=",clocks.applications.mem"         # base (when running)
queries+=",clocks.default_applications.gr"  # default
queries+=",clocks.default_applications.mem" # default
queries+=",enforced.power.limit"
queries+=",power.limit"
queries+=",power.default_limit"

# Define format
format=""
format+="csv" # mandatory
#format+=",noheader"
format+=",nounits"

nvidia-smi --query-gpu=${queries} --format=${format} > "${CURRENTDIR}/${node}.nvsmi.cfg"


##################################################################
# GPU monitoring (non blocking, please note the & symbol at the end)
##################################################################

# Define queries
queries=""

# power.draw
# The last measured power draw for the entire board, in watts.
# On Ampere or newer devices, returns average power draw over 1 sec.
# On older devices, returns instantaneous power draw.
# Only available if power management is supported.
# This reading is accurate to within +/- 5 watts.

# enforced.power.limit
# The power management algorithm's power ceiling, in watts.
# Total board power draw is manipulated by the power management algorithm such that it stays under this value.
# This value is the minimum of various power limiters.

# power.limit
# The software power limit in watts. Set by software like nvidia-smi.
# On Kepler devices Power Limit can be adjusted using [-pl | --power-limit=] switches.

# power.default_limit
# The default power management algorithm's power ceiling, in watts.
# Power Limit will be set back to Default Power Limit after driver unload.

# clocks.current.sm or clocks.sm
# Current frequency of SM (Streaming Multiprocessor) clock.

# clocks.current.memory or clocks.mem
# Current frequency of memory clock.

# temperature.gpu
# Core GPU temperature. in degrees C.

# temperature.memory
# HBM memory temperature. in degrees C.

# utilization.gpu
# Percent of time over the past sample period during which one or more kernels was executing on the GPU.
# The sample period may be between 1 second and 1/6 second depending on the product.

# utilization.memory
# Percent of time over the past sample period during which global (device) memory was being read or written.
# The sample period may be between 1 second and 1/6 second depending on the product.

# memory.used
# Total memory allocated by active contexts.

# pstate
# The current performance state for the GPU. 
# States range from P0 (maximum performance) to P12 (minimum performance).

queries+="index"
queries+=",timestamp"
queries+=",power.draw"
queries+=",enforced.power.limit"
queries+=",power.limit"
queries+=",power.default_limit"
queries+=",clocks.sm"
queries+=",clocks.mem"
queries+=",temperature.gpu"
queries+=",temperature.memory"
queries+=",utilization.gpu"
queries+=",utilization.memory"
queries+=",memory.used"
queries+=",pstate"

# Define format
format=""
format+="csv"
format+=",noheader"
format+=",nounits"

# Define period
period=1000

# monitoring
#nvidia-smi --query-gpu=$queries --format=$format -lms $period >> $node.nvsmi.txt 2>&1 &
nvidia-smi --query-gpu=${queries} --format=${format} -lms ${period} -f  ${CURRENTDIR}/${node}.nvsmi.txt 

# the process in background will be killed using 'pkill' command,
# however an alternative version based on process id (PID) follows
#nvpid=$!
#echo "nvsmi monitoring launched on $node with PID $nvpid"
#echo $nvpid > $node.nvsmi.pid

#eof

