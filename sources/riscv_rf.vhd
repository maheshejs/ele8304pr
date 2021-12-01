
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_rf.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_rf is
    port (
      i_clk     : in  std_logic;
      i_rstn    : in  std_logic;
      i_we      : in  std_logic;
      i_addr_ra : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o_data_ra : out std_logic_vector(XLEN-1 downto 0);
      i_addr_rb : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o_data_rb : out std_logic_vector(XLEN-1 downto 0);
      i_addr_w  : in  std_logic_vector(REG_WIDTH-1 downto 0);
      i_data_w  : in  std_logic_vector(XLEN-1 downto 0)
    );
end entity riscv_rf;

architecture arch of riscv_rf is
  type T_FILE is array(0 to 2**REG_WIDTH-1) of std_logic_vector(XLEN-1 downto 0);
  constant K_ADDR_ZERO  : std_logic_vector(REG_WIDTH-1 downto  0) := (others => '0');
  signal s_file         : T_FILE := (others => (others => '0'));
  signal s_addr_r       : T_RADDR_ARRAY;  
  signal s_data_r       : T_RDATA_ARRAY;  

begin

  s_addr_r(0) <= i_addr_ra;
  s_addr_r(1) <= i_addr_rb;

  P_REGISTER_FILE : process(i_clk, i_rstn)
  begin
    if (rising_edge(i_clk)) then
      -- write
      if (i_we = '1' and i_addr_w /= K_ADDR_ZERO) then
        s_file(to_integer(unsigned(i_addr_w))) <= i_data_w;
      end if;
      
      -- read
      for I in 0 to 1 loop
        if (s_addr_r(I) = i_addr_w) then
          s_data_r(I) <= i_data_w;
        else
          s_data_r(I) <= s_file(to_integer(unsigned(s_addr_r(I))));
        end if;
      end loop;
    end if;
    
    -- Asynchronous reset
    if (i_rstn = '0') then
      s_file    <= (others => (others => '0'));
      s_data_r  <= (others => (others => '0'));
    end if;
  end process;

  -- Outputs
  o_data_ra <= s_data_r(0);
  o_data_rb <= s_data_r(1);
end architecture arch;
