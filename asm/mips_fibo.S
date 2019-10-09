/******************************************************************************
 * Project  ELE8304 : Circuits intégrés à très grande échelle
 ******************************************************************************
 * File     mips_fibo.S
 * Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
 * Lab      GRM - Polytechnique Montreal
 * Date     <2019-08-15 Thu>
 ******************************************************************************
 * Brief    Programme de test pour le mini-mips basé sur Fibonacci
 ******************************************************************************/

#define SUCCESS       0xEEEEEEEE
#define FAILURE       0xDDDDDDDD
#define MASK0         0xF0F0F0F0
#define MASK1         0x0F0F0F0F
#define MAX_FIBO_LOOP 20
#define MAX_FIBO_VAL  6765

.global start

start:
    li    $sp, 0
    beqz  $sp, init

fail:
    li    $a1, FAILURE
    j     end

pass:
    li    $a1, SUCCESS
    j     end

end:
    li    $sp, _STACK
    li    $t0, MASK0
    li    $t1, MASK1
    xor   $a1, $a1, $t0
    and   $a1, $a1, $t1
    sw    $a1, 0($sp)
    li    $s1, 0

final:
    beqz  $s1, final

init:
    li    $sp, _STACK
    li    $gp, _HEAP
    addi  $sp, $sp, -4
    beqz  $sp, fail
    beqz  $gp, fail
    jal   main
    li    $t0, MAX_FIBO_VAL
    beq   $v0, $t0, pass
    j     fail

main:
    sw    $gp, 0($gp)
    li    $t0, 1
    sw    $t0, 4($gp)
    lw    $t1, 4($gp)
    sllv  $t1, $t1, $t0
    sw    $t1, 8($gp)
    lw    $s0, 0($gp)
    lw    $t1, 4($s0)
    lw    $t0, 8($s0)
    srlv  $t0, $t0, $t1
    sltiu $t2, $t0, 1
    beqz  $t2, fibo
    sub   $t2, $t2, $t1
    j     endmain

fibo:
    li    $a0, 1
    li    $s0, MAX_FIBO_LOOP
    li    $t0, 0
    li    $t1, 1
    sw    $t0, 0($sp)
    sw    $t1, -4($sp)

loop:
    sltu  $t3, $a0, $s0
    beqz  $t3, endmain
    addi  $a0, $a0, 1
    lw    $t0, 0($sp)
    lw    $t1, -4($sp)
    add   $t2, $t0, $t1
    sw    $t2, -8($sp)
    sra   $sp, $sp,  2
    addi  $sp, $sp, -1
    sll   $sp, $sp,  2
    j     loop

endmain:
    addi  $v0, $t2, 0
    jalr  $0, $ra
