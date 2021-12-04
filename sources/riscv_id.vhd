
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_id.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    Instruction Decode
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_id is
    port (
      i_clk       : in std_logic;
      i_rstn      : in std_logic;
      --
      i_reg_if_id : in E_REG_IF_ID;
      --
      i_wb        : in E_WB;
      --
      i_flush     : in std_logic;
      i_stall     : in std_logic;
      --
      o_rs_addr   : out T_RADDR_ARRAY;
      o_rs_data   : out T_RDATA_ARRAY;
      o_reg_id_ex : out E_REG_ID_EX
    );
end entity riscv_id;

architecture arch of riscv_id is
  type E_INST is record
    funct3    : std_logic_vector(3-1 downto 0);
    funct7    : std_logic_vector(7-1 downto 0);
    immed     : std_logic_vector(XLEN-1 downto 0);
    opcode    : std_logic_vector(6 downto 0);
    rs_addr   : T_RADDR_ARRAY;
    rd_addr   : std_logic_vector(REG_WIDTH-1 downto 0);
  end record;

  constant K_REG_ID_EX_ZERO : E_REG_ID_EX := 
                              (
                                alu_arith => '0', alu_sign  => '0', alu_type  => '0', alu_op  => (others => '0'),
                                branch    => '0', jump      => '0', jump_type => '0', pc  => (others => '0'),
                                dmem_re   => '0', dmem_we   => '0',
                                rd_we     => '0', rd_addr   => (others => '0'),
                                immed     => (others => '0')
                              );

  signal s_inst       : E_INST;
  signal s_reg_id_ex  : E_REG_ID_EX;
  signal s_nreg_id_ex : E_REG_ID_EX;
  signal s_rs_addr    : T_RADDR_ARRAY;
  signal s_rs_data    : T_RDATA_ARRAY;
  signal s_re         : std_logic;

