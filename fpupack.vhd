-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MUÑOZ ARBOLEDA
-- 
-- Create Date:   06-Oct-2012 
-- Design name:   HPSO
-- Module name:   fpupack
-- Description:   This package defines types, subtypes and constants
-- Automatically generated using the vHPSOgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package fpupack is

constant FRAC_WIDTH : integer := 18;
constant EXP_WIDTH : integer := 8;
constant FP_WIDTH : integer:= FRAC_WIDTH+EXP_WIDTH+1;

constant bias : std_logic_vector(EXP_WIDTH-1 downto 0) := "01111111";
constant int_bias : integer := 127;
constant int_alin : integer := 255;
constant EXP_DF : std_logic_vector(EXP_WIDTH-1 downto 0) := "10000010";
constant bias_MAX : std_logic_vector(EXP_WIDTH-1 downto 0) := "10000111";
constant EXP_ONE: std_logic_vector(EXP_WIDTH-1 downto 0):= (others => '1');

constant s_one : std_logic_vector(FP_WIDTH-1 downto 0) := "001111111000000000000000000";
constant s_ten : std_logic_vector(FP_WIDTH-1 downto 0) := "010000010010000000000000000";
constant s_twn : std_logic_vector(FP_WIDTH-1 downto 0) := "010000011010000000000000000";
constant s_hundred : std_logic_vector(FP_WIDTH-1 downto 0) := "010000101100100000000000000";
constant s_pi2 : std_logic_vector(FP_WIDTH-1 downto 0) := "001111111100100100001111110";
constant s_pi : std_logic_vector(FP_WIDTH-1 downto 0) := "010000000100100100001111110";
constant s_3pi2 : std_logic_vector(FP_WIDTH-1 downto 0) := "010000001001011011001011111";
constant s_2pi : std_logic_vector(FP_WIDTH-1 downto 0) := "010000001100100100001111110";

constant MAX_ITER_CORDIC : std_logic_vector(4 downto 0):= "01111";
constant MAX_POLY_MACKLR : std_logic_vector(3 downto 0):= "0011";

constant OneM: std_logic_vector(FRAC_WIDTH downto 0) := "1000000000000000000";
constant Zero: std_logic_vector(FP_WIDTH-1 downto 0) := (others => '0');
constant Inf: std_logic_vector(FP_WIDTH-1 downto 0) := "011111111000000000000000000";
constant NaN: std_logic_vector(FP_WIDTH-1 downto 0) := "011111111100000000000000000";
constant TSed: POSITIVE := 15;
constant Niter: POSITIVE := 3;

end fpupack;

package body fpupack is
end fpupack;
