
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_wb.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    Write back
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_wb is
    port (
      i_dmem_read : in std_logic_vector(DPM_WIDTH-1 downto 0);
      i_reg_me_wb : in E_REG_ME_WB;
      --
      o_wb        : out E_WB
    );
end entity riscv_wb;

architecture arch of riscv_wb is

begin
  -- Outputs
  o_wb.rd_addr  <=  i_reg_me_wb.rd_addr;
  o_wb.rd_data  <=  i_dmem_read when i_reg_me_wb.dmem_re = '1' else
                    i_reg_me_wb.alu_result;
  o_wb.rd_we    <=  i_reg_me_wb.rd_we;

end architecture arch;
