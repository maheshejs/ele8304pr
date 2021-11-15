

-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_logic.vhd
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
use work.riscv_pkg.all;

entity riscv_logic is
    port (
             i_a     : in  std_logic_vector(XLEN-1 downto 0);
             i_b     : in  std_logic_vector(XLEN-1 downto 0);
             o_and   : out std_logic_vector(XLEN-1 downto 0);
             o_xor   : out std_logic_vector(XLEN-1 downto 0);
             o_or    : out std_logic_vector(XLEN-1 downto 0);
);
end entity riscv_logic;

architecture arch of riscv_logic is
    signal a    : std_logic_vector(XLEN-1 downto 0);
    signal b    : std_logic_vector(XLEN-1 downto 0);
begin
    a <= i_a;
    b <= i_b;

    o_and <= a and b;
    o_xor <= a xor b;
    o_or  <= a or  b;
end architecture arch;
