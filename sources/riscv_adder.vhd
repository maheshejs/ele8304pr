
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
  signal s_a_top        : std_logic_vector(N-1 downto 0);
  signal s_b_top        : std_logic_vector(N-1 downto 0);
  signal s_carry_top    : std_logic_vector(N-1 downto 0);
  signal s_sum_top      : std_logic_vector(N-1 downto 0);
  signal s_a_bottom     : std_logic_vector(N-1 downto 0);
  signal s_b_bottom     : std_logic_vector(N-1 downto 0);
  signal s_carry_bottom : std_logic_vector(N-1 downto 0);
  signal s_sum_bottom   : std_logic_vector(N-1 downto 0);
  signal s_carry        : std_logic_vector(N downto 0);
  signal s_carry_out    : std_logic;

  component riscv_half_adder is
    port (
      i_a     : in  std_logic;
      i_b     : in  std_logic;
      o_carry : out std_logic;
      o_sum   : out std_logic
    );
  end component riscv_half_adder;

begin
  s_a_top <=  i_a;
  s_b_top <=  not i_b when i_sub = '1' else i_b;

  GEN_HALF_ADDER_TOP: 
  for I in 0 to N-1 generate
    X_RISCV_HALF_ADDER_TOP : riscv_half_adder 
    port map(
      i_a     => s_a_top(I),
      i_b     => s_b_top(I),
      o_carry => s_carry_top(I),
      o_sum   => s_sum_top(I)
    ); 
  end generate GEN_HALF_ADDER_TOP;  

  s_carry <= (s_carry_bottom(N-1 downto 0) or s_carry_top(N-1 downto 0)) & i_sub;

  GEN_HALF_ADDER_BOTTOM:
  for I in 0 to N-1 generate
    X_RISCV_HALF_ADDER_BOTTOM : riscv_half_adder 
    port map(
      i_a     => s_carry(I),
      i_b     => s_sum_top(I),
      o_carry => s_carry_bottom(I), 
      o_sum   => s_sum_bottom(I) 
    ); 
  end generate GEN_HALF_ADDER_BOTTOM;  

  o_sum       <= s_carry(N) & s_sum_bottom;

end architecture arch;

