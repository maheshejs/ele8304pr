/*****************************************************************************
 * Project  ELE8304 : Circuits intégrés à très grande échelle
 *****************************************************************************
 * File     mips.ld
 * Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
 * Lab      GRM - Polytechnique Montreal
 * Date     <2019-08-21 Wed>
 *****************************************************************************
 * Brief    Linker script pour le mini-mips
 *****************************************************************************/

OUTPUT_ARCH( "mips" )

MEMORY
{
    IMEM  : ORIGIN = 0,  LENGTH = 2K
    DMEM  : ORIGIN = 2K, LENGTH = 2K
}

   _HEAP  = ORIGIN(DMEM) - 4;
   _STACK = ORIGIN(DMEM) + LENGTH(DMEM) - 4;

ENTRY(start)

SECTIONS
{
    . = ORIGIN(IMEM);
    .text ALIGN(4):
    {
        *(.text .text*)
    } > IMEM

    . = ORIGIN(DMEM);
    .data ALIGN(4):
    {
        *(.data .data*)
    } > DMEM
}
