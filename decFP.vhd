-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MUÑOZ ARBOLEDA
-- 
-- Create Date:   19-Aug-2012 
-- Design name:   decFP 
-- Module name:   decFP - behavioral
-- Description:   capture decimal part in floating-point
-- Automatically generated using the vFPUgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

entity decFP is
	port (reset     :  in std_logic;
		 clk        :  in std_logic;
		 start      :  in std_logic;
		 Xin        :  in std_logic_vector(FP_WIDTH-1 downto 0);
		 intX       : out std_logic_vector(EXP_WIDTH-1 downto 0);
		 decX       : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready      : out std_logic);
end decFP;

architecture Behavioral of decFP is

procedure CalcInt(signal ShiftExp: in integer range 0 to EXP_WIDTH; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0);signal result : out STD_LOGIC_VECTOR(EXP_WIDTH-1 downto 0)) is
begin
	result <= (others=>'0');
	if ShiftExp < EXP_WIDTH then
		case (ShiftExp) is
			when 1 =>
				 result(1 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-1);
			when 2 =>
				 result(2 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-2);
			when 3 =>
				 result(3 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-3);
			when 4 =>
				 result(4 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-4);
			when 5 =>
				 result(5 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-5);
			when 6 =>
				 result(6 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-6);
			when 7 =>
				 result(7 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-7);
			when others =>
				 result(0) <= '1'; -- quando ShiftExp=0
		end case;
	else
		result(EXP_WIDTH-1 downto 0) <= (others=>'1');
	end if;
end CalcInt;

procedure CountBits(signal ShiftExp: in integer range 0 to EXP_WIDTH; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0);variable bits : out integer range 0 to FRAC_WIDTH-1; variable zeros: out std_logic_vector(EXP_WIDTH-1 downto 0)) is
variable b : integer range 0 to FRAC_WIDTH-1 := 0;
variable z : std_logic_vector(EXP_WIDTH-1 downto 0) := (others=>'0');
begin
	b := 0;
	z := (others=>'0');
	for i in FRAC_WIDTH-1 downto 1 loop --Mnt_aux'range loop
		if b < ShiftExp then
			b := b + 1;
		else
			case CpiaMnts(i) is
				when '0' => b := b + 1; z := z+'1';
				when others => b := b + 1; z := z+'1'; exit;
			end case;
		end if;
	end loop;
	bits := b;
	zeros := z;
end CountBits;

procedure ShiftR(variable bits: in integer range 0 to FRAC_WIDTH-1; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0); variable result: out std_logic_vector(FRAC_WIDTH-1 downto 0)) is
begin
	case (bits) is
		when 1 =>
			 result(FRAC_WIDTH-1 downto 1) := CpiaMnts(FRAC_WIDTH-1-1 downto 0);
		when 2 =>
			 result(FRAC_WIDTH-1 downto 2) := CpiaMnts(FRAC_WIDTH-1-2 downto 0);
		when 3 =>
			 result(FRAC_WIDTH-1 downto 3) := CpiaMnts(FRAC_WIDTH-1-3 downto 0);
		when 4 =>
			 result(FRAC_WIDTH-1 downto 4) := CpiaMnts(FRAC_WIDTH-1-4 downto 0);
		when 5 =>
			 result(FRAC_WIDTH-1 downto 5) := CpiaMnts(FRAC_WIDTH-1-5 downto 0);
		when 6 =>
			 result(FRAC_WIDTH-1 downto 6) := CpiaMnts(FRAC_WIDTH-1-6 downto 0);
		when 7 =>
			 result(FRAC_WIDTH-1 downto 7) := CpiaMnts(FRAC_WIDTH-1-7 downto 0);
		when 8 =>
			 result(FRAC_WIDTH-1 downto 8) := CpiaMnts(FRAC_WIDTH-1-8 downto 0);
		when 9 =>
			 result(FRAC_WIDTH-1 downto 9) := CpiaMnts(FRAC_WIDTH-1-9 downto 0);
		when 10 =>
			 result(FRAC_WIDTH-1 downto 10) := CpiaMnts(FRAC_WIDTH-1-10 downto 0);
		when 11 =>
			 result(FRAC_WIDTH-1 downto 11) := CpiaMnts(FRAC_WIDTH-1-11 downto 0);
		when 12 =>
			 result(FRAC_WIDTH-1 downto 12) := CpiaMnts(FRAC_WIDTH-1-12 downto 0);
		when 13 =>
			 result(FRAC_WIDTH-1 downto 13) := CpiaMnts(FRAC_WIDTH-1-13 downto 0);
		when 14 =>
			 result(FRAC_WIDTH-1 downto 14) := CpiaMnts(FRAC_WIDTH-1-14 downto 0);
		when 15 =>
			 result(FRAC_WIDTH-1 downto 15) := CpiaMnts(FRAC_WIDTH-1-15 downto 0);
		when 16 =>
			 result(FRAC_WIDTH-1 downto 16) := CpiaMnts(FRAC_WIDTH-1-16 downto 0);
		when 17 =>
			 result(FRAC_WIDTH-1) := CpiaMnts(0);
		when others =>
			 result := CpiaMnts; -- nunca acontece que bits=0
	end case;
