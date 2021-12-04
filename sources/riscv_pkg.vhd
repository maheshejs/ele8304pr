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
    constant DPM_DEPTH : positive := 9;
    constant DPM_WIDTH : positive := 32;

  ------------------------------------------------------------------------------
    constant SHAMT_H     : natural := 24;
    constant SHAMT_L     : natural := 20;
    constant SHAMT_WIDTH : natural := SHAMT_H-SHAMT_L+1;

  ------------------------------------------------------------------------------
  -- ALU
  ------------------------------------------------------------------------------
    constant ALUOP_WIDTH : natural := 3;
    constant ALUOP_ADD   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "000";
    constant ALUOP_SL    : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "001";
    constant ALUOP_SLT   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "010";
    constant ALUOP_XOR   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "100";
    constant ALUOP_SR    : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "101";
    constant ALUOP_OR    : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "110";
    constant ALUOP_AND   : std_logic_vector(ALUOP_WIDTH-1 downto 0) := "111";

  ------------------------------------------------------------------------------
  -- DEFINITIONS
  ------------------------------------------------------------------------------
  type E_REG_IF_ID is record
    imem_read : std_logic_vector(DPM_WIDTH-1 downto 0);
    pc        : std_logic_vector(XLEN-1 downto 0);
  end record;

  type E_REG_ID_EX is record
    alu_arith : std_logic;
    alu_sign  : std_logic;
    alu_type  : std_logic;
    alu_op    : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    branch    : std_logic;
    jump      : std_logic;
    jump_type : std_logic;
    pc        : std_logic_vector(XLEN-1 downto 0);
    dmem_re   : std_logic;
    dmem_we   : std_logic;
    rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    rd_we     : std_logic;
    immed     : std_logic_vector(XLEN-1 downto 0);
  end record;

  type E_REG_EX_ME is record
    alu_result: std_logic_vector(XLEN-1 downto 0);
    dmem_write: std_logic_vector(DPM_WIDTH-1 downto 0);
    dmem_re   : std_logic;
    dmem_we   : std_logic;
    rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    rd_we     : std_logic;
  end record;

  type E_REG_ME_WB is record
    alu_result: std_logic_vector(XLEN-1 downto 0);
    dmem_re   : std_logic;
    dmem_we   : std_logic;
    rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    rd_we     : std_logic;
  end record;

  type E_EX is record
    flush     : std_logic;
    stall     : std_logic;
    transfert : std_logic;
    target    : std_logic_vector(XLEN-1 downto 0);
  end record;

  type E_WB is record
    rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
    rd_data   : std_logic_vector(XLEN-1 downto 0);
    rd_we     : std_logic;
  end record;

  type T_RADDR_ARRAY is array(0 to 1) of std_logic_vector(REG_WIDTH-1 downto 0);
  type T_RDATA_ARRAY is array(0 to 1) of std_logic_vector(XLEN-1 downto 0);

  ------------------------------------------------------------------------------
  --  INSTRUCTION FORMATS
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

    component riscv_if is
        port (
          i_clk       : in std_logic;
          i_rstn      : in std_logic;
          i_ex        : in E_EX;
          i_imem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
          o_imem_addr : out std_logic_vector(DPM_DEPTH-1 downto 0);
          o_reg_if_id : out E_REG_IF_ID
        );
    end component riscv_if;

    component riscv_id is
        port (
          i_clk       : in std_logic;
          i_rstn      : in std_logic;
          i_reg_if_id : in E_REG_IF_ID;
          i_wb        : in E_WB;
          i_flush     : in std_logic;
          i_stall     : in std_logic;
          o_rs_addr   : out T_RADDR_ARRAY;
          o_rs_data   : out T_RDATA_ARRAY;
          o_reg_id_ex : out E_REG_ID_EX
        );
    end component riscv_id;

    component riscv_ex is
        port (
          i_clk       : in std_logic;
          i_rstn      : in std_logic;
          i_rs_addr   : in T_RADDR_ARRAY;
          i_rs_data   : in T_RDATA_ARRAY;
          i_reg_id_ex : in E_REG_ID_EX;
          i_reg_ex_me : in E_REG_EX_ME;
          i_reg_me_wb : in E_REG_ME_WB;
          i_dmem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
          o_ex        : out E_EX;
          o_reg_ex_me : out E_REG_EX_ME
        );
    end component riscv_ex;

    component riscv_me is
        port (
          i_clk       : in std_logic;
          i_rstn      : in std_logic;
          i_stall     : in std_logic;
          i_reg_ex_me : in E_REG_EX_ME;
          o_dmem_addr : out std_logic_vector(DPM_DEPTH-1 downto 0);
          o_dmem_en   : out std_logic;
          o_dmem_we   : out std_logic;
          o_dmem_write: out std_logic_vector(DPM_WIDTH-1 downto 0);
          o_reg_me_wb : out E_REG_ME_WB
        );
    end component riscv_me;

    component riscv_wb is
        port (
          i_dmem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
          i_reg_me_wb : in E_REG_ME_WB;
          o_wb        : out E_WB
        );
    end component riscv_wb;

    component riscv_core
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
        );
    end component riscv_core;

    component dpm
        generic (
          WIDTH : integer := 32;
          DEPTH : integer := 10;
          RESET : integer := 16#00000000#;
          INIT  : string  := "memory.mem"
        );
        port (
          i_a_clk   : in  std_logic;
          i_a_rstn  : in  std_logic;
          i_a_en    : in  std_logic;
          i_a_we    : in  std_logic;
          i_a_addr  : in  std_logic_vector(DEPTH-1 downto 0);
          i_a_write : in  std_logic_vector(WIDTH-1 downto 0);
          o_a_read  : out std_logic_vector(WIDTH-1 downto 0);
          i_b_clk   : in  std_logic;
          i_b_rstn  : in  std_logic;
          i_b_en    : in  std_logic;
          i_b_we    : in  std_logic;
          
          i_b_addr  : in  std_logic_vector(DEPTH-1 downto 0);
          i_b_write : in  std_logic_vector(WIDTH-1 downto 0);
          o_b_read  : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component dpm;
end package riscv_pkg;
