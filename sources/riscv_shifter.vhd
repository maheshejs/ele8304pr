

-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_shifter.vhd
-- Author   
-- Lab      GRM - Polytechnique Montreal
-- Date     
-------------------------------------------------------------------------------
-- Brief    
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity riscv_shifter is
    port (
             i_src      : in  std_logic_vector(XLEN-1 downto 0);
             i_shamt    : in  std_logic_vector(SHAMT-1 downto 0);
             i_opcode   : in  std_logic_vector(ALUOP-1, downto 0);
             i_arith    : in  std_logic;   
             o_result   : out std_logic_vector(XLEN-1 downto 0);
);
end entity riscv_shifter;

architecture arch of riscv_shifter is
    signal src      : std_logic_vector(XLEN-1 downto 0); 
    signal shamt    : std_logic_vector(SHAMT-1 downto 0);
    signal opcode   : std_logic_vector(ALUOP-1 downto 0);
    signal arith    : std_logic;
    signal result   : std_logic_vector(XLEN-1 downto 0);
begin
    src     <= i_src;
    shamt   <= i_shamt;
    opcode  <= i_opcode;
    arith   <= i_arith;

    case opcode is  
        when ALUOP_SL =>
            result <= src(shamt downto 0) & '0';
        when ALUOP_SR =>
            result(XLEN downto XLEN-shamt) <= arith;
            result(XLEN-shamt-1 downto 0) <= src(shamt downto 0);
        when others =>
            result <= '0';
    end case;

    o_result <= result;
end architecture arch;
