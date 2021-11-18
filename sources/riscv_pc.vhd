
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_pc.vhd
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

entity riscv_pc is
  generic (RESET_VECTOR : natural := 16#00000000#);
  port (
    i_clk       : in std_logic;
    i_rstn      : in std_logic;
    i_stall     : in std_logic;
    i_transfert : in std_logic;
    i_target    : in std_logic_vector(XLEN-1 downto 0);
    o_pc        : out std_logic_vector(XLEN-1 downto 0)
  );
end entity riscv_pc;

architecture arch of riscv_pc is
  signal s_pc  : std_logic_vector(XLEN-1 downto 0);
  signal s_sum : std_logic_vector(XLEN downto 0);

begin

  P_PROGRAM_COUNTER : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      if (i_stall = '0') then
        if (i_transfert = '1') then
          s_pc <= i_target;
        else
          s_pc <= s_sum(XLEN-1 downto 0);
        end if;
      end if;
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_pc <= std_logic_vector(to_unsigned(RESET_VECTOR, s_pc'length));
    end if;
  end process;

  X_RISCV_ADDER : riscv_adder 
  generic map(
      N       => XLEN
  )
  port map(
      i_a     => s_pc,
      i_b     => std_logic_vector(to_unsigned(4, XLEN)),
      i_sign  => '0',
      i_sub   => '0',
      o_sum   => s_sum
  ); 

  -- Outputs
  o_pc <= s_pc;
end architecture arch;
