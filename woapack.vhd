library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

package woapack is

--NP -> Número de baleias
constant NP : integer := 10;
--ND -> Número de dimensoes do problema
constant ND : integer := 6;

-- Usado pq o gerador de numeros aleatorios precisa
constant MAX_VELOCI : std_logic_vector(FP_WIDTH-1 downto 0) := "010000001100000000000000000";

constant init_p1 : std_logic_vector(7 downto 0):= "00111010";
constant init_p2 : std_logic_vector(7 downto 0):= "00110001";
constant init_p3 : std_logic_vector(7 downto 0):= "11011011";
constant init_p4 : std_logic_vector(7 downto 0):= "11010000";
constant init_p5 : std_logic_vector(7 downto 0):= "01101110";
constant init_p6 : std_logic_vector(7 downto 0):= "11101001";
constant init_p7 : std_logic_vector(7 downto 0):= "10111100";
constant init_p8 : std_logic_vector(7 downto 0):= "00101010";
constant init_p9 : std_logic_vector(7 downto 0):= "10110000";
constant init_p10 : std_logic_vector(7 downto 0):= "00101111";

constant init_random: std_logic_vector(7 downto 0) := "11000000";
end woapack;