# Copyright (c) 2020 Jason Bakos, Philip Conrad, Charles Daniels

# This file is used to configure information about your project. It gets
# sourced by other scripts to abstract out information needed in multiple
# places.


# Make sure this is sourced using Bash, some things may not work in
# other shells (namely BASH_SOURCE)
if [ -z "$BASH_VERSION" ] ; then
	echo "WARNING: you really need to use bash for this, expect things to break (HINT: looks like your shell is $SHELL)" 2>&1
fi

#### VALUES YOU NEED TO CHANGE ################################################

# You should update the values in this section according to their comments to
# be appropriate for your project.

# The "program memory" should be whatever you named the SystemVerilog array
# where you assembled program gets loaded. You can use any sub-string of the
# fully qualified name of your array's name, starting on the right. For
# example, if your program memory was 'simtop.cpu0.program_rom', you could just
# specify 'program_rom', unless you had more than one array named
# 'program_rom'.
#
# You need to set this or the simulator will not know where to load data into
# your processor.
PROGRAM_MEMORY="program_rom"

# NOTE: we aren't using the data memory in Fall 2020, you can just ignore this
# one.
#
# This works similarly to the PROGRAM_MEMORY variable, but for your data
# memory. The simulator needs to know this so it can properly initialize
# the data memory on reset.
DATA_MEMORY="data_mem"

# Similarly to PROGRAM_MEMORY, but specifies the array which stores your
# register file. This is needed so the simulator can show you the contents of
# your register file.
REGISTER_MEMORY="regfile0.mem"

# This should be your USC network ID. If your university email address is
# jsmith@email.sc.edu, you should set this to "jsmith".
STUDENTID="CHANGEME"

#### VALUES YOU PROBABLY DONT NEED TO CHANGE ##################################

# These configuration values might need changed if you are running on an
# environment other than the one prescribed for this course. You probably don't
# need to change these.

# Verilator executable
VERILATOR=verilator

# location where Verilator is installed, something like /usr/share/verilator
VERILATOR_ROOT="$(bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')"

# include path for verilator libraries
VERILATOR_INC="$VERILATOR_ROOT/include"

# absolute path to the root of the project
PROJECT_ROOT="$(bash -c 'cd "$(dirname "'"${BASH_SOURCE[0]}"'")" ; pwd')"
if [ ! -e "$PROJECT_ROOT/config.sh" ] ; then
	echo "WARNING: PROJECT_ROOT '$PROJECT_ROOT' has no config.sh, this means it was probably detected wrong, expect things to break" 2>&1
fi

# where build artifacts should be placed
BUILD_DIR="$PROJECT_ROOT/build"

# where Verilator's build artifacts should be placed
VERILATOR_OBJ_DIR="$BUILD_DIR/verilator_obj"

# where Verilog files are stored
RTL_DIR="$PROJECT_ROOT/rtl"

# Verilog file with the top-level module in it
TOPLEVEL="$RTL_DIR/simtop.sv"

# where generated code should live -- several header files get generated as
# part of the build
GENERATED_DIR="$BUILD_DIR/generated"

# full list of C includes
C_INCLUDES="-I$VERILATOR_INC -I$VERILATOR_OBJ_DIR"

CFLAGS="-Wall -Wextra $C_INCLUDES"
CXXFLAGS="--std=c++11 $CFLAGS"
CXX="g++"

# where Verilator will end up dropping the compiled archive file
SIM_ARCHIVE="$VERILATOR_OBJ_DIR/Vsimtop__ALL.a"

PROBES_FILE="$PROJECT_ROOT/probes.list"

# where the Verilator simulation should save it'st raec file
VCD_TRACE_FILE="$PROJECT_ROOT/trace.vcd"

# default program ROM used with `make gui`, `make waves`, and `make trace`
DEFAULT_PROGRAM_ROM="$PROJECT_ROOT/program.rom"

# number of cycles to simulate when running non-interactively
SIM_CYCLES=8192

MODELSIM_PATH="/opt/intel/quartus/20.1/modelsim_ase"
VSIM="$MODELSIM_PATH/bin/vsim"
VLOG="$MODELSIM_PATH/bin/vlog"

# Needs to be updated to the current semester before passing out project
# skeleton.
SEMESTER="Fall2020"

COURSE="CSCE611"

# Where the packed submission files should be placed
PACK_DESTDIR="$(xdg-user-dir DESKTOP)"

# Needs to be updated for each lab before passing our project skeleton
LAB="hex"

#### VALUES YOU SHOULD NOT CHANGE #############################################

# Don't change anything below this line. Changing these constants may prevent
# the simulation from compiling or running successfully.

# Number of words of program memory that should be used.
PROGRAM_WORDS=4096

# Number of bits needed for the program memory address.
PROGRAM_ADDR_BITS=12

# Number of words of data memory memory that should be used.
DATA_WORDS=4096

# Number of bits needed for the data memory address.
DATA_ADDR_BITS=12

# Address where the CPU should jump when reset
RESET_VECTOR=0
