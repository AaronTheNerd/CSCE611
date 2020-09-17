#!/usr/bin/env bash

# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels


set -e
set -u

if [ $# -ne 2 ] ; then
	echo "USAGE: ./pack.sh HOWMANY WHAT < INPUT > OUTPUT" 1>&2
	echo "Appends HOWMANY many lines containing WHAT to the input." 1>&2
	exit 1
fi

HOWMANY="$1"
WHAT="$2"

i=0
while read -r line ; do
	echo "$line"
	i=$(expr $i + 1)
done <<< "$(cat /dev/stdin)"

while true ; do
	if [ $i -ge "$HOWMANY" ] ; then
		break
	fi
	i=$(expr $i + 1)
	echo "$WHAT"
done
