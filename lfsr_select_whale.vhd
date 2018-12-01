----------------------------------------------------------------------------------
-- Company: 		 LAICO - UnB
-- Engineer: 		 Francisco Carlos Silva JUnior
-- 
-- Create Date:    01/12/2018
-- Design Name: 	 [0,9.99] random number using LFSR
-- Module Name:    lfsr_fixtofloat - Behavioral 
-- Project Name:   WOA
-- Target Devices: 
-- Tool versions: 
-- Description:    generates random numbers [0,9.99] using the LFSR 16 bits and converts from 
-- 					 fixed point to floating point.

--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;
use work.woapack.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lfsr_select_whale is
	port(reset     : in  std_logic;
	     clk       : in  std_logic;
		  start     : in  std_logic;
		  init      : in  std_logic_vector(7 downto 0);	
		  lfsr_out  : out std_logic_vector(NUM_BITS-1 downto 0);
		  ready     : out std_logic
		  );
end lfsr_select_whale;

architecture Behavioral of lfsr_select_whale is

signal my_out : std_logic_vector(NUM_BITS-1 downto 0):=(others=>'0');

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


begin

	process (reset,clk)
		variable lfsr : std_logic_vector(19 downto 0):=init&init&"0000";
		variable aux  : std_logic_vector(3 downto 0);
	begin
		if reset = '1' then
			lfsr    := init&init&"0000";
			my_out <= (others => '0');
			ready   <= '0';
		elsif rising_edge(clk) then
		   ready <= '0';
			if start = '1' then
				lfsr    := one_to_many_fb(lfsr, taps);
				
				aux := lfsr(NUM_BITS-1 downto 0);
				if aux > NP-1 then
					aux(NUM_BITS-1) := '0'; --Para não gerar números maior q a qntde de baleias
				end if;
				
				my_out <= aux;				
				ready   <= '1';
			end if;
		end if;
	end process;
	
	lfsr_out <= my_out;  -- gambiarra para sortear as baleias, conversar com o professor depois

	
end Behavioral;

