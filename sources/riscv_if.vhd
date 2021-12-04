
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
      i_ex        : in E_EX;
      --
      i_imem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
      --
      o_imem_addr : out std_logic_vector(DPM_DEPTH-1 downto 0);
      o_imem_re   : out std_logic;
      o_reg_if_id : out E_REG_IF_ID
    );
end entity riscv_if;

architecture arch of riscv_if is
  constant K_REG_IF_ID_ZERO : E_REG_IF_ID := 
                              (
                                imem_read => (others => '0'),
                                pc        => (others => '0')
                              );
  signal s_pc         : std_logic_vector(XLEN-1 downto 0);
  signal s_dly_pc     : std_logic_vector(XLEN-1 downto 0);
  signal s_reg_if_id  : E_REG_IF_ID;

begin

  X_PC : riscv_pc
  generic map(
    RESET_VECTOR  => 16#00000000#
  )
  port map (
    i_clk         => i_clk,
    i_rstn        => i_rstn,
    i_stall       => i_ex.stall,
    i_transfert   => i_ex.transfert,
    i_target      => i_ex.target,
    o_pc          => s_pc
  );

  P_REG_IF_ID : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      if (i_ex.stall = '0') then
        -- s_pc delayed for ID
        s_dly_pc        <= s_pc;
        s_reg_if_id.pc  <= s_dly_pc; 
        --
        s_reg_if_id.imem_read <= i_imem_read; 
      end if;
      
      if (i_ex.flush = '1') then
        s_reg_if_id.imem_read <= (others => '0'); 
      end if;
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_reg_if_id <= K_REG_IF_ID_ZERO; 
    end if;
  end process;

  -- Outputs
  o_imem_re   <= not i_ex.stall;
  o_imem_addr <= s_pc(DPM_DEPTH+1 downto 2); 
  o_reg_if_id <= s_reg_if_id;

end architecture arch;
