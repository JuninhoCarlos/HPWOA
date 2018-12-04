-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MU�OZ ARBOLEDA
-- 
-- Create Date:   04-Oct-2012 
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

entity decFP_quad is
	port (reset     :  in std_logic;
		 clk        :  in std_logic;
		 start      :  in std_logic;
		 Xin        :  in std_logic_vector(FP_WIDTH-1 downto 0);
		 quad       : out std_logic_vector(1 downto 0);
		 decX       : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready      : out std_logic);
end decFP_quad;

architecture Behavioral of decFP_quad is

procedure CalcInt(signal ShiftExp: in integer range 0 to FRAC_WIDTH-1; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0);signal result : out STD_LOGIC_VECTOR(1 downto 0)) is
begin
	if ShiftExp < EXP_WIDTH then
		case (ShiftExp) is
			when 1 => result <= '1'&CpiaMnts(FRAC_WIDTH-1);
			when 2 => result <= CpiaMnts(FRAC_WIDTH-1 downto FRAC_WIDTH-2);
			when 3 => result <= CpiaMnts(FRAC_WIDTH-2 downto FRAC_WIDTH-3);
			when 4 => result <= CpiaMnts(FRAC_WIDTH-3 downto FRAC_WIDTH-4);
			when 5 => result <= CpiaMnts(FRAC_WIDTH-4 downto FRAC_WIDTH-5);
			when 6 => result <= CpiaMnts(FRAC_WIDTH-5 downto FRAC_WIDTH-6);
			when 7 => result <= CpiaMnts(FRAC_WIDTH-6 downto FRAC_WIDTH-7);
			when others =>
				 result <= "01"; -- quando ShiftExp=0
		end case;
	else
		result <= (others=>'1');
	end if;
end CalcInt;

procedure CountBits(signal ShiftExp: in integer range 0 to FRAC_WIDTH-1; signal CpiaMnts: in std_logic_vector(FRAC_WIDTH-1 downto 0);variable bits : out integer range 0 to FRAC_WIDTH-1; variable zeros: out std_logic_vector(5 downto 0)) is
variable b : integer range 0 to FRAC_WIDTH-1 := 0;
variable z : std_logic_vector(5 downto 0) := (others=>'0');
begin
	b := 0;
	z := (others=>'0');
	for i in FRAC_WIDTH-1 downto 1 loop --Mnt_aux'range loop
		if b < ShiftExp then
			b := b+1;
		else
           b := b+1; z := z+'1';
			case CpiaMnts(i) is
				when '0' => null;
				when others => exit;
			end case;
		end if;
	end loop;
	bits := b;
	zeros := z;
end CountBits;

signal MntXin : std_logic_vector(FRAC_WIDTH-1 downto 0) := (others=>'0');
signal shiftExp : integer range 0 to FRAC_WIDTH-1 := 0;
type   t_state is (waiting,compute);
signal state : t_state;

begin

	MntXin <= Xin(FRAC_WIDTH-1 downto 0);

	process(reset,clk,start)
		variable zeros	    : std_logic_vector(5 downto 0) := (others => '0');
		variable Mnt_aux   : std_logic_vector(FRAC_WIDTH-1 downto 0):= (others => '0');
		variable bits      : integer range 0 to FRAC_WIDTH-1 := 0;
	begin
		if rising_edge(clk) then
           if reset='1' then
               shiftExp <= 0;
               quad     <= (others => '0');
               decX  	<= (others => '0');
               ready 	<= '0';
               zeros 	:= (others => '0');
               Mnt_aux  := (others => '0');
               bits     := 0;
               state <= waiting;
           else
               case state is
                   when waiting =>
                       if start = '1' then
                           if Xin(FP_WIDTH-2 downto FRAC_WIDTH) < bias then
                               shiftExp <= 0;
                               quad <= (others=>'0');
                               Mnt_aux := (others => '0');
                               zeros := (others => '0');
                               decX <= Xin;
                               ready <= '1';
                               state <= waiting;
                           elsif Xin(FP_WIDTH-2 downto FRAC_WIDTH) > bias_MAX then
                               shiftExp <= 0;
                               quad <= (others=>'1');
                               Mnt_aux := (others => '0');
                               zeros := (others => '0');
                               decX <= Zero;
                               ready <= '1';
                               state <= waiting;
                           else
                               shiftExp <= conv_integer(Xin(FP_WIDTH-2 downto FRAC_WIDTH) - bias);
                               quad <= (others => '0');
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
                       CalcInt(shiftExp,MntXin,quad);
                       CountBits(shiftExp,MntXin,bits,zeros);
                       if zeros="000000" then
                           decX(FP_WIDTH-2 downto FRAC_WIDTH) <= (others => '0');
                           Mnt_aux(FRAC_WIDTH-1 downto 0):= (others => '0');
                       else
                           decX(FP_WIDTH-2 downto FRAC_WIDTH) <= bias - zeros;
                           Mnt_aux := to_stdlogicvector(to_bitvector(MntXin) sll bits);
                       end if;
                       decX(FP_WIDTH-1) <= Xin(FP_WIDTH-1);
                       decX(FRAC_WIDTH-1 downto 0) <= Mnt_aux;
                       ready <= '1';
                       state <= waiting;

                   when others => state <= waiting;
               end case;
           end if;
		end if;
	end process;

end Behavioral;
