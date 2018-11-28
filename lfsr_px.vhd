-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MU�OZ ARBOLEDA
-- 
-- Create Date:   23-Jul-2012 
-- Design name:   HPABC
-- Module name:   lfsr_px
-- Description:   This package defines types, subtypes and constants
-- Automatically generated using the vHPABCgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;
use work.woapack.all;

entity lfsr_px is
	port(reset     : in  std_logic;
	     clk       : in  std_logic;
		  start     : in  std_logic;
		  init      : in  std_logic_vector(7 downto 0);
		  lfsr_out  : out std_logic_vector(FP_WIDTH-1 downto 0);
		  ready     : out std_logic);
end lfsr_px;

architecture Behavioral of lfsr_px is
	constant taps : std_logic_vector(19 downto 0) := "10010000000000000000";

	function one_to_many_fb (DATA, TAPS :std_logic_vector) return std_logic_vector is
   	variable xor_taps  :std_logic;
      variable all_0s    :std_logic;
      variable feedback  :std_logic;
      variable result    :std_logic_vector (DATA'length-1 downto 0);
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

	process (clk,reset)
		variable exp    : std_logic_vector(EXP_WIDTH-1 downto 0);
		variable man    : std_logic_vector(FRAC_WIDTH-1 downto 0);
		variable lfsr_m : std_logic_vector(19 downto 0);
	begin
		if reset = '1' then
			lfsr_m := init&init&"0000";
			exp 	   := "10000000";
			man      := (others=>'0');
			lfsr_out <= MAX_VELOCI;
			ready  <= '0';
		elsif (rising_edge(clk)) then
			ready <= '0';
			if start = '1' then
				lfsr_m := one_to_many_fb(lfsr_m, taps);
				lfsr_out(FP_WIDTH-1) <= lfsr_m(19);
				lfsr_out(FP_WIDTH-2) <= lfsr_m(18);
				if lfsr_m(18) = '1' then
					lfsr_out(FP_WIDTH-3 downto FRAC_WIDTH+1) <= "000000";
					lfsr_out(FRAC_WIDTH downto 1) <= lfsr_m(17 downto 0);
				else
					lfsr_out(FP_WIDTH-3 downto FRAC_WIDTH+1) <= "111111";
					lfsr_out(FRAC_WIDTH downto 1) <= lfsr_m(17 downto 0);
				end if;
				ready 	<= '1';
			end if;
		end if;
	end process;

end Behavioral;
