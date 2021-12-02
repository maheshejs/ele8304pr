
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
      i_rs_data   : in T_RDATA_ARRAY;
      i_reg_id_ex : in E_REG_ID_EX;
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

  signal s_ex         : E_EX;
  signal s_reg_ex_me  : E_REG_EX_ME;
  signal s_shamt      : std_logic_vector(SHAMT_WIDTH-1 downto 0);
  signal s_src1       : std_logic_vector(XLEN-1 downto 0);
  signal s_src2       : std_logic_vector(XLEN-1 downto 0);
  signal s_alu_result : std_logic_vector(XLEN-1 downto 0);

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

  s_src1  <=  i_rs_data(0);
  s_src2  <=  i_reg_id_ex.immed when i_reg_id_ex.alu_type = '1' else
              i_rs_data(1);

  
  P_REG_ID_EX : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      s_reg_ex_me <=  (
                        alu_result  => s_alu_result,
                        dmem_write  => i_rs_data(1),
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

  s_ex.flush      <= '0';
  s_ex.stall      <= '0';
  s_ex.target     <= (others => '0');
  s_ex.transfert  <= i_reg_id_ex.jump or (i_reg_id_ex.branch and not or_reduce(s_alu_result));

  -- Outputs
  o_ex        <= s_ex;
  o_reg_ex_me <= s_reg_ex_me;

end architecture arch;