end ShiftR;

signal MntXin : std_logic_vector(FRAC_WIDTH-1 downto 0) := (others=>'0');
signal shiftExp : integer range 0 to EXP_WIDTH := 0;
type   t_state is (waiting,compute,output);
signal state : t_state;

begin

	MntXin <= Xin(FRAC_WIDTH-1 downto 0);

	process(reset,clk,start)
		variable zeros	    : std_logic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
		variable Mnt_aux   : std_logic_vector(FRAC_WIDTH-1 downto 0):= (others => '0');
		variable bits      : integer range 0 to FRAC_WIDTH-1 := 0;
	begin
		if reset='1' then
			intX     <= (others => '0');
			decX  	<= (others => '0');
			ready 	<= '0';
			shiftExp <= 0;
			zeros 	:= (others => '0');
			Mnt_aux  := (others => '0');
			bits     := 0;
			state <= waiting;
		elsif rising_edge(clk) then
			case state is
				when waiting =>
					if start = '1' then
						if Xin(FP_WIDTH-2 downto FRAC_WIDTH) < bias then
							intX <= (others=>'0');
							decX <= Xin;
							ready <= '0';
							state <= output;
						elsif Xin(FP_WIDTH-2 downto FRAC_WIDTH) > bias_MAX then -- if Xin(FP_WIDTH-2 downto FRAC_WIDTH) - bias > "00010001" --(FRAC_WIDTH em binario)
							intX <= (others=>'1');
							decX <= Zero;
							ready <= '0';
							state <= output;
						else
							shiftExp <= conv_integer(Xin(FP_WIDTH-2 downto FRAC_WIDTH) - bias);
							intX <= (others => '0');
							Mnt_aux := (others => '0');
							zeros := (others => '0');
							ready <= '0';
							state <= compute;
						end if;
					else
						ready <= '0';
						state <= waiting;
					end if;

				when compute =>
					CalcInt(shiftExp,MntXin,IntX);
					CountBits(shiftExp,MntXin,bits,zeros);
					if zeros="00000000" then
						Mnt_aux(FRAC_WIDTH-1 downto 0):= (others => '0');
						decX(FP_WIDTH-2 downto FRAC_WIDTH) <= (others => '0');
					else
						decX(FP_WIDTH-2 downto FRAC_WIDTH) <= bias - zeros;
						ShiftR(bits,MntXin,Mnt_aux);
					end if;
					decX(FP_WIDTH-1) <= Xin(FP_WIDTH-1);
					decX(FRAC_WIDTH-1 downto 0) <= Mnt_aux;
					ready <= '1';
					state <= waiting;
				
				when output =>
					ready <= '1';
					state <= waiting;

				when others => state <= waiting;
			end case;
		end if;
	end process;
end Behavioral;

