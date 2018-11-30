library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

package woapack is

--NP -> Número de baleias
constant NP : integer := 10;
--ND -> Número de dimensoes do problema
constant ND : integer := 6;

constant INITIAL_A_MINUSCULO : std_logic_vector(FP_WIDTH-1 downto 0) := s_two;
constant A_SLOPE	: std_logic_vector(FP_WIDTH-1 downto 0) 				:= "101110110000001100010010011";

constant numIter  : integer := 1000;

constant ADD: std_logic := '0';
constant SUBTRACTION: std_logic := '1';

-- Usado pq o gerador de numeros aleatorios precisa
constant MAX_VELOCI : std_logic_vector(FP_WIDTH-1 downto 0) := "010000001100000000000000000";

type array_rand is array (1 to NP) of std_logic_vector(7 downto 0);
constant init_p : array_rand := (	1 => "00111010",
												2 => "00110001",
												3 => "11011011",
												4 => "11010000",
												5 => "01101110",
												6 => "01101110",
												7 => "10111100",
												8 => "00101010",
												9 => "10110000",
												10 => "00101111");													


constant init_random: std_logic_vector(7 downto 0) := "11000000";
end woapack;