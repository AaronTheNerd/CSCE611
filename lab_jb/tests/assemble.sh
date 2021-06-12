#!/usr/bin/env bash

# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels

set -e
set -u

if [ $# -ne 3 ] ; then
	echo "USAGE: ./assemble.sh RARS INPUT OUTPUT" 1>&2
	echo "Uses the jar file located at RARS to assemble the INPUT as ASCII hex and places it at OUTPUT" 1>&2
	exit 1
fi

RARS="$1"
INPUT="$2"
OUTPUT="$3"

if java -jar "$RARS" a dump .text HexText "$OUTPUT" "$INPUT" 2>&1 | grep -qi "error" ; then
	java -jar "$RARS" a dump .text HexText "$OUTPUT" "$INPUT" 2>&1
	exit 1
fi
