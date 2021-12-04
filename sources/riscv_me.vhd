
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_me.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    Memory Access
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_me is
    port (
      i_clk       : in std_logic;
      i_rstn      : in std_logic;
      --
      i_stall     : in std_logic;
      i_reg_ex_me : in E_REG_EX_ME;
      --
      o_dmem_addr : out std_logic_vector(DPM_DEPTH-1 downto 0);
      o_dmem_en   : out std_logic;
      o_dmem_we   : out std_logic;
      o_dmem_write: out std_logic_vector(DPM_WIDTH-1 downto 0);
      o_reg_me_wb : out E_REG_ME_WB
    );
end entity riscv_me;

architecture arch of riscv_me is
  signal s_reg_me_wb  : E_REG_ME_WB;
begin

  P_REG_ME_WB : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      if (i_stall = '0') then
        s_reg_me_wb <=  (
                          alu_result  => i_reg_ex_me.alu_result,
                          dmem_re     => i_reg_ex_me.dmem_re,
                          dmem_we     => i_reg_ex_me.dmem_we,
                          rd_addr     => i_reg_ex_me.rd_addr,
                          rd_we       => i_reg_ex_me.rd_we
                        );
      end if;
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_reg_me_wb <=  (
                        alu_result  => (others => '0'),
                        dmem_re     => '0',
                        dmem_we     => '0',
                        rd_addr     => (others => '0'),
                        rd_we       => '0'
                      );
    end if;
  end process;

  -- Outputs
  o_dmem_addr   <= i_reg_ex_me.alu_result(DPM_DEPTH+1 downto 2);
  o_dmem_en     <= i_reg_ex_me.dmem_re or i_reg_ex_me.dmem_we;
  o_dmem_we     <= i_reg_ex_me.dmem_we;
  o_dmem_write  <= i_reg_ex_me.dmem_write;
  o_reg_me_wb   <= s_reg_me_wb;

end architecture arch;
