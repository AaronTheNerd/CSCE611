#!/usr/bin/env bash

set -e
set -u

# Copyright (c) 2020 Jason Bakos, Philip Conrad, Charles Daniels

# This script uses config.sh the output of ./findmem.sh to generate a header
# file so the C support library can find the appropriate memories in the
# Verilated source.
#
# Shorted out for the hex lab, since there are no memories

cd "$(dirname "$0")/.."

. ./config.sh

echo '#ifndef MEMORIES_H'
echo '#define MEMORIES_H'
printf '#define PROGRAM_MEMORY '
bash ./scripts/findmem.sh $PROGRAM_MEMORY
#printf '#define DATA_MEMORY '
#bash ./scripts/findmem.sh $DATA_MEMORY
printf '#define REGISTER_MEMORY '
bash ./scripts/findmem.sh $REGISTER_MEMORY
echo '#endif'
