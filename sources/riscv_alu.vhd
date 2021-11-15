
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_alu.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity riscv_alu is
    port (
             i_arith  : in  std_logic;
             i_sign   : in  std_logic;
             i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
             i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
             i_src1   : in  std_logic_vector(XLEN-1 downto 0);
             i_src2   : in  std_logic_vector(XLEN-1 downto 0);
             o_res    : out std_logic_vector(XLEN-1 downto 0));
end entity riscv_alu;

architecture arch of riscv_alu is
    signal arith  : std_logic;
    signal sign   : std_logic;
    signal opcode : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal shamt  : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal src1   : std_logic_vector(XLEN-1 downto 0);
    signal src2   : std_logic_vector(XLEN-1 downto 0);

    signal o_shifter : std_logic_vector(XLEN-1 downto 0); 
    signal o_less    : std_logic_vector(XLEN-1 downto 0); 
    signal o_adder   : std_logic_vector(XLEN-1 downto 0); 
    signal o_and     : std_logic_vector(XLEN-1 downto 0); 
    signal o_xor     : std_logic_vector(XLEN-1 downto 0); 
    signal o_or      : std_logic_vector(XLEN-1 downto 0); 
begin
    arith  <= i_arith;
    sign   <= i_sign;
    opcode <= i_opcode;
    shamt  <= i_shamt;
    src1   <= i_src1;
    src2   <= i_src2;

    adder : riscv_adder PORT MAP (
                                     i_a    => src1,
                                     i_b    => src2,
                                     i_sign => sign,
                                     i_sub  => arith,
                                     o_sum  => adder_out
                                 );

    shifter : riscv_shifter PORT MAP (
                                         i_src    => src1,
                                         i_shamt  => shamt,
                                         i_opcode => opcode,
                                         i_arith  => arith,
                                         o_result => o_shifter 
                                     );

    logic : riscv_logic PORT MAP (
                                     i_a   => src1,
                                     i_b   => src2,
                                     o_and => o_and,
                                     o_xor => o_xor,
                                     o_or  => o_or,
                                 );

    o_less <= o_adder(XLEN-1);

    case opcode is
        when ALUOP_ADD =>
            o_res <= o_adder;
        when ALUOP_SLT =>
            o_res <= o_less;
        when ALUOP_SL  =>
            o_res <= o_shifter;
        when ALUOP_SR  =>
            o_res <= o_shifter;
        when ALUOP_XOR =>
            o_res <= o_xor;
        when ALUOP_OR  =>
            o_res <= o_or;
        when others =>
            o_res <= o_and;
    end case;

end architecture arch;
