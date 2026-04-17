#!/bin/sh
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC

HANDLER="/usr/sbin/debug_cli_script.sh"

while read line; do
	echo "$line" > /dev/console

	if [ -x "$HANDLER" ]; then
		"$HANDLER" snapshot cloud KFENCE > /dev/console
	fi

done