----------------------------------------------------------------------------------
---- Company: 
---- Engineer:
----
---- Create Date:    20:07:16 04/20/09
---- Design Name:    
---- Module Name:    decFP - Behavioral
---- Project Name:   
---- Target Device:  
---- Tool versions:  
---- Description:
----
---- Dependencies:
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
----------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use work.fpupack.all;
--
------ Uncomment the following library declaration if instantiating
------ any Xilinx primitives in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
--
--entity decFP is
--	port(reset : in  std_logic;
--		  clk   : in  std_logic;
--		  start : in  std_logic;
--		  Xin	  : in  std_logic_vector(FP_WIDTH-1 downto 0);
--		  intX  : out std_logic_vector(EXP_WIDTH-1 downto 0);
--		  decX  : out std_logic_vector(FP_WIDTH-1 downto 0);
--		  ready : out std_logic);
--end decFP;
--
--architecture Behavioral of decFP is
--
--procedure CalcInt(signal ShiftExp: in integer range 0 to EXP_WIDTH; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0);signal result : out STD_LOGIC_VECTOR(EXP_WIDTH-1 downto 0)) is
--begin
--	result <= (others=>'0');
--	if ShiftExp < EXP_WIDTH then
--		case (ShiftExp) is 
--			when 1 =>
--				 result(1 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-1);
--			when 2 =>
--				 result(2 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-2);
--			when 3 =>
--				 result(3 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-3);
--			when 4 =>
--				 result(4 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-4);
--			when 5 =>
--				 result(5 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-5);
--			when 6 =>
--				 result(6 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-6);
--			when 7 =>
--				 result(7 downto 0) <= '1'&CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-7);
--			when others =>
--				 result(0) <= '1'; -- quando ShiftExp=0
--		end case;
--	else
--		result(EXP_WIDTH-1 downto 0) <= (others=>'1');
--	end if;
--end CalcInt;
--
--procedure CountBits(signal ShiftExp: in integer range 0 to EXP_WIDTH; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0);variable bits : out integer range 0 to FRAC_WIDTH-1; variable zeros: out std_logic_vector(EXP_WIDTH-1 downto 0)) is
--variable b : integer range 0 to FRAC_WIDTH-1 := 0;
--variable z : std_logic_vector(EXP_WIDTH-1 downto 0) := (others=>'0');
--begin
--	b := 0;
--	z := (others=>'0');
--	for i in FRAC_WIDTH-1 downto 1 loop --Mnt_aux'range loop
--		if b < ShiftExp then
--			b := b + 1;
--		else
--			case CpiaMnts(i) is
--				when '0' => b := b + 1; z := z+'1';
--				when others => b := b + 1; z := z+'1'; exit;
--			end case;
--		end if;
--	end loop;
--	bits := b;
--	zeros := z;
--end CountBits;
--
--
--procedure ShiftR(variable bits: in integer range 0 to FRAC_WIDTH-1; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0); variable result: out std_logic_vector(FRAC_WIDTH-1 downto 0)) is
--begin
--	case (bits) is 
--		when 1 =>
--			 result(FRAC_WIDTH-1 downto 1) := CpiaMnts(FRAC_WIDTH-1-1 downto 0);
--		when 2 =>
--			 result(FRAC_WIDTH-1 downto 2) := CpiaMnts(FRAC_WIDTH-1-2 downto 0);
--		when 3 =>
--			 result(FRAC_WIDTH-1 downto 3) := CpiaMnts(FRAC_WIDTH-1-3 downto 0);
--		when 4 =>
--			 result(FRAC_WIDTH-1 downto 4) := CpiaMnts(FRAC_WIDTH-1-4 downto 0);
--		when 5 =>
--			 result(FRAC_WIDTH-1 downto 5) := CpiaMnts(FRAC_WIDTH-1-5 downto 0);
--		when 6 =>
--			 result(FRAC_WIDTH-1 downto 6) := CpiaMnts(FRAC_WIDTH-1-6 downto 0);
--		when 7 =>
--			 result(FRAC_WIDTH-1 downto 7) := CpiaMnts(FRAC_WIDTH-1-7 downto 0);
--		when 8 =>
--			 result(FRAC_WIDTH-1 downto 8) := CpiaMnts(FRAC_WIDTH-1-8 downto 0);
--		when 9 =>
--			 result(FRAC_WIDTH-1 downto 9) := CpiaMnts(FRAC_WIDTH-1-9 downto 0);
--		when 10 =>
--			 result(FRAC_WIDTH-1 downto 10) := CpiaMnts(FRAC_WIDTH-1-10 downto 0);
--		when 11 =>
--			 result(FRAC_WIDTH-1 downto 11) := CpiaMnts(FRAC_WIDTH-1-11 downto 0);
--		when 12 =>
--			 result(FRAC_WIDTH-1 downto 12) := CpiaMnts(FRAC_WIDTH-1-12 downto 0);
--		when 13 =>
--			 result(FRAC_WIDTH-1 downto 13) := CpiaMnts(FRAC_WIDTH-1-13 downto 0);
--		when 14 =>
--			 result(FRAC_WIDTH-1 downto 14) := CpiaMnts(FRAC_WIDTH-1-14 downto 0);
--		when 15 =>
--			 result(FRAC_WIDTH-1 downto 15) := CpiaMnts(FRAC_WIDTH-1-15 downto 0);
--		when 16 =>
--			 result(FRAC_WIDTH-1 downto 16) := CpiaMnts(FRAC_WIDTH-1-16 downto 0);
--		when 17 =>
--			 result(FRAC_WIDTH-1) := CpiaMnts(0);
--		when others =>
--			 result := CpiaMnts; -- nunca acontece que bits=0
--	end case;
--end ShiftR;
--
--
--signal MntXin : std_logic_vector(FRAC_WIDTH-1 downto 0) := (others=>'0');
--signal shiftExp : integer range 0 to EXP_WIDTH := 0;
--type   t_state is (waiting,compute,halfck);
--signal state : t_state;
--
--begin
--	
--	MntXin <= Xin(FRAC_WIDTH-1 downto 0);
--	
--	process(reset,clk,start)
--		variable zeros	    : std_logic_vector(EXP_WIDTH-1 downto 0) := (others => '0');
--		variable Mnt_aux   : std_logic_vector(FRAC_WIDTH-1 downto 0):= (others => '0');
--		variable bits      : integer range 0 to FRAC_WIDTH-1 := 0;
--	begin
--		if reset='1' then
--			intX     <= (others => '0');
--			decX  	<= (others => '0');
--			ready 	<= '0';
--			shiftExp <= 0;
--
--			zeros 	:= (others => '0');
--			Mnt_aux  := (others => '0');
--			bits     := 0;
--
--			state <= waiting;
--		elsif rising_edge(clk) then
--			case state is 
--				when waiting =>
--					if start = '1' then
--						if Xin(FP_WIDTH-2 downto FRAC_WIDTH) < bias then
--							intX <= (others=>'0');
--							decX <= Xin;
--							ready <= '1';
--							state <= waiting;
--						elsif Xin(FP_WIDTH-2 downto FRAC_WIDTH) > bias_MAX then -- if Xin(FP_WIDTH-2 downto FRAC_WIDTH) - bias > "00010001" --(FRAC_WIDTH em binario)
--							intX <= (others=>'1');
--							decX <= Zero;
--							ready <= '1';
--							state <= waiting;
--						else
--							shiftExp <= conv_integer(Xin(FP_WIDTH-2 downto FRAC_WIDTH) - bias);
--							intX <= (others => '0');
--							Mnt_aux := (others => '0');
--							zeros := (others => '0');
--							ready <= '0';
--							state <= compute;
--						end if;
--					else
--						ready <= '0';
--						state <= waiting;
--					end if;
--
--				when compute =>
--					CalcInt(shiftExp,MntXin,IntX);
--
--					CountBits(shiftExp,MntXin,bits,zeros);
--					if zeros="00000000" then
--						Mnt_aux(FRAC_WIDTH-1 downto 0):= (others => '0');
--						decX(FP_WIDTH-2 downto FRAC_WIDTH) <= (others => '0');
--					else
--						decX(FP_WIDTH-2 downto FRAC_WIDTH) <= bias - zeros;
--						ShiftR(bits,MntXin,Mnt_aux);
--					end if;
--
--					decX(FP_WIDTH-1) <= Xin(FP_WIDTH-1);
--					decX(FRAC_WIDTH-1 downto 0) <= Mnt_aux;
--					ready <= '1';
--					state <= waiting;
--
--				when others => state <= waiting;
--			end case;		 			
--		end if;
--	end process;			
--end Behavioral;
--
----procedure LeftMnts(signal ShiftExp: in integer range 0 to EXP_WIDTH; variable CpiaMnts: in std_logic_vector(FRAC_WIDTH downto 0);signal result : out STD_LOGIC_VECTOR(FRAC_WIDTH-1 downto 0))is	
----begin
----	result <= CpiaMnts; 
----	case (ShiftExp) is 
----		when 0 => 
----			result(FRAC_WIDTH-1 downto 0) <= CpiaMntsI(FRAC_WIDTH-1 downto 0);
----		when 1 =>
----			 result(FRAC_WIDTH-1 downto 1) <= CpiaMntsI(FRAC_WIDTH-2 downto 0);
----		when 2 =>
----			 result(FRAC_WIDTH-1 downto 2) <= CpiaMntsI(FRAC_WIDTH-3 downto 0);
----		when 3 =>
----			 result(FRAC_WIDTH-1 downto 3) <= CpiaMntsI(FRAC_WIDTH-4 downto 0);
----		when 4 =>
----			 result(FRAC_WIDTH-1 downto 4) <= CpiaMntsI(FRAC_WIDTH-5 downto 0);
----		when 5 =>
----			 result(FRAC_WIDTH-1 downto 5) <= CpiaMntsI(FRAC_WIDTH-6 downto 0);
----		when 6 =>
----			 result(FRAC_WIDTH-1 downto 6) <= CpiaMntsI(FRAC_WIDTH-7 downto 0);
----		when 7 =>
----			 result(FRAC_WIDTH-1 downto 7) <= CpiaMntsI(FRAC_WIDTH-8 downto 0);
----		when 8 =>
----			 result(FRAC_WIDTH-1 downto 8) <= CpiaMntsI(FRAC_WIDTH-9 downto 0);
----		when others =>
----			 result(FRAC_WIDTH-1 downto 0) <= CpiaMntsI(FRAC_WIDTH-1 downto 0);
----	end case;
----end LeftMnts;
--
--
----procedure CountZeros(variable CpiaMnts: in std_logic_vector(FRAC_WIDTH downto 0);variable zeros : out integer range 0 to EXP_WIDTH, variable s_z : out std_logic) is
----begin
----	s_z := '0';
----	zeros := 0;
----	for i in FRAC_WIDTH-1 downto 1 loop --Mnt_aux'range loop
----		case Mnt_aux(i) is
----			when '0' => zeros := zeros + 1; s_z := '0'; 
----			when others => zeros := zeros + 1; s_z := '1'; exit;
----		end case;
----	end loop;
----end CountZeros;
--
--
----function countZeros (CpiaMnts, ShiftExp :std_logic_vector) return integer is
----	variable Mnt_aux   : std_logic_vector(FRAC_WIDTH-1 downto 0):= (others => '0');
----begin  
----	Mnt_aux(FRAC_WIDTH-1 downto shiftExp) := Xin(FRAC_WIDTH-shiftExp-1 downto 0);
----	for i in FRAC_WIDTH-1 downto 1 loop
----		case Mnt_aux(i) is
----			when '0' => zeros := zeros + 1; s_z := '0'; 
----			when others => zeros := zeros + 1; s_z := '1'; exit;
----		end case;
----	end loop;          
----	return result; 
----end function;