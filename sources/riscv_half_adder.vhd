-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_half_adder.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity riscv_half_adder is
  port (
    i_a     : in  std_logic;
    i_b     : in  std_logic;
    o_carry : out std_logic;
    o_sum   : out std_logic
  );
end entity riscv_half_adder;

architecture arch of riscv_half_adder is
begin
  o_sum   <= i_a xor i_b;
  o_carry <= i_a and i_b;
end architecture arch;

