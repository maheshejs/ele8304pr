
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_if.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    Instruction Fetch
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_if is
    port (
      i_clk       : in std_logic;
      i_rstn      : in std_logic;
      --
      i_flush     : in std_logic;
      i_stall     : in std_logic;
      i_transfert : in std_logic;
      i_target    : in std_logic_vector(XLEN-1 downto 0);
      --
      i_imem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
      --
      o_imem_addr : out std_logic_vector(DPM_DEPTH-1 downto 0);
      o_reg_if_id : out E_REG_IF_ID
    );
end entity riscv_if;

architecture arch of riscv_if is
  signal s_pc         : std_logic_vector(XLEN-1 downto 0);
  signal s_reg_if_id  : E_REG_IF_ID;

begin

  X_PC : riscv_pc
  generic map(
    RESET_VECTOR  => 16#00000000#
  )
  port map (
    i_clk         => i_clk,
    i_rstn        => i_rstn,
    i_stall       => i_stall,
    i_transfert   => i_transfert,
    i_target      => i_target,
    o_pc          => s_pc
  );

  P_REG_IF_ID : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      if (i_stall = '0') then
        s_reg_if_id.imem_read <= i_imem_read; 
      end if;

      if (i_flush = '1') then
        s_reg_if_id.imem_read <= (others => '0'); 
      end if;
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_reg_if_id.imem_read <= (others => '0'); 
    end if;
  end process;

  -- Outputs
  o_imem_addr <= s_pc(DPM_DEPTH+1 downto 2); -- TODO : Overflow
  o_reg_if_id <= s_reg_if_id;

end architecture arch;
