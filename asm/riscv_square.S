/******************************************************************************
 * Project  ELE8304 : Circuits intégrés à très grande échelle
 *          Mini-RISCV
 ******************************************************************************
 * File     riscv_square.S
 * Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
 * Lab      GRM - Polytechnique Montreal
 * Date     <2019-08-15 Thu>
 ******************************************************************************
 * Brief    Programme de test pour le mini-riscv basé sur les carrés
 ******************************************************************************/
#define SUCCESS       0xEEEEEEEE
#define FAILURE       0xDDDDDDDD
#define MASK0         0xF0F0F0F0
#define MASK1         0x0F0F0F0F
#define MAX_SQUA_LOOP 19
#define MAX_SQUA_VAL  400

.global start

start:
    li    sp, 0
    beqz  sp, init

fail:
    li    a1, FAILURE
    jal   zero, end

pass:
    li    a1, SUCCESS
    jal   zero, end

end:
    la    sp, _STACK
    li    t0, MASK0
    li    t1, MASK1
    xor   a1, a1, t0
    and   a1, a1, t1
    sw    a1, 0(sp)
    li    s1, 0

final:
    beqz  s1, final

init:
    la    sp, _STACK
    la    gp, _HEAP
    addi  sp, sp, -4
    beqz  sp, fail
    beqz  gp, fail
    jal   ra, main
    li    t0, MAX_SQUA_VAL
    beq   a0, t0, pass
    jal   zero,  fail

main:
    sw    gp, 0(gp)
    li    t0, 1
    sw    t0, 4(gp)
    lw    t1, 4(gp)
    sll   t1, t1, t0
    sw    t1, 8(gp)
    lw    s0, 0(gp)
    lw    t1, 4(s0)
    lw    t0, 8(s0)
    srl   t0, t0, t1
    sltiu t2, t0, 1
    beqz  t2, square
    sub   t2, t2, t1
    jal   zero, endmain

square:
    li    t0, 0
    li    s0, MAX_SQUA_LOOP
    addi  t1, zero, 1
    sw    t1, 0(sp)

loop:
    sltu  t3, t0, s0
    beqz  t3, endmain
    addi  t0, t0, 1
    add   t1, t0, t0
    addi  t1, t1, 1
    lw    t2, 0(sp)
    add   t2, t1, t2
    sw    t2, -4(sp)
    srai  sp, sp,  2
    addi  sp, sp, -1
    slli  sp, sp,  2
    jal   zero, loop

endmain:
    addi  a0, t2, 0
    jalr  zero, ra, 0
