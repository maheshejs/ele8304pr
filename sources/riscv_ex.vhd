
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_ex.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    Execute
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_ex is
    port (
      i_clk       : in std_logic;
      i_rstn      : in std_logic;
      --
      i_rs_addr   : in T_RADDR_ARRAY;
      i_rs_data   : in T_RDATA_ARRAY;
      i_reg_id_ex : in E_REG_ID_EX;
      --
      i_reg_ex_me : in E_REG_EX_ME;
      i_reg_me_wb : in E_REG_ME_WB;
      i_dmem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
      --
      o_ex        : out E_EX;
      o_reg_ex_me : out E_REG_EX_ME
    );
end entity riscv_ex;

architecture arch of riscv_ex is

  signal s_stall_state    : std_logic := '0';
  signal s_flush          : std_logic := '0';
  signal s_reg_flush      : std_logic := '0';
  signal s_reg_dmem_re    : std_logic := '0';
  signal s_ex             : E_EX;
  signal s_reg_ex_me      : E_REG_EX_ME;
  signal s_rs_data        : T_RDATA_ARRAY;
  signal s_alu_result     : std_logic_vector(XLEN-1 downto 0);
  signal s_shamt          : std_logic_vector(SHAMT_WIDTH-1 downto 0);
  signal s_src1           : std_logic_vector(XLEN-1 downto 0);
  signal s_src2           : std_logic_vector(XLEN-1 downto 0);
  signal s_pc             : std_logic_vector(XLEN-1 downto 0);
  signal s_sum            : std_logic_vector(XLEN downto 0);
  signal s_or_stage_I     : std_logic_vector(16-1 downto 0);
  signal s_or_stage_II    : std_logic_vector(8-1 downto 0);
  signal s_or_stage_III   : std_logic_vector(4-1 downto 0);
  signal s_or_stage_IV    : std_logic_vector(2-1 downto 0);
  signal s_or_reduce      : std_logic;
  signal s_reg_rs_data    : T_RDATA_ARRAY;

begin

  X_ALU : riscv_alu
  port map(
    i_arith  => i_reg_id_ex.alu_arith,
    i_sign   => i_reg_id_ex.alu_sign,
    i_opcode => i_reg_id_ex.alu_op,
    i_shamt  => s_src2(SHAMT_WIDTH-1 downto 0),
    i_src1   => s_src1,
    i_src2   => s_src2,
    o_res    => s_alu_result
  );

  s_src1  <=  i_reg_id_ex.pc when i_reg_id_ex.jump = '1' else
              s_rs_data(0);
  s_src2  <=  s_rs_data(1) when i_reg_id_ex.alu_type = '0' else
              std_logic_vector(to_signed(4, s_src2'length)) when i_reg_id_ex.jump = '1' else
              i_reg_id_ex.immed;

  X_ADDER : riscv_adder 
  generic map(
    N       => XLEN
  )
  port map (
    i_a     => s_pc,
    i_b     => i_reg_id_ex.immed,
    i_sign  => '0',
    i_sub   => '0',
    o_sum   => s_sum
  );

  s_pc  <=  s_rs_data(0) when i_reg_id_ex.jump_type = '1' else
            i_reg_id_ex.pc;

  P_REG_EX_ME : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      s_reg_ex_me <=  (
                        alu_result  => s_alu_result,
                        dmem_write  => s_rs_data(1),
                        dmem_re     => i_reg_id_ex.dmem_re,
                        dmem_we     => i_reg_id_ex.dmem_we,
                        rd_addr     => i_reg_id_ex.rd_addr,
                        rd_we       => i_reg_id_ex.rd_we
                      );
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_reg_ex_me <=  (
                        alu_result  => (others => '0'),
                        dmem_write  => (others => '0'),
                        dmem_re     => '0',
                        dmem_we     => '0',
                        rd_addr     => (others => '0'),
                        rd_we       => '0'
                      );
    end if;
  end process;

  P_FORWARDING : process(i_reg_ex_me, i_reg_me_wb, i_rs_data, s_reg_rs_data, i_rs_addr, i_dmem_read, s_stall_state)
  begin
    -- default values
    if (s_stall_state = '1') then
      s_rs_data <= s_reg_rs_data;
    else
      s_rs_data <= i_rs_data;
    end if;

    for I in 0 to 1 loop
      -- Source registers are updated in Memory/Write-Back
      if (i_reg_me_wb.rd_addr = i_rs_addr(I)) then
        if (i_reg_me_wb.rd_we = '1') then
          if (i_reg_me_wb.dmem_re = '1') then
            s_rs_data(I) <= i_dmem_read;
          else
            s_rs_data(I) <= i_reg_me_wb.alu_result;
          end if;
        end if;
      end if;
      -- Source registers are updated in Execute/Memory
      if (i_reg_ex_me.rd_addr = i_rs_addr(I)) then
        if (i_reg_ex_me.rd_we = '1') then
          if (i_reg_ex_me.dmem_re = '1') then
            s_rs_data(I) <= i_dmem_read;
          else
            s_rs_data(I) <= i_reg_ex_me.alu_result;
          end if;
        end if;
      end if;
    end loop;
  end process;

  P_STALLING : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      s_reg_rs_data <= i_rs_data;
      s_stall_state <= not s_stall_state and i_reg_id_ex.dmem_re;
    end if;

    -- Asynchronous reset
    if (i_rstn = '0') then
      s_stall_state  <= '0';
    end if;
  end process;

  P_FLUSHING : process(i_clk)
  begin
    if (rising_edge(i_clk)) then
      s_reg_flush <= s_flush;
    end if;
  end process;

  GEN_OR_STAGE_I : for I in 0 to 16-1 generate
    s_or_stage_I(I) <= s_alu_result(I) or s_alu_result(16+I); 
  end generate GEN_OR_STAGE_I;

  GEN_OR_STAGE_II : for I in 0 to 8-1 generate
    s_or_stage_II(I) <= s_or_stage_I(I) or s_or_stage_I(8+I); 
  end generate GEN_OR_STAGE_II;

  GEN_OR_STAGE_III : for I in 0 to 4-1 generate
    s_or_stage_III(I) <= s_or_stage_II(I) or s_or_stage_II(4+I); 
  end generate GEN_OR_STAGE_III;

  GEN_OR_STAGE_IV : for I in 0 to 2-1 generate
    s_or_stage_IV(I) <= s_or_stage_III(I) or s_or_stage_III(2+I); 
  end generate GEN_OR_STAGE_IV;

  s_or_reduce <= s_or_stage_IV(0) or s_or_stage_IV(1);

  s_flush         <=  i_reg_id_ex.jump or (i_reg_id_ex.branch and not s_or_reduce);

  s_ex.flush      <=  s_flush or s_reg_flush;
  s_ex.stall      <=  not s_stall_state and i_reg_id_ex.dmem_re;
  s_ex.target     <=  s_sum(XLEN-1 downto 0);
  s_ex.transfert  <=  i_reg_id_ex.jump or (i_reg_id_ex.branch and not s_or_reduce);

  -- Outputs
  o_ex            <= s_ex;
  o_reg_ex_me     <= s_reg_ex_me;

end architecture arch;
