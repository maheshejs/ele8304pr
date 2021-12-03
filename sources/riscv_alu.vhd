
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
    signal s_less       : std_logic; 
    signal s_adder      : std_logic_vector(XLEN downto 0); 
    signal s_and        : std_logic_vector(XLEN-1 downto 0); 
    signal s_xor        : std_logic_vector(XLEN-1 downto 0); 
    signal s_or         : std_logic_vector(XLEN-1 downto 0); 
    signal s_sr_result  : std_logic_vector(XLEN-1 downto 0); 
begin

    X_ADDER : riscv_adder 
    generic map(
      N       => XLEN
    )
    port map (
      i_a     => i_src1,
      i_b     => i_src2,
      i_sign  => i_sign,
      i_sub   => i_arith,
      o_sum   => s_adder
    );

    X_LOGIC : riscv_logic
    port map (
      i_a     => i_src1,
      i_b     => i_src2,
      o_and   => s_and,
      o_xor   => s_xor,
      o_or    => s_or
    );

    s_less <= s_adder(XLEN-1) xor s_adder(XLEN) when i_sign = '1' else 
              not s_adder(XLEN) when i_arith = '1' else
              '0';

    s_sr_result <=  std_logic_vector(shift_right(signed(i_src1), to_integer(unsigned(i_shamt)))) when i_arith = '1' else 
                    std_logic_vector(shift_right(unsigned(i_src1), to_integer(unsigned(i_shamt))));

    -- Outputs
    with i_opcode select o_res <=
        s_adder(XLEN-1 downto 0) 
          when ALUOP_ADD,
        std_logic_vector(shift_left(unsigned(i_src1), to_integer(unsigned(i_shamt)))) 
          when ALUOP_SL,
        (0 => s_less, others => '0') 
          when ALUOP_SLT,
        s_xor 
          when ALUOP_XOR,
        s_sr_result
          when ALUOP_SR,
        s_or 
          when ALUOP_OR,
        s_and 
          when ALUOP_AND,
        (others => '0') 
          when others;

end architecture arch;
