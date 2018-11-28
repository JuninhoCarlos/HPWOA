----------------------------------------------------------------------------------
-- Company: 		 GRACO - UnB
-- Engineer: 		 Daniel Mauricio Muñoz
-- 
-- Create Date:    20:39:00 02/18/2010 
-- Design Name: 	 U[0,2] random number using LFSR
-- Module Name:    lfsr_fixtofloat - Behavioral 
-- Project Name:   PSO
-- Target Devices: 
-- Tool versions: 
-- Description:    generates U[0,2] using the LFSR 16 bits and converts from 
-- 					 fixed point to floating point.
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lfsr_fixtofloat_20bits is
	port(reset     : in  std_logic;
	     clk       : in  std_logic;
		  start     : in  std_logic;
		  init      : in  std_logic_vector(7 downto 0);	
		  lfsr_out  : out std_logic_vector(FP_WIDTH-1 downto 0);
		  ready     : out std_logic);
end lfsr_fixtofloat_20bits;

architecture Behavioral of lfsr_fixtofloat_20bits is

--signal exp_man : std_logic_vector(19 downto 0) := (others => '0');
signal exp_man : std_logic_vector(22 downto 0) := (others => '0');
constant taps : std_logic_vector(19 downto 0) := "10010000000000000000";

	function one_to_many_fb (DATA, TAPS :std_logic_vector) return std_logic_vector is
   	variable xor_taps  :std_logic;
      variable all_0s    :std_logic;
      variable feedback  :std_logic;
      variable result    :std_logic_vector(DATA'length-1 downto 0);
	begin  
		-- Validate if lfsr = to zero (Prohibit Value)
		 if (DATA(DATA'length-2 downto 0) = 0) then
			  all_0s := '1';
		 else
			  all_0s := '0';
		 end if;  
		 feedback := DATA(DATA'length-1) xor all_0s;  
		-- XOR the taps with the feedback
		 result(0) := feedback;
		 for idx in 0 to (TAPS'length-2) loop
			  if (TAPS(idx) = '1') then
					result(idx+1) := feedback xor DATA(idx);
			  else
					result(idx+1) := DATA(idx);
			  end if;
		 end loop;          
		 return result; 
	end function;

-- U[0 to 1]:
	function fixtofloat(input: std_logic_vector) return std_logic_vector is	
		variable exp 	 : std_logic_vector(3 downto 0) := "1110";
		variable man 	 : std_logic_vector(18 downto 0) := (others => '0');
		variable idx 	 : integer range 0 to 19 := 0;
		variable output : std_logic_vector(19+4-1 downto 0);
	begin
		man := (others=>'0');
		idx := 0;
		if input(19) = '1' then
			exp := "1110"; -- numeros entre [0,1]
			man(18 downto 0) := input(18 downto 0);
			idx := 0;
		else
			for i in 18 downto 0 loop
				exp := exp - '1';
				if input(i) = '1' then
					idx := i;
					exit;
				else
					idx:=1;
				end if;
			end loop;
			man(18 downto 19-idx) := input(idx-1 downto 0);
		end if;	
		output(22 downto 19) := exp; 
		output(18 downto 0)  := man;
		return output;
	end function;
	
begin

	process (reset,clk)
		variable lfsr : std_logic_vector(19 downto 0):=init&init&"0000";
	begin
		if reset = '1' then
			lfsr    := init&init&"0000";
			exp_man <= (others => '0');
			ready   <= '0';
		elsif rising_edge(clk) then
		   ready <= '0';
			if start = '1' then
				lfsr    := one_to_many_fb(lfsr, taps);
				exp_man <= fixtofloat(lfsr);
				ready   <= '1';
			end if;
		end if;
	end process;
	
	lfsr_out(FP_WIDTH-1) <= exp_man(0);  -- revisar si genera numeros entre [-1,1]
	lfsr_out(FP_WIDTH-2 downto FRAC_WIDTH+4) <= "0111";
	lfsr_out(FRAC_WIDTH+3 downto 0) <= exp_man(22 downto 1);
--	lfsr_out(FRAC_WIDTH+3 downto 4) <= exp_man;
--	lfsr_out(3 downto 0) <= (others => '0');
	
end Behavioral;

