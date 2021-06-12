# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels
# Given test program from lab 2
import test_util

test_util.run_test("""
li x1 1
li x2 -1
if1:
    beq x1 x1 else1
    li x3 -3
    j endif1
else1:
    li x3 3
endif1:
if2:
    beq x1 x2 else2
    li x4 4
    j endif2
else2:
    li x4 -4
endif2:
if3:
    bge x1 x2 else3
    li x5 -5
    j endif3
else3:
    li x5 5
endif3:
if4:
    bge x2 x1 else4
    li x6 6
    j endif4
else4:
    li x6 -6
endif4:
if5:
    bgeu x1 x2 else5
    li x7 7
    j endif5
else5:
    li x7 -7
endif5:
if6:
    bgeu x2 x1 else6
    li x8 -8
    j endif6
else6:
    li x8 8
endif6:
if7:
    blt x1 x2 else7
    li x9 9
    j endif7
else7:
    li x9 -9
endif7:
if8:
    blt x2 x1 else8
    li x10 -10
    j endif8
else8:
    li x10 10
endif8:
if9:
    bltu x1 x2 else9
    li x11 -11
    j endif9
else9:
    li x11 11
endif9:
if10:
    bltu x2 x1 else10
    li x12 12
    j endif10
else10:
    li x12 -12
endif10:
if11:
    bne x1 x1 else11
    li x13 13
    j endif11
else11:
    li x13 -13
endif11:
if12:
    bne x1 x2 else12
    li x14 -14
    j endif12
else12:
    li x14 14
endif12:
""", {1: 1, 2: 0xFFFFFFFF, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, 10: 10, 11: 11, 12: 12, 13: 13, 14: 14})