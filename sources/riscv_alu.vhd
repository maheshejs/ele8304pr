
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
library work;
use work.riscv_pkg.all;

entity riscv_alu is
    port (
             i_arith  : in  std_logic;
             i_sign   : in  std_logic;
             i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
             i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
             i_src1   : in  std_logic_vector(XLEN-1 downto 0);
             i_src2   : in  std_logic_vector(XLEN-1 downto 0);
             o_res    : out std_logic_vector(XLEN-1 downto 0)
	);
end entity riscv_alu;

architecture arch of riscv_alu is
    signal arith  : std_logic;
    signal sign   : std_logic;
    signal opcode : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    signal shamt  : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    signal src1   : std_logic_vector(XLEN-1 downto 0);
    signal src2   : std_logic_vector(XLEN-1 downto 0);

    signal s_less    : std_logic; 
    signal s_adder   : std_logic_vector(XLEN downto 0); 
    signal s_and     : std_logic_vector(XLEN-1 downto 0); 
    signal s_xor     : std_logic_vector(XLEN-1 downto 0); 
    signal s_or      : std_logic_vector(XLEN-1 downto 0); 
begin
    arith  <= i_arith;
    sign   <= i_sign;
    opcode <= i_opcode;
    shamt  <= i_shamt;
    src1   <= i_src1;
    src2   <= i_src2;

    adder : riscv_adder GENERIC MAP(N => XLEN)
			PORT MAP (
                                     i_a    => src1,
                                     i_b    => src2,
                                     i_sign => sign,
                                     i_sub  => arith,
                                     o_sum  => s_adder
                                 );

    logic : riscv_logic PORT MAP (
                                     i_a   => src1,
                                     i_b   => src2,
                                     o_and => s_and,
                                     o_xor => s_xor,
                                     o_or  => s_or
                                 );

    s_less <= s_adder(XLEN-1) xor s_adder(XLEN) when sign = '1' else 
	       not s_adder(XLEN) when arith = '1' else
	       '0';

    with i_opcode select o_res <=
        s_adder(XLEN-1 downto 0) when ALUOP_ADD,
        (others => s_less) when ALUOP_SLT,
        std_logic_vector(shift_left(unsigned(src1), to_integer(unsigned(shamt)))) when ALUOP_SL,
        std_logic_vector(shift_right(signed(src1), to_integer(unsigned(shamt)))) when ALUOP_SR,
        s_xor when ALUOP_XOR,
        s_or when ALUOP_OR,
        s_and when others;

end architecture arch;
