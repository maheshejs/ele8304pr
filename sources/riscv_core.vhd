
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_core.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    Core
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_core is
    port (
      i_rstn        : in std_logic;
      i_clk         : in std_logic;
      o_imem_en     : out std_logic;
      o_imem_addr   : out std_logic_vector(8 downto 0);
      i_imem_read   : in std_logic_vector(31 downto 0);
      o_dmem_en     : out std_logic;
      o_dmem_we     : out std_logic;
      o_dmem_addr   : out std_logic_vector(8 downto 0);
      i_dmem_read   : in std_logic_vector(31 downto 0);
      o_dmem_write  : out std_logic_vector(31 downto 0)
      -- DFT
      --i_scan_en     : in std_logic;
      --i_test_mode   : in std_logic;
      --i_tdi       : in std_logic;
      --o_tdo       : out std_logic
    );
end entity riscv_core;

architecture arch of riscv_core is
  signal s_ex         : E_EX;
  signal s_reg_if_id  : E_REG_IF_ID;
  signal s_reg_id_ex  : E_REG_ID_EX;
  signal s_reg_ex_me  : E_REG_EX_ME;
  signal s_reg_me_wb  : E_REG_ME_WB;
  signal s_rs_addr    : T_RADDR_ARRAY;  
  signal s_rs_data    : T_RDATA_ARRAY;  
  signal s_wb         : E_WB;

begin

  X_IF : riscv_if
  port map(
    i_clk       => i_clk,
    i_rstn      => i_rstn,
    i_ex        => s_ex,
    i_imem_read => i_imem_read,
    o_imem_addr => o_imem_addr,
    o_reg_if_id => s_reg_if_id
  );

  X_ID : riscv_id
  port map(
    i_clk       => i_clk,
    i_rstn      => i_rstn,
    i_reg_if_id => s_reg_if_id,
    i_wb        => s_wb,
    i_flush     => s_ex.flush,
    o_rs_addr   => s_rs_addr,
    o_rs_data   => s_rs_data,
    o_reg_id_ex => s_reg_id_ex
  );

  X_EX : riscv_ex
  port map(
    i_clk       => i_clk,
    i_rstn      => i_rstn,
    i_rs_addr   => s_rs_addr,
    i_rs_data   => s_rs_data,
    i_reg_id_ex => s_reg_id_ex,
    i_reg_ex_me => s_reg_ex_me,
    i_reg_me_wb => s_reg_me_wb,
    i_dmem_read => i_dmem_read,
    o_ex        => s_ex,
    o_reg_ex_me => s_reg_ex_me
  );

  X_ME : riscv_me
  port map(
    i_clk       => i_clk,
    i_rstn      => i_rstn,
    i_reg_ex_me => s_reg_ex_me,
    o_dmem_addr => o_dmem_addr,
    o_dmem_en   => o_dmem_en,
    o_dmem_we   => o_dmem_we,
    o_dmem_write=> o_dmem_write,
    o_reg_me_wb => s_reg_me_wb
  );

  X_WB : riscv_wb
  port map(
    i_dmem_read => i_dmem_read,
    i_reg_me_wb => s_reg_me_wb,
    o_wb        => s_wb
  );

  -- Outputs
  o_imem_en <= '1';

end architecture arch;
