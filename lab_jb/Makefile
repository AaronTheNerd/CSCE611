# Copyright (c) 2020 Jason Bakos, Philip Conrad, Charles Daniels

# use bash, since config.sh needs it
SHELL := bash

# crash if commands fail
.SHELLFLAGS := -eu -o pipefail -c

# remove incomplete targets
.DELETE_ON_ERROR:

# more helpful warnings
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# grab needed values from config.sh
VERILATOR=$(shell . ./config.sh && echo $$VERILATOR)
VERILATOR_INC=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$VERILATOR_INC')
VERILATOR_OBJ_DIR=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$VERILATOR_OBJ_DIR')
BUILD_DIR=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$BUILD_DIR')
CXXFLAGS=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$CXXFLAGS')
CXX=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$CXX')
RTL_DIR=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$RTL_DIR')
TOPLEVEL=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$TOPLEVEL')
SIM_ARCHIVE=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$SIM_ARCHIVE')
GENERATED_DIR=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$GENERATED_DIR')
PROBES_FILE=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$PROBES_FILE')
C_INCLUDES=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$C_INCLUDES')
VCD_TRACE_FILE=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$VCD_TRACE_FILE')
DEFAULT_PROGRAM_ROM=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$DEFAULT_PROGRAM_ROM')
SIM_CYCLES=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$SIM_CYCLES')
VSIM=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$VSIM')
VLOG=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$VLOG')
STUDENTID=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$STUDENTID')
SEMESTER=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$SEMESTER')
COURSE=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$COURSE')
PACK_DESTDIR=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$PACK_DESTDIR')
LAB=$(shell bash --noprofile --norc -c '. ./config.sh && echo $$LAB')


SUBMISSIONFILE=$(PACK_DESTDIR)/$(COURSE)_$(SEMESTER)_$(LAB)_$(STUDENTID).7z

