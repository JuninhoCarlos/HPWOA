-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MU�OZ ARBOLEDA
-- 
-- Create Date:   06-Oct-2012 
-- Design name:   lfsr_fixtofloat
-- Module name:   lfsr_fixtofloat - behavioral
-- Description:   U[-1,1] and fireflies initialization 
-- Automatically generated using the vHFAgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;

entity compara_baleias is
port (reset     :  in std_logic;
      clk       :  in std_logic;
      start_cmp_baleia :  in std_logic;
      f_y_p1   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p2   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p3   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p4   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p5   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p6   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p7   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p8   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p9   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_y_p10   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      y_pj      : out std_logic_vector(3 downto 0);
      cmpsc_out : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready_cmpsc : out std_logic);
end compara_baleias;

architecture Behavioral of compara_baleias is

signal s_y_pj : std_logic_vector(3 downto 0) := "0000";
type   t_state is (waiting,minimum1,minimum2,minimum3,minimum4,minimum5,minimum6,minimum7,minimum8,minimum9,minimum10,output_cs);
signal state : t_state;

begin
process(clk,reset)
variable key : std_logic_vector(FP_WIDTH-1 downto 0);
begin
   if rising_edge(clk) then
       if reset='1' then
           state <= waiting;
           key := Inf;
           cmpsc_out <= Inf;
           s_y_pj <= "0000";
           y_pj <= "0000";
           ready_cmpsc	<= '0';
       else
           case state is 
               when waiting =>
                   ready_cmpsc	<= '0';
                   if start_cmp_baleia = '1' then
                       key := Inf;
                       state <= minimum1;
                   else state <= waiting;
                   end if;
               when minimum1 =>
                   if f_y_p1(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p1;
                       s_y_pj <= "0000";
                   end if;
                   state <= minimum2;
               when minimum2 =>
                   if f_y_p2(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p2;
                       s_y_pj <= "0001";
                   end if;
                   state <= minimum3;
               when minimum3 =>
                   if f_y_p3(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p3;
                       s_y_pj <= "0010";
                   end if;
                   state <= minimum4;
               when minimum4 =>
                   if f_y_p4(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p4;
                       s_y_pj <= "0011";
                   end if;
                   state <= minimum5;
               when minimum5 =>
                   if f_y_p5(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p5;
                       s_y_pj <= "0100";
                   end if;
                   state <= minimum6;
               when minimum6 =>
                   if f_y_p6(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p6;
                       s_y_pj <= "0101";
                   end if;
                   state <= minimum7;
               when minimum7 =>
                   if f_y_p7(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p7;
                       s_y_pj <= "0110";
                   end if;
                   state <= minimum8;
               when minimum8 =>
                   if f_y_p8(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p8;
                       s_y_pj <= "0111";
                   end if;
                   state <= minimum9;
               when minimum9 =>
                   if f_y_p9(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p9;
                       s_y_pj <= "1000";
                   end if;
                   state <= minimum10;
               when minimum10 =>
                   if f_y_p10(FP_WIDTH-2 downto 0) < key(FP_WIDTH-2 downto 0) then
                       key  := f_y_p10;
                       s_y_pj <= "1001";
                   end if;
                   state <= output_cs;
               when output_cs =>
                   y_pj <= s_y_pj;
                   cmpsc_out <= key;
                   ready_cmpsc <= '1';
                   state <= waiting;
               when others => state <= waiting;
           end case;
       end if;
   end if;
end process;

end Behavioral;

