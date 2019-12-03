-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     mips_tb.vhd
-- Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab      GRM - Polytechnique Montreal
-- Date     2019-08-09
-------------------------------------------------------------------------------
-- Brief    Banc d'essai du mini-mips
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use std.env.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity mips_tb is
end entity mips_tb;

architecture tb of mips_tb is

  constant READ_PERF_COUNTERS  : boolean := false;
  constant DECODE_INSTRUCTIONS : boolean := true;
  constant MEM_INIT_FILE       : string  := "../asm/mips_basic.mem";
  constant PERIOD              : time    := 10000 ps;

  constant RLEN       : positive := 32;
  constant MEM_ADDR_W : positive := 10;
  constant PC_RESET   : natural  := 16#00000000#;

  -----------------------------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------------------------
  type t_opcode is (lui, j, jal, beq, lw, sw, addi, addiu, slti, sltiu, xori, ori, andi, jalr, add,
                    sub, sllv, srlv, srav, slli, srli, srai, slt, sltu, xxor, oor, aand, nop, other);

  -- Produces instruction opcode (+ funct) from imem output
  procedure decode (
    signal imem   : in  std_logic_vector(RLEN-1 downto 0);
    signal opcode : out t_opcode) is
    --
    constant OP_LUI   : std_logic_vector(5 downto 0) := "001111";
    constant OP_JAL   : std_logic_vector(5 downto 0) := "000011";
    constant OP_J     : std_logic_vector(5 downto 0) := "000010";
    constant OP_BEQ   : std_logic_vector(5 downto 0) := "000100";
    constant OP_LW    : std_logic_vector(5 downto 0) := "100011";
    constant OP_SW    : std_logic_vector(5 downto 0) := "101011";
    constant OP_ADDI  : std_logic_vector(5 downto 0) := "001000";
    constant OP_ADDIU : std_logic_vector(5 downto 0) := "001001";
    constant OP_SLTI  : std_logic_vector(5 downto 0) := "001010";
    constant OP_SLTIU : std_logic_vector(5 downto 0) := "001011";
    constant OP_XORI  : std_logic_vector(5 downto 0) := "001110";
    constant OP_ORI   : std_logic_vector(5 downto 0) := "001101";
    constant OP_ANDI  : std_logic_vector(5 downto 0) := "001100";
    constant OP_RTYPE : std_logic_vector(5 downto 0) := "000000";
    constant FCT_JALR : std_logic_vector(5 downto 0) := "001001";
    constant FCT_ADD  : std_logic_vector(5 downto 0) := "100000";
    constant FCT_SUB  : std_logic_vector(5 downto 0) := "100010";
    constant FCT_SLL  : std_logic_vector(5 downto 0) := "000000";
    constant FCT_SRL  : std_logic_vector(5 downto 0) := "000010";
    constant FCT_SRA  : std_logic_vector(5 downto 0) := "000011";
    constant FCT_SLLV : std_logic_vector(5 downto 0) := "000100";
    constant FCT_SRLV : std_logic_vector(5 downto 0) := "000110";
    constant FCT_SRAV : std_logic_vector(5 downto 0) := "000111";
    constant FCT_SLT  : std_logic_vector(5 downto 0) := "101010";
    constant FCT_SLTU : std_logic_vector(5 downto 0) := "101011";
    constant FCT_XOR  : std_logic_vector(5 downto 0) := "100110";
    constant FCT_OR   : std_logic_vector(5 downto 0) := "100101";
    constant FCT_AND  : std_logic_vector(5 downto 0) := "100100";
    constant NOOP : std_logic_vector(RLEN-1 downto 0)  := OP_RTYPE & 20x"0" & FCT_SLL;
  begin
    if imem = NOOP then
      opcode <= nop;
    else
      case imem(31 downto 26) is
        when OP_RTYPE =>
          case imem(5 downto 0) is
            when FCT_JALR => opcode <= jalr;
            when FCT_ADD  => opcode <= add;
            when FCT_SUB  => opcode <= sub;
            when FCT_SLL  => opcode <= slli;
            when FCT_SLLV => opcode <= sllv;
            when FCT_SRL  => opcode <= srli;
            when FCT_SRLV => opcode <= srlv;
            when FCT_SRA  => opcode <= srai;
            when FCT_SRAV => opcode <= srav;
            when FCT_SLT  => opcode <= slt;
            when FCT_SLTU => opcode <= sltu;
            when FCT_XOR  => opcode <= xxor;
            when FCT_OR   => opcode <= oor;
            when FCT_AND  => opcode <= aand;
            when others   => opcode <= other;
          end case;
        when OP_ADDI  => opcode <= addi;
        when OP_ADDIU => opcode <= addiu;
        when OP_SLTI  => opcode <= slti;
        when OP_SLTIU => opcode <= sltiu;
        when OP_XORI  => opcode <= xori;
        when OP_ORI   => opcode <= ori;
        when OP_ANDI  => opcode <= andi;
        when OP_LUI   => opcode <= lui;
        when OP_LW    => opcode <= lw;
        when OP_SW    => opcode <= sw;
        when OP_BEQ   => opcode <= beq;
        when OP_JAL   => opcode <= jal;
        when OP_J     => opcode <= j;
        when others   => opcode <= other;
      end case;
    end if;
  end procedure decode;

  -- Transport I/O with estimated delay (PERIOD/10) to handle post-pnr simulation timing issues
  procedure transport_io (
    constant P   : in time;
    signal i_sig : in  std_logic_vector;
    signal o_sig : out std_logic_vector) is
    --
    constant IO_DELAY : time := P / 10;
  begin
      o_sig <= inertial i_sig after IO_DELAY;
  end procedure transport_io;

  -- Returns the number of Cycles per Instructions
  function cpi (c : in unsigned; i : in unsigned) return string is
  begin
    return real'image(real(to_integer(c)) / real(to_integer(i)));
  end function cpi;

  -- Returns the Execution time (c * P)
  function exec_time (c : in unsigned; constant P : in time) return string is
  begin
    return time'image(to_integer(c) * P);
  end function exec_time;

  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------
  component dpm is
    generic (
      WIDTH : integer;
      DEPTH : integer;
      RESET : integer;
      INIT  : string);
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
      o_b_read  : out std_logic_vector(WIDTH-1 downto 0));
  end component dpm;

  component mips_core is
    port (
      i_rstn       : in  std_logic;
      i_clk        : in  std_logic;
      o_imem_en    : out std_logic;
      o_imem_addr  : out std_logic_vector(MEM_ADDR_W-1 downto 0);
      i_imem_read  : in  std_logic_vector(RLEN-1 downto 0);
      o_dmem_en    : out std_logic;
      o_dmem_we    : out std_logic;
      o_dmem_addr  : out std_logic_vector(MEM_ADDR_W-1 downto 0);
      i_dmem_read  : in  std_logic_vector(RLEN-1 downto 0);
      o_dmem_write : out std_logic_vector(RLEN-1 downto 0));
  end component mips_core;

  -----------------------------------------------------------------------------
  -- TB
  -----------------------------------------------------------------------------

  -- Clock & Reset
  signal rstn   : std_logic := '0';
  signal rst_en : std_logic := '0';
  signal clk_en : std_logic := '0';
  signal clk    : std_logic := '0';

  -- Memory interface
  signal imem_en        : std_logic;
  signal imem_addr      : std_logic_vector(MEM_ADDR_W-1 downto 0);
  signal imem_read      : std_logic_vector(RLEN-1 downto 0);
  signal imem_read_core : std_logic_vector(RLEN-1 downto 0);
  signal dmem_en        : std_logic;
  signal dmem_we        : std_logic;
  signal dmem_addr      : std_logic_vector(MEM_ADDR_W-1 downto 0);
  signal dmem_read      : std_logic_vector(RLEN-1 downto 0);
  signal dmem_read_core : std_logic_vector(RLEN-1 downto 0);
  signal dmem_write     : std_logic_vector(RLEN-1 downto 0);

  -- TB signals
  constant LAST_INST : std_logic_vector(RLEN-1 downto 0) := x"1220ffff";  -- end: beqz $s1, end
  signal opcode      : t_opcode;
  signal cycles      : unsigned(RLEN-1 downto 0);
  signal insts       : unsigned(RLEN-1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- CLOCK & RESET
  -----------------------------------------------------------------------------
  clk <= inertial not clk after PERIOD/2 when clk_en = '1' else '0';

  p_rst : process(clk)
  begin
    if falling_edge(clk) then
      if rst_en = '1' then
        rstn <= not rstn;
      end if;
    end if;
  end process p_rst;

  -----------------------------------------------------------------------------
  -- CORE + MEM
  -----------------------------------------------------------------------------
  m_core : mips_core
    port map (
      i_rstn       => rstn,
      i_clk        => clk,
      o_imem_en    => imem_en,
      o_imem_addr  => imem_addr,
      i_imem_read  => imem_read_core,
      o_dmem_en    => dmem_en,
      o_dmem_we    => dmem_we,
      o_dmem_addr  => dmem_addr,
      i_dmem_read  => dmem_read_core,
      o_dmem_write => dmem_write);

  m_dpm : dpm
    generic map (
      WIDTH => RLEN,
      DEPTH => MEM_ADDR_W,
      RESET => PC_RESET,
      INIT  => MEM_INIT_FILE)
    port map (
      i_a_clk   => clk,
      i_a_rstn  => rstn,
      i_a_en    => imem_en,
      i_a_we    => '0',
      i_a_addr  => imem_addr,
      i_a_write => (others => '0'),
      o_a_read  => imem_read,
      i_b_clk   => clk,
      i_b_rstn  => rstn,
      i_b_en    => dmem_en,
      i_b_we    => dmem_we,
      i_b_addr  => dmem_addr,
      i_b_write => dmem_write,
      o_b_read  => dmem_read);

  -- Transport memory signal to dut
  transport_io(PERIOD, imem_read, imem_read_core);
  transport_io(PERIOD, dmem_read, dmem_read_core);

  -----------------------------------------------------------------------------
  -- TB
  -----------------------------------------------------------------------------

  -- Decode instructions to facilitate debug (--> vsim +acc)
  g_decode: if DECODE_INSTRUCTIONS generate
    decode(imem_read, opcode);
  end generate g_decode;

  -- Read cycle count & instruction count from the core
  g_spy: if READ_PERF_COUNTERS generate
    p_spy : process
    begin
      init_signal_spy("/m_core/cycles","cycles",1,1);
      init_signal_spy("/m_core/insts","insts",1,1);
      wait;
    end process p_spy;
  end generate g_spy;

  p_main : process
  begin
    report "BEGIN SIMULATION";

    -- Let the Xs settle...
    wait for 2 * PERIOD;
    clk_en <= '1';

    -- Reset
    wait until rising_edge(clk);
    rst_en <= '1';
    wait for PERIOD;
    rst_en <= '0';

    -- Main loop
    while (imem_read /= LAST_INST) loop
      wait for PERIOD;
      if dmem_we = '1' then
        report LF & "   DMEM" & "[" & to_hstring(dmem_addr) & "] = "
          & to_hstring(dmem_write) & " (" & to_string(to_integer(unsigned(dmem_write))) & ")";
      end if;
    end loop;

    -- Performances
    if READ_PERF_COUNTERS then
      report LF & "   CPI : " & cpi(cycles, insts);
      report LF & "   EXEC: " & exec_time(cycles, PERIOD);
    end if;

    -- Reset
    wait until rising_edge(clk);
    wait for PERIOD;
    rst_en <= '1';
    wait for PERIOD;
    rst_en <= '0';

    report "END SIMULATION";
    stop;
  end process p_main;

end architecture tb;
