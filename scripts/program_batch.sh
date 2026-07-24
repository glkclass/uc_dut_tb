#!/bin/bash

# Func: Program batch of different size.
# Desc:
# 	Programming of full batch of 9 targets sometimes crashes due to hs_server internal issues.
# 	So we split full set of 9 targets into 2 or 3 separate batches.
# 	And use 2 or 3 separate runs switching off/on board power between them.
# Usage examples:
# 	0. ./program_batch.sh 0 - detect active jtags, print them and exit
# 	1. ./program_batch.sh 91 - program batch 91
# 	2. ./program_batch.sh 52 - program batch 52
# 	3. ./program_batch.sh 33 - program batch 33
# 	4. ./program_batch.sh 210299BC2C3C - program single jtag target 210299BC2C3C
# 	5. ./program_batch.sh 210299BC2C3C:210299BDCF29 - program two jtag targets 210299BC2C3C and 210299BDCF29

BATCH_91=210299BC2C3C:210299BDCF47:210299BDCF29:210299BBA718:210299BBE362:210299BDCF44:210299BDCF33:210299BBA560:210299BBACAF

BATCH_41=210299BC2C3C:210299BDCF47:210299BDCF29:210299BBA718
BATCH_52=210299BBE362:210299BDCF44:210299BDCF33:210299BBA560:210299BBACAF

BATCH_31=210299BC2C3C:210299BDCF47:210299BDCF29
BATCH_32=210299BBA718:210299BBE362:210299BDCF44
BATCH_33=210299BDCF33:210299BBA560:210299BBACAF


if [ "$1" == "0" ]; then
	echo "INFO | Run jtag target autodetect procedure"
elif [ "$1" == "91" ]; then
	export PROGRAM_JTAG_TARGET_ID=${BATCH_91}
elif [ "$1" == "41" ]; then
	export PROGRAM_JTAG_TARGET_ID=${BATCH_41}
elif [ "$1" == "52" ]; then
	export PROGRAM_JTAG_TARGET_ID=${BATCH_52}
elif [ "$1" == "31" ]; then
	export PROGRAM_JTAG_TARGET_ID=${BATCH_31}
elif [ "$1" == "32" ]; then
	export PROGRAM_JTAG_TARGET_ID=${BATCH_32}
elif [ "$1" == "33" ]; then
	export PROGRAM_JTAG_TARGET_ID=${BATCH_33}
else
	echo "INFO | Seems unknown option: $1, use it as jtag target id."
	export PROGRAM_JTAG_TARGET_ID=$1
fi

make program_n_flash
