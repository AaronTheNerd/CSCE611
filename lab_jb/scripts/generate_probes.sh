#!/usr/bin/env bash

set -e
set -u

# Copyright (c) 2020 Jason Bakos, Philip Conrad, Charles Daniels

# This script will generate a header file with macros to help the simulation
# support library implement the user-defined probes.

cd "$(dirname "$0")/.."

. ./config.sh


printf '#ifndef PROBES_H\n'
printf '#define PROBES_H\n'
printf '#define _internal_read_probes(_simstate, _deststr) do { \\'
printf '\n'

# generate buffers for disassembly-formatted probes
while read -r line ; do
	fmt="$(echo "$line" | cut -f1)"
	sig="$(echo "$line" | cut -f2)"
	if [ "$fmt" = "inst" ] ; then
		printf 'char _%s_buf[128] = { 0 };\' "$sig"
		printf '\n'
		printf 'disasm_inst(_%s_buf, sizeof(_%s_buf), rv32, 0, _simstate->top->%s);\' "$sig" "$sig" "$sig"
		printf '\n'
	fi ; done < "$PROBES_FILE"

# generate the asprintf
printf 'asprintf(_deststr, "'

# first generate format strings for each instruction and it's value
while read -r line ; do fmt="$(echo "$line" | awk '{print($1)}')" ; sig="$(echo "$line" | cut -f2)"
		if [ "$fmt" = "hex" ] ; then  printf '%%20s:    0x%%08x\\n' ; fi
		if [ "$fmt" = "inst" ] ; then printf '%%20s:    %%s\\n' ; fi
		if [ "$fmt" = "int" ] ; then printf '%%20s:    %%-8d\\n' ; fi
	done < "$PROBES_FILE"
printf '"'

# now generate the values that need to get plugged into the format string
while read -r line ; do fmt="$(echo "$line" | awk '{print($1)}')" ; sig="$(echo "$line" | cut -f2)"
	printf ', "%s", '  "$(echo $sig | sed 's/simtop__DOT__//g' | sed 's/__DOT__/./g')"
	if [ "$fmt" = "hex" ] ; then printf '_simstate->top->%s' "$sig"; fi
	if [ "$fmt" = "inst" ] ; then  printf '_%s_buf' "$sig" ; fi
	if [ "$fmt" = "int" ] ; then printf '_simstate->top->%s' "$sig" ; fi
	done < "$PROBES_FILE"
printf '); \'
printf '\n'
printf '} while(0);\n'
printf '#endif'
