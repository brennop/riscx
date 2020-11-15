addi a0 zero 10
addi a1 zero 1
addi t1 zero 4
PROC: sw a0 0(a3)
add a3 a3 t1
sub a0 a0 a1
slt a2 a0 zero
beq a2 zero PROC
and a3 a3 zero
or a3 a3 t1
add a3 a3 a3
lw s2 0(a3)
END: jal END
