# Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels
# Given test program from lab 2
import test_util

test_util.run_test("""
addi x1, x0, 12
addi x2, x0, 17
add x3, x1, x2
sub x3, x3, x1
slli x3, x3, 27
mul x4, x2, x3
mulh x4, x2, x3
mulhu x5, x2, x3
slt x6, x4, x1
sltu x6, x4, x1
and x7, x4, x1
or x8, x4, x1
xor x9, x1, x2
andi x10, x3, -2048
ori x11, x2, -2048
xori x12, x2, 14
sll x13, x2, x1
srl x14,x3,x2
sra x15, x3, x2
slli x16 ,x1, 1
srli x17, x2, 1
srai x18, x3, 1
lui x19, 0xDBEEF
csrrw x20, 0xf02, x3
csrrw x21, 0xf00, x3
""", {1: 12, 2:17, 3:0x88000000, 4:0xFFFFFFF8, 5:9, 6:0, 7:8, 8:0xFFFFFFFC, 9:29, 10:0x88000000, 11:0xFFFFF811, 12:31, 13:69632, 14:17408, 15:0xFFFFC400, 16:24, 17:8, 18:0xC4000000, 19:0xDBEEF000})