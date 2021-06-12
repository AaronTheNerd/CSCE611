/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* This program will initialize the simulation, overwrite the program ROM with
 * one that is specified, then run the simulation for the specified number of
 * cycles. It will produce on standard out the state of the register file.
 *
 * This program is not very good. It will definitely break if you give it bad
 * inputs. It probably should not be used for anything outside of the automated
 * test suite.
 * */

#include "../support.h"

int main(int argc, char** argv) {
	if (argc != 3) {
		printf("usage: ./test_frontent ROM_FILE NCYCLES\n");
		return 1;
	}

	simulation_state* s = initialize_simulation(argc, argv);

	FILE* romfd = fopen(argv[1], "r");
	int romaddr = 0;

	while (true) {
		uint32_t read = 0;
		int n = fscanf(romfd, "%x[\n]", &read);
		if (n == 1) {
			s->top->PROGRAM_MEMORY[romaddr] = read;
			romaddr++;
		} else {
			break;
		}
	}

	while (romaddr < 4096) {
			s->top->PROGRAM_MEMORY[romaddr] = 0;
			romaddr++;
	}

	reset(s);

	delay_cycles(s, atoi(argv[2]));

	for (int i = 0 ; i < 32 ; i++) {
		uint32_t regval = s->top->REGISTER_MEMORY[i];
		printf("%2i\t%08x\n", i, regval);
	}

	return 0;

}
