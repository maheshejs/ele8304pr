
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_adder.vhd
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

entity riscv_adder is
  generic (N : positive := 32);
  port (
    i_a    : in  std_logic_vector(N-1 downto 0);
    i_b    : in  std_logic_vector(N-1 downto 0);
    i_sign : in  std_logic;
    i_sub  : in  std_logic;
    o_sum  : out std_logic_vector(N downto 0)
  );
end entity riscv_adder;

architecture arch of riscv_adder is
  type T_ARRAY is array(0 to 1) of std_logic_vector(N-1 downto 0);
  signal s_a     : T_ARRAY;
  signal s_b     : T_ARRAY;
  signal s_carry : T_ARRAY;
  signal s_sum   : T_ARRAY;
  signal s_sig   : std_logic;

begin

  s_a(0) <= i_a;
  s_b(0) <= not i_b when i_sub = '1' else i_b;
  s_a(1) <= (s_carry(0)(N-2 downto 0) or s_carry(1)(N-2 downto 0)) & i_sub;
  s_b(1) <= s_sum(0);

  GEN_FULL_ADDER:
  for I in 0 to 1 generate
    GEN_HALF_ADDER:
    for J in 0 to N-1 generate
        X_RISCV_HALF_ADDER : riscv_half_adder 
        port map(
          i_a     => s_a(I)(J),
          i_b     => s_b(I)(J),
          o_carry => s_carry(I)(J), 
          o_sum   => s_sum(I)(J) 
        ); 
    end generate GEN_HALF_ADDER;
  end generate GEN_FULL_ADDER;  

  s_sig <= s_carry(1)(N-1) xor s_carry(1)(N-2) when i_sign = '1' else s_carry(0)(N-1) or s_carry(1)(N-1);

  -- Outputs
  o_sum <= s_sig & s_sum(1);

end architecture arch;