BIN_DIR=$(BUILD_DIR)/bin
LIB_DIR=$(BUILD_DIR)/lib
OBJ_DIR=$(BUILD_DIR)/obj
SVFILES=$(shell ls -q $(RTL_DIR)/*.sv)

OBJECTS=$(OBJ_DIR)/verilated.o \
	$(OBJ_DIR)/verilated_vcd_c.o \
	$(OBJ_DIR)/cli.o \
	$(OBJ_DIR)/support.o \
	$(OBJ_DIR)/riscv-disas.o

# This is a bit silly -- normally you don't need to generate .a files like
# this unless you are shipping a static library. However, CGo seems to like
# these better, so I'm not going to question it too much.
ARCHIVES=$(SIM_ARCHIVE) \
	 $(LIB_DIR)/libsimulation.a \
	 $(LIB_DIR)/libsupport.a \
	 $(LIB_DIR)/libriscv-disas.a \
	 $(LIB_DIR)/libverilated.a \
	 $(LIB_DIR)/libverilated_vcd_c.a

BINARIES=$(BIN_DIR)/simcli $(BIN_DIR)/simgui

all: $(BINARIES)
.PHONY: all

build: $(BINARIES)
.PHONY: build

builddirs:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BIN_DIR)
	mkdir -p $(LIB_DIR)
	mkdir -p $(OBJ_DIR)
	mkdir -p $(GENERATED_DIR)
.PHONY: builddirs

trace: $(VCD_TRACE_FILE)
.PHONY: trace

waves: $(VCD_TRACE_FILE)
	gtkwave --wish ./trace.vcd
.PHONY: waves

gui: $(BIN_DIR)/simgui $(DEFAULT_PROGRAM_ROM)
	$(BIN_DIR)/simgui --load-rom "$(DEFAULT_PROGRAM_ROM)"
.PHONY: gui

$(DEFAULT_PROGRAM_ROM):
	@echo "WARNING: Whatever you're trying to do is going to fail, you need to create a program ROM in hex format and place it at '$(DEFAULT_PROGRAM_ROM)'"
	@exit 1


$(VCD_TRACE_FILE): $(BIN_DIR)/simcli $(DEFAULT_PROGRAM_ROM)
	bash -c "$(BIN_DIR)/simcli '$(DEFAULT_PROGRAM_ROM)' $(SIM_CYCLES)" 2>&1 simulation.log

$(OBJ_DIR)/%.o: $(VERILATOR_INC)/%.cpp builddirs
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: support/%.cpp $(SIM_ARCHIVE) $(GENERATED_DIR)/memories.h $(GENERATED_DIR)/probes.h $(GENERATED_DIR)/config.h builddirs
	$(CXX) -I"$(GENERATED_DIR)" $(CXXFLAGS) -c "$<" -o "$@"

$(OBJ_DIR)/riscv-disas.o: support/riscv-disas.c support/riscv-disas.h builddirs
	$(CXX) -I"$(GENERATED_DIR)" $(CXXFLAGS) -o "$@" -c "$<"


verilate: $(SIM_ARCHIVE)
.PHONY: verilate

$(SIM_ARCHIVE): $(VERILATOR_OBJ_DIR)/Vsimtop.cpp builddirs
	$(MAKE) -C "$(VERILATOR_OBJ_DIR)" -f Vsimtop.mk

$(VERILATOR_OBJ_DIR)/Vsimtop.cpp: $(SVFILES) $(GENERATED_DIR)/config.svh
	$(VERILATOR) --Mdir "$(VERILATOR_OBJ_DIR)" -I"$(RTL_DIR)" -I"$(GENERATED_DIR)" --trace -cc $(TOPLEVEL)

$(GENERATED_DIR)/%.svh: ./scripts/generate_%_svh.sh ./config.sh builddirs
	bash "$<" > "$@"

$(GENERATED_DIR)/%.h: ./scripts/generate_%.sh ./config.sh $(PROBES_FILE) $(SIM_ARCHIVE) builddirs
	bash "$<" > "$@"

$(BIN_DIR)/simcli: $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o "$@" $^ $(VERILATOR_OBJ_DIR)/*.o

$(BIN_DIR)/simgui: support/gui.go $(ARCHIVES) $(GENERATED_DIR)/memories.h $(GENERATED_DIR)/probes.h builddirs $(GENERATED_DIR)/config.h
	CGO_CFLAGS="-I$(GENERATED_DIR) $(C_INCLUDES)" CGO_LDFLAGS="-L$(LIB_DIR) -lsupport -lsimulation -lriscv-disas -lverilated -lverilated_vcd_c -lstdc++" go build -o "$@" "$<"

$(LIB_DIR)/libsimulation.a: $(SIM_ARCHIVE) builddirs
	cp "$<" "$@"

$(LIB_DIR)/lib%.a: $(OBJ_DIR)/%.o
	ar r "$@" $^

rars:
	java -jar ./support/rars.jar
.PHONY: rars

tests/test_frontend: tests/test_frontend.cpp $(SIM_ARCHIVE) $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) $(VERILATOR_OBJ_DIR)/*.o -o $@

test: tests/test_frontend
	e=0 ; for f in tests/test_*.py ; do echo "$$f" ;  if ! python3 "$$f" ; then e=$$(expr $$e + 1) ; fi ; done ; exit $$e
.PHONY: test

testbench:
	$(VLOG) -pedanticerrors -lint -source -stats=all $$(ls -1 -q $(RTL_DIR)/*.sv) $$(ls -q ./testbench/*.sv)
	set -e
	for tbtop in ./testbench/*testtop.sv ; do \
		modname="$$(basename "$$tbtop" .sv)" ; \
		echo "==== RUNNING TOP-LEVEL TESTBENCH: $$tbtop ==========================" ; \
		printf "run 10000\n" | $(VSIM) -pedanticerrors -c -sva -immedassert work.$$modname -do /dev/stdin ; \
	done
	set +e
.PHONY: testbench

pack: clean
	@if [ "$(STUDENTID)" = "CHANGEME" ] ; then \
		echo "Please edit ./config.sh and set the STUDENTID variable to your student ID" 1>&2 ; \
		exit 1 ; \
	fi
	@7z a "$(SUBMISSIONFILE)" ./
	@echo "Your project submission has been placed at $(SUBMISSIONFILE)"
.PHONY: pack

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(LIB_DIR) $(OBJ_DIR) $(VCD_TRACE_FILE) simulation.log ./work transcript
.PHONY: clean
