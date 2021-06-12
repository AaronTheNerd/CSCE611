# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels

# this is a quick and dirty mess

import subprocess
import os
dir_path = os.path.dirname(os.path.realpath(__file__))

def assemble(program):
    # write out the program to a file, since I don't feel like dealing with
    # subprocess pipes
    with open(dir_path + "/.temp_prog.asm", "w") as f:
        f.write(program)

    # run the assembler script...
    res = subprocess.run(["sh", "-c", "./assemble.sh ../support/rars.jar ./.temp_prog.asm ./.temp_rom.dat 2>&1 ; exit $?"], cwd=dir_path, capture_output=True)

    # note that the assembler exits 0 if assembly fails
    if (res.returncode != 0) or (not os.path.exists(dir_path + "/.temp_rom.dat")):
        print("Failed to assemble program!\n\nProgram was:\n")
        print(program)
        print("\nerror was: ")
        print(res.stdout.decode("utf8"))
        exit(1)

def run_test(program, expectregs):
    # make sure there is no junk left over fro mthe last test
    res = subprocess.run(["rm", "-f", "./temp_rom.dat", "./.temp_prog.asm"], cwd=dir_path)

    assemble(program)

    # run the test fronted, we assume that somebody else already make-ed it for
    # us
    res = subprocess.run(["sh", "-c", "./test_frontend ./.temp_rom.dat 1024 2>&1"], cwd=dir_path, capture_output=True)
    if res.returncode != 0:
        print("Failed to run program!")
        print(program)
        print("\nerror was: ")
        print(res.stdout.decode("utf8"))
        exit(1)

    # parse the reg values that it output
    regs = {}
    for i in range(32):
        regs[i] = "UNKNOWN"
    for line in res.stdout.decode("utf8").split("\n"):
        try:
            reg = int(line.split()[0])
            val = int(line.split()[1], 16)
            regs[reg] = val
        except Exception as e:
            continue

    # compare against the expected values
    failed = False
    for key in expectregs:
        if expectregs[key] != regs[key]:
            print("Register {} should have been {}, but was {}".format(key, expectregs[key], regs[key]))
            failed = True

    # tidy up
    res = subprocess.run(["rm", "-f", "./temp_rom.dat", "./.temp_prog.asm"], cwd=dir_path)

    if failed:
        exit(1)

if __name__ == "__main__":
    exit(0)
