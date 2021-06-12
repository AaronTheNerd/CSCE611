# Written by Aaron Barge
csrrw x1 io0 x1
slli x1 x1 14
li x2 256
slli x2 x2 14
li x3 128
slli x3 x3 14
sqrtloop:
mul x4 x2 x2
mulhu x5 x2 x2
srli x6 x4 14
slli x7 x5 18
or x4 x6 x7
beq x2 x4 b2d
if:
bgeu x4 x1 else
add x2 x2 x3
j endif
else:
sub x2 x2 x3
endif:
srli x3 x3 1
beqz x3 b2d
j sqrtloop

b2d:
li x3 100000
mulhu x4 x2 x3
slli x4 x4 18
mul x5 x2 x3
srli x5 x5 14
or x1 x4 x5

li x2 429496730 # load 0.1 into x2
li x3 10	# Store 10 in x3
li x4 0		# Set Result to x4 and 0
li x8 0
# Conversion Block
b2dloop:
beq x1 x0 exit
mulhu x5 x1 x2	# Store upper 32 bits of x1 * x2 in x5
mul x6 x1 x2	# Store lower 32 bits of x1 * x2 in x6
add x1 x5 x0	# Store upper 32 bits x1 * x2 in x1
mulhu x7 x6 x3	# Store upper 32 bits of x6 * 10 in x6
sll x7 x7 x8	# Shift bits to proper place
add x4 x4 x7	# Store in result
addi x8 x8 4
j b2dloop
exit:
csrrw x4 io2 x4
