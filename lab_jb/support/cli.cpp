/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

#include "support.h"
#include "config.h"

int main(int argc, char** argv) {
	if (argc != 3) {
		printf("usage: ./simcli ROM_FILE NCYCLES\n");
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

	while (romaddr < PROGRAM_WORDS) {
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
