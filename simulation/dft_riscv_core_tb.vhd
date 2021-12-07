library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.riscv_pkg.all;

entity riscv_core_tb is
end;

architecture bench of riscv_core_tb is
  component top is
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
        o_dmem_write  : out std_logic_vector(31 downto 0);
        -- DFT
        i_scan_en     : in std_logic;
        i_test_mode   : in std_logic;
        i_tdi         : in std_logic;
        o_tdo         : out std_logic
      );
  end component top;

  constant K_CLK_PERIOD : time := 12.5 ns;

  signal s_rstn       : std_logic := '1';
  signal s_clk        : std_logic := '0';
  signal s_imem_en    : std_logic;
  signal s_imem_we    : std_logic;
  signal s_imem_addr  : std_logic_vector(8 downto 0);
  signal s_imem_read  : std_logic_vector(31 downto 0);
  signal s_imem_write : std_logic_vector(31 downto 0) ;
  signal s_dmem_en    : std_logic;
  signal s_dmem_we    : std_logic;
  signal s_dmem_addr  : std_logic_vector(8 downto 0);
  signal s_dmem_read  : std_logic_vector(31 downto 0);
  signal s_dmem_write : std_logic_vector(31 downto 0);

begin

  s_clk <= not s_clk after K_CLK_PERIOD/2;

  X_TOP : top
  port map (
    i_rstn        => s_rstn,
    i_clk         => s_clk,
    o_imem_en     => s_imem_en,
    o_imem_addr   => s_imem_addr,
    i_imem_read   => s_imem_read,
    o_dmem_en     => s_dmem_en,
    o_dmem_we     => s_dmem_we,
    o_dmem_addr   => s_dmem_addr,
    i_dmem_read   => s_dmem_read,
    o_dmem_write  => s_dmem_write,
    -- DFT
    i_scan_en     => '0',
    i_test_mode   => '0',
    i_tdi         => '0',
    o_tdo         => open
  );

  X_DPM : dpm 
  generic map (
    WIDTH         => DPM_WIDTH,
    DEPTH         => DPM_DEPTH,
    RESET         => 16#00000000#,
    INIT          => "../asm/riscv_fibo.mem"
  )
  port map ( 
    i_a_clk       => s_clk,
    i_a_rstn      => s_rstn,
    i_a_en        => s_imem_en,
    i_a_we        => s_imem_we,
    i_a_addr      => s_imem_addr,
    i_a_write     => s_imem_write,
    o_a_read      => s_imem_read,
    i_b_clk       => s_clk,
    i_b_rstn      => s_rstn,
    i_b_en        => s_dmem_en,
    i_b_we        => s_dmem_we,
    i_b_addr      => s_dmem_addr,
    i_b_write     => s_dmem_write,
    o_b_read      => s_dmem_read 
  );

  s_imem_we     <= '0';
  s_imem_write  <= (others => '0');

  stimulus: process
  begin
  
    -- Put initialisation code here

    s_rstn <= '0';
    wait for 10 * K_CLK_PERIOD;
    s_rstn <= '1';

    -- Put test bench stimulus code here

    wait;
  end process;

end;

-----------------------------------------------------------------------------                            
-- CONFIGURATIONS                                                                                        
-----------------------------------------------------------------------------                            
configuration c_dft of riscv_core_tb is
  for bench
    for X_TOP : top
      use entity work.top(dft);
    end for;
  end for;
end configuration;
configuration c_rtl of riscv_core_tb is
  for bench
    for X_TOP : top
      use entity work.top(rtl);
    end for;
  end for;
end configuration;