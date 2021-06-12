/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

#ifndef SUPPORT_H
#define SUPPORT_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "probes.h"
#include "riscv-disas.h"
#include "memories.h"
#include "config.h"

#ifdef __cplusplus

/* we don't include these under C, since it will confuse CGo */
#include "Vsimtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#else
#define Vsimtop void
#define VerilatedVcdC void
#endif

/* The "clock rate" of the simulation. This exists purely to give meaning to
 * stuff like delay_ms and delay_us. */
#define CLOCK_RATE 1000000UL

/* conversion rates */
#define US_PER_SECOND 1000000L
#define MS_PER_SECOND 1000L
#define US_PER_CYCLE (US_PER_SECOND / CLOCK_RATE)
#define MS_PER_CYCLE (MS_PER_SECOND / CLOCK_RATE)
#define CYCLES_PER_US ( CLOCK_RATE / US_PER_SECOND)
#define CYCLES_PER_MS ( CLOCK_RATE / MS_PER_SECOND)

typedef struct {
	Vsimtop* top;
	VerilatedVcdC* vcd;
	uint64_t cycleno;
} simulation_state;

typedef enum {
	IO_CLOCK_50,
	IO_SW,
	IO_KEY,
	IO_HEX0,
	IO_HEX1,
	IO_HEX2,
	IO_HEX3,
	IO_HEX4,
	IO_HEX5,
	IO_HEX6,
	IO_HEX7,
	IO_LEDG,
	IO_LEDR,
} simulation_io;

typedef enum {
	IO_CLOSED,
	IO_RDRW,
	IO_RO,
	IO_WO
} simulation_io_direction;

#ifdef __cplusplus
extern "C" {
#endif

void delay_cycles(simulation_state* s, uint64_t cycles);
void delay_us(simulation_state* s, uint64_t us);
void delay_ms(simulation_state* s, uint64_t ms);
void reset(simulation_state* s);
uint32_t read_io(simulation_state* s, simulation_io io);
void write_io(simulation_state* s, simulation_io io, uint32_t val);
simulation_state* initialize_simulation(int argc, char** argv);
uint32_t read_rom(simulation_state* s, uint32_t addr);
void write_rom(simulation_state* s, uint32_t addr, uint32_t val);
uint32_t read_reg(simulation_state* s, uint32_t addr);
void write_reg(simulation_state* s, uint32_t addr, uint32_t val);
char* read_probes(simulation_state* s);

#ifdef __cplusplus
}
#endif

/* key is RW so we can mask the button state */
#define io_direction(__io) ( \
	(__io == IO_CLOCK_50) ? IO_WO : \
	(__io == IO_SW)       ? IO_WO : \
	(__io == IO_KEY)      ? IO_RDRW : \
	(__io == IO_HEX0)     ? IO_RO : \
	(__io == IO_HEX1)     ? IO_RO : \
	(__io == IO_HEX2)     ? IO_RO : \
	(__io == IO_HEX3)     ? IO_RO : \
	(__io == IO_HEX4)     ? IO_RO : \
	(__io == IO_HEX5)     ? IO_RO : \
	(__io == IO_HEX6)     ? IO_RO : \
	(__io == IO_HEX7)     ? IO_RO : \
	(__io == IO_LEDG)     ? IO_RO : \
	(__io == IO_LEDR)     ? IO_RO : IO_CLOSED )

#define io_mask(__io) ( \
	(__io == IO_CLOCK_50) ? 0x00000001 : \
	(__io == IO_SW)       ? 0x0003ffff : \
	(__io == IO_KEY)      ? 0x0000000f : \
	(__io == IO_HEX0)     ? 0x0000007f : \
	(__io == IO_HEX1)     ? 0x0000007f : \
	(__io == IO_HEX2)     ? 0x0000007f : \
	(__io == IO_HEX3)     ? 0x0000007f : \
	(__io == IO_HEX4)     ? 0x0000007f : \
	(__io == IO_HEX5)     ? 0x0000007f : \
	(__io == IO_HEX6)     ? 0x0000007f : \
	(__io == IO_HEX7)     ? 0x0000007f : \
	(__io == IO_LEDG)     ? 0x000001ff : \
	(__io == IO_LEDR)     ? 0x0003ffff : 0x0 )

#define io2str(__io) ( \
	(__io == IO_CLOCK_50) ? "IO_CLOCK_50" : \
	(__io == IO_SW)       ? "IO_SW" : \
	(__io == IO_KEY)      ? "IO_KEY" : \
	(__io == IO_HEX0)     ? "IO_HEX0" : \
	(__io == IO_HEX1)     ? "IO_HEX1" : \
	(__io == IO_HEX2)     ? "IO_HEX2" : \
	(__io == IO_HEX3)     ? "IO_HEX3" : \
	(__io == IO_HEX4)     ? "IO_HEX4" : \
	(__io == IO_HEX5)     ? "IO_HEX5" : \
	(__io == IO_HEX6)     ? "IO_HEX6" : \
	(__io == IO_HEX7)     ? "IO_HEX7" : \
	(__io == IO_LEDG)     ? "IO_LEDG" : \
	(__io == IO_LEDR)     ? "IO_LEDR" : "ERROR UNKNOWN IO" )

#define dir2str(__dir) \
	(__dir == IO_CLOSED) ? "closed" : \
	(__dir == IO_RDRW)   ? "read/write" : \
	(__dir == IO_RO)     ? "read only" : \
	(__dir == IO_WO)     ? "write only" : "ERROR UNKNOWN DIRECTION"

#define whereat do { \
		fprintf(stderr, "%s:%d:%s()", __FILE__, __LINE__, __func__); \
	} while(0);

#define assert_valid_io(__io) do { \
	if (strcmp(io2str(__io), "ERROR UNKNOWN IO") == 0) { \
			fprintf(stderr, "ERROR: IO %i is unknown.\n", __io); \
			fprintf(stderr, "previous error was near: "); \
			whereat; \
			fprintf(stderr, "\n"); \
			exit(1); \
		}\
	} while(0)

#define assert_writeable(__io) do { \
		if ((io_direction(__io) != IO_RDRW) && (io_direction(__io) != IO_WO)) { \
			fprintf(stderr, "ERROR: IO '%s' is not writeable (direction is '%s')\n", \
					io2str(__io), dir2str(io_direction(__io))); \
			fprintf(stderr, "previous error was near: "); \
			whereat; \
			fprintf(stderr, "\n"); \
			exit(1); \
		} \
	} while(0)

#define assert_readable(__io) do { \
		if ((io_direction(__io) != IO_RDRW) && (io_direction(__io) != IO_RO)) { \
			fprintf(stderr, "ERROR: IO '%s' is not readable (direction is '%s')\n", \
					io2str(__io), dir2str(io_direction(__io))); \
			fprintf(stderr, "previous error was near: "); \
			whereat; \
			fprintf(stderr, "\n"); \
			exit(1); \
		} \
	} while(0)


#endif

#define print_disasm(_inst) do { \
		char _buf[128] = { 0 }; \
		disasm_inst(_buf, sizeof(_buf), rv32, 0, _inst); \
		printf("%s", _buf); \
	} while(0);
