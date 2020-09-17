#!/usr/bin/env bash

set -e
set -u

# Copyright (c) 2020 Jason Bakos, Philip Conrad, Charles Daniels

# This script will generate config.h based on the contents of ../config.sh.

cd "$(dirname "$0")/.."

. ./config.sh

printf '#ifndef GENERATED_CONFIG_H\n'
printf '#define GENERATED_CONFIG_H\n'
printf '#define PROGRAM_WORDS %d\n' "$PROGRAM_WORDS"
printf '#define PROGRAM_ADDR_BITS %d\n' "$PROGRAM_ADDR_BITS"
printf '#define DATA_WORDS %d\n' "$DATA_WORDS"
printf '#define DATA_ADDR_BITS %d\n' "$DATA_ADDR_BITS"
printf '#define RESET_VECTOR %d\n' "$RESET_VECTOR"
printf '#define VCD_TRACE_FILE "%s" \n' "$VCD_TRACE_FILE"
printf '#endif\n'