begin

  X_RF : riscv_rf
  port map(
    i_clk     => i_clk,
    i_rstn    => i_rstn,
    i_we      => i_wb.rd_we,
    i_addr_w  => i_wb.rd_addr,
    i_data_w  => i_wb.rd_data,
    i_addr_ra => s_inst.rs_addr(0),
    o_data_ra => s_rs_data(0),
    i_addr_rb => s_inst.rs_addr(1),
    o_data_rb => s_rs_data(1)
  );
  s_re <= not i_stall;

  P_REG_ID_EX : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      if (i_stall = '0') then
        s_reg_id_ex <= s_nreg_id_ex;
        -- rs_addr clocked for EX
        s_rs_addr   <= s_inst.rs_addr;
      end if;

      if (i_flush = '1') then
        s_reg_id_ex <= K_REG_ID_EX_ZERO;
      end if;
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_reg_id_ex <= K_REG_ID_EX_ZERO;
    end if;
  end process;


  P_PREDECODE : process(i_reg_if_id)
    variable imem_read  : std_logic_vector(DPM_WIDTH-1 downto 0);
    variable op : std_logic_vector(6 downto 0);
  begin
    imem_read := i_reg_if_id.imem_read;

    -- default values
    s_inst.opcode     <= imem_read(6 downto 0);
    s_inst.rd_addr    <= imem_read(11 downto 7);
    s_inst.funct3     <= imem_read(14 downto 12);
    s_inst.rs_addr(0) <= imem_read(19 downto 15);
    s_inst.rs_addr(1) <= imem_read(24 downto 20);
    s_inst.funct7     <= imem_read(31 downto 25);
    -- -- init immed with I-TYPE
    s_inst.immed(10 downto 0)       <= imem_read(30 downto 20);
    s_inst.immed(XLEN-1 downto 11)  <= (others => imem_read(DPM_WIDTH-1));

    case imem_read(6 downto 0) is
      when "0110011" => -- R-TYPE
        null; -- don't care
      when "0010011" | "1100111" | "0000011" => -- I-TYPE 
        null;
      when "1100011" => -- B-TYPE
        s_inst.immed(0)                 <= '0';
        s_inst.immed(4 downto 1)        <= imem_read(11 downto 8);
        s_inst.immed(11)                <= imem_read(7);
      when "1101111" => -- J-TYPE
        s_inst.immed(0)                 <= '0';
        s_inst.immed(11)                <= imem_read(20);
        s_inst.immed(19 downto 12)      <= imem_read(19 downto 12);
      when "0100011" => -- S-TYPE
        s_inst.immed(4 downto 0)        <= imem_read(11 downto 7);
      when "0110111" => -- U-TYPE
        s_inst.immed(11 downto 0)       <= (others => '0');
        s_inst.immed(XLEN-1 downto 12)  <= imem_read(DPM_WIDTH-1 downto 12);
        -- For LUI, translate rs1 with 0
        s_inst.rs_addr(0)               <= (others => '0');
      when others =>    -- NOP
        s_inst.immed                    <= (others => '0');
        s_inst.rs_addr(0)               <= (others => '0');
    end case;
  end process;

  P_DECODE : process(s_inst)
  begin

    -- default values
    s_nreg_id_ex.alu_arith  <= '0';
    s_nreg_id_ex.alu_sign   <= '1';
    s_nreg_id_ex.alu_type   <= '1';
    s_nreg_id_ex.alu_op     <= s_inst.funct3;
    s_nreg_id_ex.branch     <= '0';
    s_nreg_id_ex.jump       <= '0';
    s_nreg_id_ex.jump_type  <= '0';
    s_nreg_id_ex.pc         <= i_reg_if_id.pc;
    s_nreg_id_ex.dmem_re    <= '0';
    s_nreg_id_ex.dmem_we    <= '0';
    s_nreg_id_ex.rd_addr    <= s_inst.rd_addr;
    s_nreg_id_ex.rd_we      <= '1';
    s_nreg_id_ex.immed      <= s_inst.immed;

    case s_inst.opcode is
      when "0110011" | "0010011" =>       -- ARITH & LOGIC
        if s_inst.opcode = "0110011" then
          s_nreg_id_ex.alu_type  <= '0';
          s_nreg_id_ex.alu_arith <= s_inst.funct7(5);
        elsif s_inst.funct3 = "101" then
          s_nreg_id_ex.alu_arith <= s_inst.funct7(5);
        end if;
        --
        if s_inst.funct3 = "011" then     -- SLT
          s_nreg_id_ex.alu_arith  <= '1';
          s_nreg_id_ex.alu_sign   <= '0';
          s_nreg_id_ex.alu_op     <= ALUOP_SLT;
        elsif s_inst.funct3 = "010" then
          s_nreg_id_ex.alu_arith  <= '1';
        end if;
      when "0110111" =>                   -- LUI
        s_nreg_id_ex.alu_op   <= ALUOP_OR;
      when "1100011" =>                   -- BEQ
        s_nreg_id_ex.branch   <= '1';
        s_nreg_id_ex.alu_op   <= ALUOP_XOR;
        s_nreg_id_ex.alu_type <= '0';
        s_nreg_id_ex.rd_we    <= '0';
      when "1100111" | "1101111" =>       -- JAL*
        s_nreg_id_ex.jump     <= '1';
        if s_inst.opcode = "1100111" then -- JALR
          s_nreg_id_ex.jump_type  <= '1';
        end if;
      when "0000011" =>                   -- LW
        s_nreg_id_ex.dmem_re  <= '1';
        s_nreg_id_ex.alu_op   <= ALUOP_ADD;
      when "0100011" =>                   -- SW
        s_nreg_id_ex.dmem_we  <= '1';
        s_nreg_id_ex.rd_we    <= '0';
        s_nreg_id_ex.alu_op   <= ALUOP_ADD;
      when others =>                      -- NOOP
        s_nreg_id_ex.alu_op   <= ALUOP_OR; 
        s_nreg_id_ex.rd_we    <= '0';
    end case;

  end process;

  -- Outputs
  o_reg_id_ex <= s_reg_id_ex;
  o_rs_addr   <= s_rs_addr;
  o_rs_data   <= s_rs_data;

end architecture arch;
