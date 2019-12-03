/******************************************************************************
 * Project  ELE8304 : Circuits intégrés à très grande échelle
 ******************************************************************************
 * File     mips_basic.S
 * Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
 * Lab      GRM - Polytechnique Montreal
 * Date     <2019-12-02 Mon>
 ******************************************************************************
 * Brief    Programme de test simple pour le mini-mips
 ******************************************************************************/
#define BRANCH_SUCCESS  -1
#define BRANCH_FAILURE   1


/******************************************************************************
 * Début
 ******************************************************************************/
.global start
start:
    and $s1, $0, $0                     // r17 = 0

/******************************************************************************
 * Opérations arithmétiques et logiques sans dépendances de données
 ******************************************************************************/
arith:
    lui   $t0, 0xFFFF                   // r8  = 0xFFFF0000
    addi  $t1, $0,  0x0FFF              // r9  = 0x00000FFF
    ori   $t2, $0,  0xFFFF              // r10 = 0xFFFFFFFF
    xori  $t3, $0,  2                   // r11 = 0x00000002
    andi  $t4, $t1, 1                   // r12 = 0x00000001

    sll   $a0, $t1, 4                   // r4  = 0x0000FFF0
    srl   $a1, $t0, 4                   // r5  = 0x0FFFF000
    sra   $a2, $t0, 4                   // r6  = 0xFFFFF000

    sllv  $t5, $t0, $t3                 // r13 = 0xFFFC0000
    srlv  $t6, $t0, $t3                 // r14 = 0x3FFFC000
    srav  $t7, $t0, $t3                 // r15 = 0xFFFFC000

    xor   $a0, $a0, $a1                 // r4  = 0x0FFF0FF0
    and   $a1, $t1, $t3                 // r5  = 0x00000002
    or    $a2, $t0, $t3                 // r6  = 0xFFFF0002

    add   $k0, $t1, $t0                 // r26 = 0xFFFF0FFF
    sub   $k1, $t1, $t0                 // r27 = 0x00010FFF

    sltu  $v0, $t1, $t0                 // r2  = 0x00000001
    slt   $v1, $t0, $t1                 // r3  = 0x00000001
    sltiu $v0, $t7, 1                   // r2  = 0x00000000
    slti  $v1, $t3, 1                   // r3  = 0x00000000

    nop
    nop
    nop
    nop

/******************************************************************************
 * Load / Store + dépendance de donnée dans le RF
 ******************************************************************************/
mem:
    li  $sp, _STACK                     // r29 = 0x00000FFC
    li  $gp, _HEAP                      // r28 = 0x000007FC
    sw  $a0, -4($sp)                    // DMEM[3FE] = 0x0FFF0FF0
    lw  $t8, -4($sp)                    // r24 = 0x0FFF0FF0

    nop
    nop
    nop
    nop

/******************************************************************************
 * Branchements: r16 = BRANCH_SUCCESS si succès, BRANCH_FAILURE (ou 0) sinon
 ******************************************************************************/
branch:
    beq $a0, $t8, branch_ok
    li $s0, BRANCH_FAILURE
    j next

branch_ok:
    jal success
    j next

success:
    li $s0, BRANCH_SUCCESS
    jalr $0, $ra

next:
    nop
    nop
    nop
    nop

/******************************************************************************
 * Dépendances de données
 ******************************************************************************/
fwd:
    addi $sp, $sp, -8                 // r29 = 0x00000FF4
    sw   $sp, 0($sp)                  // DMEM[3FD] = 0x00000FF4
    lw   $v0, 0($sp)                  // r2  = 0x00000FF4
    lw   $v1, 0($v0)                  // r3  = 0x00000FF4

    nop
    nop
    nop
    nop

/******************************************************************************
 * Fin
 ******************************************************************************/
end:
    beqz $s1, end
