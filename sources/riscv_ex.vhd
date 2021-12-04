
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

  function or_reduce(arg: std_logic_vector) return std_logic is
    variable result: std_logic;
  begin
      result := '0';
      for i in arg'range loop
        result := result or arg(i);
      end loop;
      return result;
  end;

  signal s_stall      : std_logic := '0';
  signal s_stall_state: std_logic := '0';
  signal s_flush      : std_logic := '0';
  signal s_reg_flush  : std_logic := '0';
  signal s_reg_dmem_re: std_logic := '0';
  signal s_ex         : E_EX;
  signal s_reg_ex_me  : E_REG_EX_ME;
  signal s_rs_data    : T_RDATA_ARRAY;
  signal s_alu_result : std_logic_vector(XLEN-1 downto 0);
  signal s_shamt      : std_logic_vector(SHAMT_WIDTH-1 downto 0);
  signal s_src1       : std_logic_vector(XLEN-1 downto 0);
  signal s_src2       : std_logic_vector(XLEN-1 downto 0);
  signal s_pc         : std_logic_vector(XLEN-1 downto 0);
  signal s_sum        : std_logic_vector(XLEN downto 0);

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

  P_FORWARDING : process(i_reg_ex_me, i_reg_me_wb, i_rs_data, i_dmem_read)
  begin
    -- default values
    s_rs_data <= i_rs_data;

    for I in 0 to 1 loop
      if (i_reg_me_wb.rd_addr = i_rs_addr(I)) then
        if (i_reg_me_wb.rd_we = '1') then
          if (i_reg_me_wb.dmem_re = '1') then
            s_rs_data(I) <= i_dmem_read;
          else
            s_rs_data(I) <= i_reg_me_wb.alu_result;
          end if;
        end if;
      end if;
      --
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

  P_STALLING : process(i_clk)
  begin
    if (rising_edge(i_clk)) then
      s_reg_dmem_re <= i_reg_id_ex.dmem_re;
      s_reg_stall   <= s_stall;
      s_reg2_stall  <= s_reg_stall;
    end if;
  end process;
  s_stall         <=  not s_reg_dmem_re and i_reg_id_ex.dmem_re;

  P_FLUSHING : process(i_clk)
  begin
    if (rising_edge(i_clk)) then
      s_reg_flush <= s_flush;
    end if;
  end process;
  s_flush         <=  i_reg_id_ex.jump or (i_reg_id_ex.branch and not or_reduce(s_alu_result));

  s_ex.flush      <=  s_flush or s_reg_flush;
  s_ex.stall      <=  s_stall;
  s_ex.target     <=  s_sum(XLEN-1 downto 0);
  s_ex.transfert  <=  i_reg_id_ex.jump or (i_reg_id_ex.branch and not or_reduce(s_alu_result));

  -- Outputs
  o_ex        <= s_ex;
  o_reg_ex_me <= s_reg_ex_me;

end architecture arch;
