library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
library work;
use work.riscv_pkg.all;

entity riscv_alu is
end;

architecture bench of riscv_alu is

  component riscv_alu is
  port (
     i_arith  : in  std_logic;
     i_sign   : in  std_logic;
     i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
     i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
     i_src1   : in  std_logic_vector(XLEN-1 downto 0);
     i_src2   : in  std_logic_vector(XLEN-1 downto 0);
     o_res    : out std_logic_vector(XLEN-1 downto 0)
  );
  end component riscv_alu;

  constant N : integer := 32;

	signal arith  : std_logic;
	signal sign   : std_logic;
	signal opcode : std_logic_vector(ALUOP_WIDTH-1 downto 0);
	signal shamt  : std_logic_vector(SHAMT_WIDTH-1 downto 0);
	signal src1   : std_logic_vector(XLEN-1 downto 0);
	signal src2   : std_logic_vector(XLEN-1 downto 0);
  signal s_res  : std_logic_vector(XLEN-1 downto 0);

  signal clk: std_logic;
  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;


begin

  uut: riscv_alu port map (i_arith  => arith,
                           i_sign   => sign,
                           i_opcode => opcode,
                           i_shamt  => shamt,
                           i_src1   => src1,
                           i_src2   => src2,
                           o_res    => s_res
                          );

  stimulus: process
  begin
  
    -- Signed addition
    opcode <= ALUOP_ADD;
    arith <= '0';
    sign <= '1';
 
    wait for clock_period * 2;
    src1 <= X"00004004";
    src2 <= X"00002B76";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00006B7A" report "ERROR ADDING TWO SIGNED POSITIVE NUMBERS" severity error;

    wait for clock_period * 2;
    src1 <= X"FFFF1612";
    src2 <= X"0000BDF1";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFD403" report "ERROR ADDING ONE SIGNED NEGATIVE WITH ONE SIGNED POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"0008FB76";
    src2 <= X"DCE9B7AB";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"DCF2B321" report "ERROR ADDING ONE SIGNED POSITIVE WITH ONE SIGNED NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"CDEF4568";
    src2 <= X"FF40B367";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"DE542EF8" report "ERROR ADDING ONE SIGNED NEGATIVE WITH ONE SIGNED NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"758D14EE";
    src2 <= X"6111422D";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"D69E571B" report "ERROR ADDING TWO SIGNED POSITIVES WITH POSITIVE OVERFLOW" severity error;

    wait for clock_period * 2;
    src1 <= X"8AD97B6F";
    src2 <= X"88CA6C00";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"13A3E76F" report "ERROR ADDING TWO SIGNED NEGATIVES WITH NEGATIVE OVERFLOW" severity error;

    -- Unsigned addition
    sign <= '0';

    wait for clock_period * 2;
    src1 <= X"DA23530F";
    src2 <= X"00089354";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"DA2BE663" report "ERROR ADDING TWO UNSIGNED" severity error;

    wait for clock_period * 2;
    src1 <= X"EA23530F";
    src2 <= X"CCCCCCCC";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"B6F01FDB" report "ERROR ADDING TWO UNSIGNED WITH OVERFLOW" severity error;

    -- Signed subtraction
    sign <= '1';
    arith <= '1';
 
    wait for clock_period * 2;
    src1 <= X"00004004";
    src2 <= X"00002B76";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"0000148E" report "ERROR SUBTRACTING TWO SIGNED POSITIVE NUMBERS" severity error;

    wait for clock_period * 2;
    src1 <= X"FFFF1612";
    src2 <= X"0000BDF1";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFE5821" report "ERROR SUBTRACTING ONE SIGNED NEGATIVE WITH ONE SIGNED POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"0008FB76";
    src2 <= X"DCE9B7AB";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"231F43CB" report "ERROR SUBTRACTING ONE SIGNED POSITIVE WITH ONE SIGNED NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"CDEF4568";
    src2 <= X"FF40B367";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"CEAE9201" report "ERROR SUBTRACTING ONE SIGNED NEGATIVE WITH ONE SIGNED NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"77359400";
    src2 <= X"88CA6C00";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"EE6B2800" report "ERROR SUBTRACTING ONE SIGNED POSITIVE WITH ONE SIGNED NEGATIVE WITH POSITIVE OVERFLOW" severity error;

    wait for clock_period * 2;
    src1 <= X"8BC55C80";
    src2 <= X"7C6001AA";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"0F65AD6" report "ERROR SUBTRACTING ONE SIGNED NEGATIVE WITH ONE SIGNED POSITIVE WITH NEGATIVE OVERFLOW" severity error;

    -- Unsigned subtraction
    sign <= '0';

    wait for clock_period * 2;
    src1 <= X"0515C00B";
    src2 <= X"0004E65A";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"0510D9B1" report "ERROR SUBTRACTING TWO UNSIGNED" severity error;

    wait for clock_period * 2;
    src1 <= X"00000018";
    src2 <= X"00000184";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFE94" report "ERROR SUBSTRACTING TWO UNSIGNED WITH NEGATIVE OVERFLOW" severity error;

    -- Set less than (signed addition)
    opcode <= ALUOP_SLT;
    arith <= '0';
    sign <= '1';
 
    wait for clock_period * 2;
    src1 <= X"00004004";
    src2 <= X"00002B76";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED ADDING TWO POSITIVE SIGNED TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"FFFF1612";
    src2 <= X"0000BDF1";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED ADDING ONE SIGNED NEGATIVE WITH ONE SIGNED POSITIVE TO BE NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"0008FB76";
    src2 <= X"DCE9B7AB";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED ADDING ONE SIGNED POSITIVE WITH ONE SIGNED NEGATIVE TO BE NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"CDEF4568";
    src2 <= X"FF40B367";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED ADDING ONE SIGNED NEGATIVE WITH ONE SIGNED NEGATIVE TO BE NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"758D14EE";
    src2 <= X"6111422D";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED ADDING TWO SIGNED POSITIVES WITH POSITIVE OVERFLOW TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"8AD97B6F";
    src2 <= X"88CA6C00";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED ADDING TWO SIGNED NEGATIVES WITH NEGATIVE OVERFLOW TO BE NEGATIVE" severity error;

    -- Set less than (unsigned addition)
    sign <= '0';

    wait for clock_period * 2;
    src1 <= X"DA23530F";
    src2 <= X"00089354";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED ADDING TWO UNSIGNED TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"EA23530F";
    src2 <= X"CCCCCCCC";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED ADDING TWO UNSIGNED WITH OVERFLOW TO BE POSITIVE" severity error;

    -- Set less than (signed substraction)
    sign <= '1';
    arith <= '1';
 
    wait for clock_period * 2;
    src1 <= X"00004004";
    src2 <= X"00002B76";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED SUBTRACTING TWO SIGNED POSITIVE NUMBERS TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"FFFF1612";
    src2 <= X"0000BDF1";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED SUBTRACTING ONE SIGNED NEGATIVE WITH ONE SIGNED POSITIVE TO BE NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"0008FB76";
    src2 <= X"DCE9B7AB";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED SUBTRACTING ONE SIGNED POSITIVE WITH ONE SIGNED NEGATIVE TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"CDEF4568";
    src2 <= X"FF40B367";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED SUBTRACTING ONE SIGNED NEGATIVE WITH ONE SIGNED NEGATIVE TO BE NEGATIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"77359400";
    src2 <= X"88CA6C00";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED SUBTRACTING ONE SIGNED POSITIVE WITH ONE SIGNED NEGATIVE WITH POSITIVE OVERFLOW TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"8BC55C80";
    src2 <= X"7C6001AA";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED SUBTRACTING ONE SIGNED NEGATIVE WITH ONE SIGNED POSITIVE WITH NEGATIVE OVERFLOW TO BE NEGATIVE" severity error;

    -- Unsigned subtraction
    sign <= '0';

    wait for clock_period * 2;
    src1 <= X"0515C00B";
    src2 <= X"0004E65A";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"00000000" report "ERROR EXPECTED SUBTRACTING TWO UNSIGNED TO BE POSITIVE" severity error;

    wait for clock_period * 2;
    src1 <= X"00000018";
    src2 <= X"00000184";
    wait for clock_period;
    assert s_res(N-1 downto 0) = X"FFFFFFFF" report "ERROR EXPECTED SUBSTRACTING TWO UNSIGNED WITH NEGATIVE OVERFLOW TO BE NEGATIVE" severity error;


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
