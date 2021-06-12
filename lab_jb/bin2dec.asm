# Written by Aaron Barge
.text
csrrw x1 io0 x0 # Grab input from switches and store in x1
lui x2 104858 # Store 0.1 in x2
addi x2 x2 -1638
addi x3 x0 10 # Store 10 in x3
add x4 x0 x0 # Set Result to x4 and 0
li x8 0
# Conversion Block
loop:
beq x1 x0 exit
mulhu x5 x1 x2 # Store upper 32 bits of x1 * x2 in x5
mul x6 x1 x2 # Store lower 32 bits of x1 * x2 in x6
add x1 x5 x0 # Store upper 32 bits x1 * x2 in x1
mulhu x7 x6 x3 # Store upper 32 bits of x6 * 10 in x6
sll x7 x7 x8 # Shift bits to proper place
add x4 x4 x7 # Store in result
addi x8 x8 4
j loop
exit:
csrrw x4 io2 x4
