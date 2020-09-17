#!/usr/bin/env bash

# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels

# Attempts to find what Verilator has called a memory.

set -e
set -u

if [ $# -ne 1 ] ; then
	echo "./findmem.sh MEMORY_NAME" 1>&2
	exit 1
fi

MEMNAME="$(echo "$1" |  sed 's/[.]/__DOT__/g')"

cd "$(dirname "$0")/.."
. ./config.sh

if [ ! -f "$SIM_ARCHIVE" ] ; then
	echo "No '$SIM_ARCHIVE' file found, did you run Verilator yet?" 1>&2
	exit 1
fi

RESULTS="$(cat "$VERILATOR_OBJ_DIR"/*.h | egrep -o '[a-zA-Z_0-9]*'"$MEMNAME")"

if [ "$(echo "$RESULTS" | wc -l)" -gt 1 ] ; then
	echo -e "Multiple candidates found, be more specific\n$RESULTS" 1>&2
	exit 1
fi

if [ "$(echo "$RESULTS" | wc -l)" -lt 1 ] ; then
	echo "No results found" 1>&2
	exit 1
fi

echo $RESULTS
exit 0
