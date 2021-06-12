/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* This file includes supporting routines for your project. You should not
 * change anything in here.
 */

#include "support.h"

/* Run the simulation the given number of cycles */
void delay_cycles(simulation_state* s, uint64_t cycles)  {

	while (cycles > 0) {
		s->top->eval();
		if (s->vcd) { s->vcd->dump(s->cycleno * 10 - 2); }
		s->top->CLOCK_50 = 1;
		s->top->eval();
		if (s->vcd) { s->vcd->dump(s->cycleno * 10); }
		s->top->CLOCK_50 = 0;
		s->top->eval();
		if (s->vcd) {
			s->vcd->dump(s->cycleno * 10 + 5);
			s->vcd->flush();
		}
		cycles --;
		s->cycleno++;
	}
}

void delay_us(simulation_state* s, uint64_t us) {
	delay_cycles(s, CYCLES_PER_US * us);
}

void delay_ms(simulation_state* s, uint64_t ms) {
	delay_cycles(s, CYCLES_PER_MS * ms);
}

/* Perform a reset. This will run the simulation for 3 cycles. */
void reset(simulation_state* s) {
	s->top->KEY |= 1 << 3;
	for (int reg = 0 ; reg < 32 ; reg++) {
		write_reg(s, reg, 0);
	}
	delay_cycles(s, 5);
	s->top->KEY &= ~(1 << 3);
}

/* Read the specified I/O */
uint32_t read_io(simulation_state* s, simulation_io io) {
	assert_valid_io(io);
	assert_readable(io);

	uint32_t res = 0;

	if (io == IO_CLOCK_50) {
		res = s->top->CLOCK_50;
	} else if (io == IO_SW)       {
		res = s->top->SW;
	} else if (io == IO_KEY)      {
		res = s->top->KEY;
	} else if (io == IO_HEX0)     {
		res = s->top->HEX0;
	} else if (io == IO_HEX1)     {
		res = s->top->HEX1;
	} else if (io == IO_HEX2)     {
		res = s->top->HEX2;
	} else if (io == IO_HEX3)     {
		res = s->top->HEX3;
	} else if (io == IO_HEX4)     {
		res = s->top->HEX4;
	} else if (io == IO_HEX5)     {
		res = s->top->HEX5;
	} else if (io == IO_HEX6)     {
		res = s->top->HEX6;
	} else if (io == IO_HEX7)     {
		res = s->top->HEX7;
	} else if (io == IO_LEDG)     {
		res = s->top->LEDG;
	} else if (io == IO_LEDR)     {
		res = s->top->LEDR;
	}

	return res & io_mask(io);
}

/* Write to the specified I/O */
void write_io(simulation_state* s, simulation_io io, uint32_t val) {
	assert_valid_io(io);
	assert_writeable(io);

	val = val & io_mask(io);

	if (io == IO_CLOCK_50) {
		s->top->CLOCK_50 = val;
	} else if (io == IO_SW)       {
		s->top->SW = val;
	} else if (io == IO_KEY)      {
		s->top->KEY = val;
	} else if (io == IO_HEX0)     {
		s->top->HEX0 = val;
	} else if (io == IO_HEX1)     {
		s->top->HEX1 = val;
	} else if (io == IO_HEX2)     {
		s->top->HEX2 = val;
	} else if (io == IO_HEX3)     {
		s->top->HEX3 = val;
	} else if (io == IO_HEX4)     {
		s->top->HEX4 = val;
	} else if (io == IO_HEX5)     {
		s->top->HEX5 = val;
	} else if (io == IO_HEX6)     {
		s->top->HEX6 = val;
	} else if (io == IO_HEX7)     {
		s->top->HEX7 = val;
	} else if (io == IO_LEDG)     {
		s->top->LEDG = val;
	} else if (io == IO_LEDR)     {
		s->top->LEDR = val;
	}

}

simulation_state* initialize_simulation(int argc, char** argv) {
        Verilated::commandArgs(argc, argv);
	simulation_state* s = (simulation_state*) malloc(sizeof(simulation_state));
	s->top = new Vsimtop;
	Verilated::traceEverOn(true);
	s->vcd = new VerilatedVcdC;
	s->top->trace(s->vcd, 99);
	s->vcd->open(VCD_TRACE_FILE);
	s->cycleno = 1;

	reset(s);
	return s;
}

uint32_t read_rom(simulation_state* s, uint32_t addr) {
	return s->top->PROGRAM_MEMORY[addr];
}

void write_rom(simulation_state* s, uint32_t addr, uint32_t val) {
	s->top->PROGRAM_MEMORY[addr] = val;
}

uint32_t read_reg(simulation_state* s, uint32_t addr) {
	return s->top->REGISTER_MEMORY[addr];
}

void write_reg(simulation_state* s, uint32_t addr, uint32_t val) {
	s->top->REGISTER_MEMORY[addr] = val;
}


char* read_probes(simulation_state* s) {
	char* res;
	_internal_read_probes(s, &res);
	return res;
}
