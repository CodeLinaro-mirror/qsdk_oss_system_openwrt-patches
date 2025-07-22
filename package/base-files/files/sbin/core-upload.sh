#!/bin/sh
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC
#

# Arguments from core_patternrguments from core_pattern
EXE_NAME=$1
PID=$2
USER_ID=$3
GROUP_ID=$4
SIGNAL=$5
TIME=$6
HOSTNAME=$7
PPID=$8

CORE_FILE="/tmp/${EXE_NAME}.${PID}.${TIME}.core"
LOG_FILE="/tmp/core-upload.log"
TFTP_SERVER="192.168.1.100"
MAX_RETRIES=3
RETRY_DELAY=5

# Save core dump to file
cat > "$CORE_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Core dump saved to $CORE_FILE" >> "$LOG_FILE"

# Upload with retry logic
attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Attempt $attempt: Uploading $CORE_FILE to $TFTP_SERVER" >> "$LOG_FILE"
    tftp -p -l "$CORE_FILE" -r "$(basename $CORE_FILE)" "$TFTP_SERVER" && {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Upload successful" >> "$LOG_FILE"
        rm -f "$CORE_FILE"
        exit 0
    }
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Upload failed" >> "$LOG_FILE"
    attempt=$((attempt + 1))
    sleep $RETRY_DELAY
done
echo "$(date '+%Y-%m-%d %H:%M:%S') - All upload attempts failed. Core file retained at $CORE_FILE" >> "$LOG_FILE"
exit 1

