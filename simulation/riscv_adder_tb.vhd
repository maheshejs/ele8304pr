library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

architecture bench of riscv_adder_tb is

  component riscv_adder
    generic (N : positive := 32);
    port (
      i_a    : in  std_logic_vector(N-1 downto 0);
      i_b    : in  std_logic_vector(N-1 downto 0);
      i_sign : in  std_logic;
      i_sub  : in  std_logic;
      o_sum  : out std_logic_vector(N downto 0)
    );
  end component;
  constant N : integer := 32;

  signal i_a: std_logic_vector(N-1 downto 0);
  signal i_b: std_logic_vector(N-1 downto 0);
  signal i_sign: std_logic;
  signal i_sub: std_logic;
  signal o_sum: std_logic_vector(N downto 0) ;
  signal clk: std_logic;
  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: riscv_adder port map    ( i_a    => i_a,
                                 i_b    => i_b,
                                 i_sign => i_sign,
                                 i_sub  => i_sub,
                                 o_sum  => o_sum );

  stimulus: process
  begin
  
    -- Put initialisation code here
    wait for clock_period * 2;
    i_sub <= '0';
    i_a <= X"00004004";
    i_b <= X"00002B76";
    --std_logic_vector(signed(i_a)+signed(i_b)) 
    wait for clock_period;
    assert o_sum(N-1 downto 0) = X"00006B7A" report "ERROR ADDING TWO NUMBERS" severity error;

    wait for clock_period * 2;
    i_sub <= '1';
    i_a <= X"00004004";
    i_b <= X"00002B76";
    wait for clock_period;
    assert o_sum(N-1 downto 0) = X"0000148E" report "ERROR SUB TWO NUMBERS" severity error;

    wait for clock_period * 2;
    i_sub <= '0';
    i_a <= X"C0104004";
    i_b <= X"A2002B76";
    wait for clock_period;
    assert o_sum(N-1 downto 0) = X"62106B7A" report "ERROR ADDING TWO BIG NUMBERS" severity error;
    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
