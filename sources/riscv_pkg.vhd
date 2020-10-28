-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_pkg.vhd
-- Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab      GRM - Polytechnique Montreal
-- Date     2019-08-09
-------------------------------------------------------------------------------
-- Brief    Package for constants, components, and procedures
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package riscv_pkg is

  ------------------------------------------------------------------------------
  -- MAIN PARAMETERS
  ------------------------------------------------------------------------------
  constant XLEN      : positive := 32;
  constant REG_WIDTH : positive := 5;

  ------------------------------------------------------------------------------
  --  INSTRUCTION FORMATS
  ------------------------------------------------------------------------------
  constant SHAMT_H     : natural := 24;
  constant SHAMT_L     : natural := 20;
  constant SHAMT_WIDTH : natural := SHAMT_H-SHAMT_L+1;
  
  ------------------------------------------------------------------------------
  -- ALU
  ------------------------------------------------------------------------------
  constant ALUOP_WIDTH : natural := 3;

  ------------------------------------------------------------------------------
  -- COMPONENTS
  ------------------------------------------------------------------------------
  component riscv_adder is
    generic (
      N : positive);
    port (
      i_a    : in  std_logic_vector(N-1 downto 0);
      i_b    : in  std_logic_vector(N-1 downto 0);
      i_sign : in  std_logic;
      i_sub  : in  std_logic;
      o_sum  : out std_logic_vector(N downto 0));
  end component riscv_adder;

  component riscv_alu is
    port (
      i_arith  : in  std_logic;
      i_sign   : in  std_logic;
      i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
      i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
      i_src1   : in  std_logic_vector(XLEN-1 downto 0);
      i_src2   : in  std_logic_vector(XLEN-1 downto 0);
      o_res    : out std_logic_vector(XLEN-1 downto 0));
  end component riscv_alu;

  component riscv_rf is
    port (
      i_clk     : in  std_logic;
      i_rstn    : in  std_logic;
      i_we      : in  std_logic;
      i_addr_ra : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o_data_ra : out std_logic_vector(XLEN-1 downto 0);
      i_addr_rb : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o_data_rb : out std_logic_vector(XLEN-1 downto 0);
      i_addr_w  : in  std_logic_vector(REG_WIDTH-1 downto 0);
      i_data_w  : in  std_logic_vector(XLEN-1 downto 0));
  end component riscv_rf;

  component riscv_pc is
    generic (
      RESET_VECTOR : natural);
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;
      i_stall     : in  std_logic;
      i_transfert : in  std_logic;
      i_target    : in  std_logic_vector(XLEN-1 downto 0);
      o_pc        : out std_logic_vector(XLEN-1 downto 0));
  end component riscv_pc;

  component riscv_perf is
    port (
      i_rstn   : in  std_logic;
      i_clk    : in  std_logic;
      i_en     : in  std_logic;
      o_cycles : out std_logic_vector(XLEN-1 downto 0);
      o_insts  : out std_logic_vector(XLEN-1 downto 0));
  end component riscv_perf;

end package riscv_pkg;
