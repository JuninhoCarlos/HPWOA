-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MUÑOZ ARBOLEDA
-- 
-- Create Date:   06-Oct-2012 
-- Design name:   HPSO
-- Module name:   psopack
-- Description:   This package defines types, subtypes and constants
-- Automatically generated using the vHPSOgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

package psopack is

constant NP : integer := 10;
constant ND : integer := 6;
constant numIter  : integer := 15000;

constant COEFF_C1 : std_logic_vector(FP_WIDTH-1 downto 0) := "010000000010000000000000000";
constant COEFF_C2 : std_logic_vector(FP_WIDTH-1 downto 0) := "010000000010000000000000000";

constant INITIAL_WEIGHT : std_logic_vector(FP_WIDTH-1 downto 0) := "001111110100110011001100110";
constant INERTIA_SLOPE : std_logic_vector(FP_WIDTH-1 downto 0) := "101110000100001110111011111";
constant INITIAL_VELOCI : std_logic_vector(FP_WIDTH-1 downto 0) := "010000001010000000000000000";
constant MAX_VELOCI : std_logic_vector(FP_WIDTH-1 downto 0) := "010000001100000000000000000";
constant MAX_POS : std_logic_vector(FP_WIDTH-1 downto 0) := "010000010000000000000000000";
constant MIN_FIT : std_logic_vector(FP_WIDTH-1 downto 0) := "001111000010001111010111000";

constant INV_NP : std_logic_vector(FP_WIDTH-1 downto 0) := "001111011100110011001100110";
constant INV_SL : std_logic_vector(FP_WIDTH-1 downto 0) := "001110111010011100110111111";
constant exploit : std_logic_vector(FP_WIDTH-1 downto 0) := "001110110000001100010010011";
constant explore : std_logic_vector(FP_WIDTH-1 downto 0) := "001111101100110011001100110";

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

end psopack;

