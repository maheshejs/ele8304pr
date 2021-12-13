library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_pc_tb is
end;

architecture bench of riscv_pc_tb is

  constant K_CLK_PERIOD : time := 12.5 ns;

  signal s_rstn       : std_logic := '1';
  signal s_clk        : std_logic := '0';
  signal s_stall      : std_logic := '0';
  signal s_transfert  : std_logic := '0';
  signal s_target     : std_logic_vector(XLEN-1 downto 0);
  signal s_pc         : std_logic_vector(XLEN-1 downto 0);

begin

  s_clk   <= not s_clk after K_CLK_PERIOD/2;
  s_rstn  <= '0', '1' after K_CLK_PERIOD*10;

  X_PC : riscv_pc
  generic map(
    RESET_VECTOR  => 16#00000000#
  )
  port map (
    i_clk         => s_clk,
    i_rstn        => s_rstn,
    i_stall       => s_stall,
    i_transfert   => s_transfert,
    i_target      => s_target,
    o_pc          => s_pc
  );

  stimulus: process
  begin
    wait until s_rstn = '1';

    --------------------------------------------------------------------------
    report "Fetch 4 PC+4";
    --------------------------------------------------------------------------
    s_stall     <= '0';
    s_transfert <= '0';
    s_target    <= (others => '0'); 
    for I in 0 to 4-1 loop
      wait for K_CLK_PERIOD;
    end loop;

    --------------------------------------------------------------------------
    report "Fetch 4 different PC_TARGET";
    --------------------------------------------------------------------------
    s_transfert <= '1';
    for I in 0 to 4-1 loop
      s_target  <= std_logic_vector(to_unsigned(2**I+7, s_target'length));
      wait for K_CLK_PERIOD;
    end loop; 

    --------------------------------------------------------------------------
    report "Stall for 4 cycles with TRANSFERT 0N then OFF";
    --------------------------------------------------------------------------
    s_stall <= '1';
    for I in 0 to 4-1 loop
      if (I = 2) then
        s_transfert <= '0';
      end if;
      wait for K_CLK_PERIOD;
    end loop;

    --------------------------------------------------------------------------
    report "Stall released for 1 cycle";
    --------------------------------------------------------------------------
    s_stall <= '0';
    wait for K_CLK_PERIOD;
    s_stall <= '1';

    wait;
  end process;

end;