
-------------------------------------------------------------------------------
-- File     top.vhd
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

entity top is
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
      o_dmem_write  : out std_logic_vector(31 downto 0);
      -- DFT
      i_scan_en     : in std_logic;
      i_test_mode   : in std_logic;
      i_tdi       	: in std_logic;
      o_tdo       	: out std_logic
    );
end entity top;

architecture dft of top is
  component riscv_core is
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
        o_dmem_write  : out std_logic_vector(31 downto 0);
        -- DFT
        i_scan_en     : in std_logic;
        i_test_mode   : in std_logic;
        i_tdi       	: in std_logic;
        o_tdo       	: out std_logic
      );
  end component riscv_core;
begin
  -- Netlist DFT
  m_riscv_core : riscv_core
     port map (
        i_rstn        => i_rstn,
        i_clk         => i_clk,
        o_imem_en     => o_imem_en,
        o_imem_addr   => o_imem_addr,
        i_imem_read   => i_imem_read,
        o_dmem_en     => o_dmem_en,
        o_dmem_we     => o_dmem_we,
        o_dmem_addr   => o_dmem_addr,
        i_dmem_read   => i_dmem_read,
        o_dmem_write  => o_dmem_write,
        -- DFT
        i_scan_en     => i_scan_en,
        i_test_mode   => i_test_mode,
        i_tdi       	=> i_tdi,
        o_tdo       	=> o_tdo
      );
end architecture dft;

architecture rtl of top is
  component riscv_core is
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
      o_dmem_write  : out std_logic_vector(31 downto 0));
  end component riscv_core;
begin
  -- riscv_core RTL
    m_riscv_core : riscv_core
    port map (
      i_rstn        => i_rstn,
      i_clk         => i_clk,
      o_imem_en     => o_imem_en,
      o_imem_addr   => o_imem_addr,
      i_imem_read   => i_imem_read,
      o_dmem_en     => o_dmem_en,
      o_dmem_we     => o_dmem_we,
      o_dmem_addr   => o_dmem_addr,
      i_dmem_read   => i_dmem_read,
      o_dmem_write  => o_dmem_write);
    o_tdo <= '0';
end architecture rtl;
