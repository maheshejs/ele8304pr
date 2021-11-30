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
    constant DPM_DEPTH : positive := 10;
    constant DPM_WIDTH : positive := 32;

  ------------------------------------------------------------------------------
  -- DEFINITIONS
  ------------------------------------------------------------------------------
  type E_REG_IF_ID is record
    imem_read : std_logic_vector(DPM_WIDTH-1 downto 0);
  end record;

  type E_REG_ID_EX is record
    flush     : std_logic;
    imem_read : std_logic;
    stall     : std_logic;
  end record;

  type E_REG_EX_ME is record
    alu_result: std_logic_vector(XLEN-1 downto 0);
    store_data: std_logic;
  end record;

  type E_REG_ME_WB is record
    alu_result: std_logic_vector(XLEN-1 downto 0);
    rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
  end record;

  type T_RADDR_ARRAY is array(0 to 1) of std_logic_vector(REG_WIDTH-1 downto 0);
  type T_RDATA_ARRAY is array(0 to 1) of std_logic_vector(XLEN-1 downto 0);
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
    constant ALUOP_ADD   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, ALUOP_WIDTH));
    constant ALUOP_SL    : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, ALUOP_WIDTH));
    constant ALUOP_SLT   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(2, ALUOP_WIDTH));
    constant ALUOP_XOR   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(4, ALUOP_WIDTH));
    constant ALUOP_SR    : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(5, ALUOP_WIDTH));
    constant ALUOP_OR    : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(6, ALUOP_WIDTH));
    constant ALUOP_AND   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(7, ALUOP_WIDTH));

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

    component riscv_half_adder is
        port (
                 i_a     : in  std_logic;
                 i_b     : in  std_logic;
                 o_carry : out std_logic;
                 o_sum   : out std_logic
             );
    end component riscv_half_adder;

    component riscv_logic is
        port (
                i_a     : in  std_logic_vector(XLEN-1 downto 0);
                i_b     : in  std_logic_vector(XLEN-1 downto 0);
                o_and   : out std_logic_vector(XLEN-1 downto 0);
                o_xor   : out std_logic_vector(XLEN-1 downto 0);
                o_or    : out std_logic_vector(XLEN-1 downto 0)
             );
    end component riscv_logic;
end package riscv_pkg;
