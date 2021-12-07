library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_rf_tb is
end;

architecture bench of riscv_rf_tb is

  constant K_CLK_PERIOD : time := 12.5 ns;

  signal s_rstn       : std_logic     := '1';
  signal s_clk        : std_logic     := '0';
  signal s_we         : std_logic     := '0';
  signal s_addr_w     : std_logic_vector(REG_WIDTH-1 downto 0)  := (others => '0');
  signal s_data_w     : std_logic_vector(XLEN-1 downto 0)       := (others => '0');
  signal s_addr_r     : T_RADDR_ARRAY := (others => (others => '0'));  
  signal s_data_r     : T_RDATA_ARRAY;  

begin

  s_clk   <= not s_clk after K_CLK_PERIOD/2;
  s_rstn  <= '0', '1' after K_CLK_PERIOD*10;

  X_RF : riscv_rf
  port map(
    i_clk     => s_clk,
    i_rstn    => s_rstn,
    i_we      => s_we,
    i_addr_w  => s_addr_w,
    i_data_w  => s_data_w,
    i_addr_ra => s_addr_r(0),
    o_data_ra => s_data_r(0),
    i_addr_rb => s_addr_r(1),
    o_data_rb => s_data_r(1)
  );

  stimulus: process
  begin
    wait until s_rstn = '1';

    --------------------------------------------------------------------------
    report "Write to all XLEN=32 registers";
    --------------------------------------------------------------------------
    for I in 0 to XLEN-1 loop
      s_we      <= '1';
      s_addr_w  <= std_logic_vector(to_unsigned(I, s_addr_w'length));
      s_data_w  <= std_logic_vector(to_unsigned(I+1, s_data_w'length));
      wait for K_CLK_PERIOD;
    end loop;
    s_we  <= '0';

    ---------------------------------------------------------------------------
    report "Read register pairs (0,1), (1,2), (3,3), (7, 4), (15,5) and (31,6)";
    ---------------------------------------------------------------------------
    for I in 0 to 5 loop
      s_addr_r(0) <= std_logic_vector(to_unsigned(2**I-1, s_addr_w'length));
      s_addr_r(1) <= std_logic_vector(to_unsigned(I+1, s_addr_w'length));
      wait for K_CLK_PERIOD;
    end loop; 

    --------------------------------------------------------------------------
    report "Read and Write register 7";
    --------------------------------------------------------------------------
    s_we  <= '1';
    s_data_w    <= std_logic_vector(to_unsigned(49, s_data_w'length));
    s_addr_w    <= std_logic_vector(to_unsigned(7, s_addr_w'length));
    s_addr_r(0) <= std_logic_vector(to_unsigned(7, s_addr_w'length));
    s_addr_r(1) <= std_logic_vector(to_unsigned(7, s_addr_w'length));
    wait for K_CLK_PERIOD;
    s_we  <= '0';

    wait;
  end process;

end;