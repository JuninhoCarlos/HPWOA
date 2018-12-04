-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MU�OZ ARBOLEDA
-- 
-- Create Date:   04-Dec-2018 
-- Design name:   Cordic 
-- Module name:   Cordic - behavioral
-- Description:   Circular Cordic for computing sin/cos
--                using floating-point arithmetics
-- Automatically generated using the vFPUgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.entities.all;
use work.fpupack.all;

entity cordic_sincos is
	port(reset	:  in std_logic;
	     clk	:  in std_logic;
		 start	:  in std_logic;
		 Ain	:  in std_logic_vector(FP_WIDTH-1 downto 0);
		 sin    : out std_logic_vector(FP_WIDTH-1 downto 0);
		 cos	: out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready  : out std_logic);
end cordic_sincos;

architecture Behavioral of cordic_sincos is

type RAM is array (FP_WIDTH-1 downto 0) of std_logic;
type RRAM is array (0 to 26) of RAM;
constant MEM : RRAM := ("001111110100100100001111110", --7.853982e-01
                        "001111101110110101100011001", --4.636476e-01
                        "001111100111101011011011101", --2.449787e-01
                        "001111011111111010101101110", --1.243550e-01
                        "001111010111111110101010110", --6.241881e-02
                        "001111001111111111101010101", --3.123983e-02
                        "001111000111111111111010101", --1.562373e-02
                        "001110111111111111111110101", --7.812341e-03
                        "001110110111111111111111101", --3.906230e-03
                        "001110101111111111111111111", --1.953123e-03
                        "001110100111111111111111111", --9.765622e-04
                        "001110011111111111111111111", --4.882812e-04
                        "001110010111111111111111111", --2.441406e-04
                        "001110001111111111111111111", --1.220703e-04
                        "001110000111111111111111111", --6.103516e-05
                        "001101111111111111111111111", --3.051758e-05
                        "001101110111111111111111111", --1.525879e-05
                        "001101101111111111111111111", --7.629395e-06
                        "001101100111111111111111111", --3.814697e-06
                        "001101011111111111111111111", --1.907349e-06
                        "001101010111111111111111111", --9.536743e-07
                        "001101001111111111111111111", --4.768372e-07
                        "001101000111111111111111111", --2.384186e-07
                        "001100111111111111111111111", --1.192093e-07
                        "001100110111111111111111111", --5.960464e-08
                        "001100101111111111111111111", --2.980232e-08
                        "001100100111111111111111111"); --1.490116e-08

signal start_as1: std_logic := '0';
signal op_as1 	 : std_logic := '0';
signal opA_as1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_as1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_as1  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_as1: std_logic := '0';

signal start_as2: std_logic := '0';
signal op_as2 	 : std_logic := '0';
signal opA_as2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_as2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_as2  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_as2: std_logic := '0';

signal start_as3: std_logic := '0';
signal op_as3 	 : std_logic := '0';
signal opA_as3  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_as3  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_as3  : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_as3: std_logic := '0';

signal start_mul1 : std_logic := '0';
signal opA_mul1 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_mul1 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_mul1 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_mul1 : std_logic := '0';

signal start_decX  : std_logic := '0';
signal quad 	  	: std_logic_vector(1 downto 0) := (others=> '0');
signal decX		: std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_decX  : std_logic := '0';
signal quadrant    : std_logic_vector(2 downto 0) := "000";
signal ready_cordic: std_logic := '0';

type   t_state is (waiting,cordicmul1,cordicdec1,cordicmul2,cordicrot);
signal state : t_state;

begin

   adsb1: addsubfsm_v6
   port map (reset         => reset,
             clk           => clk,
             op            => op_as1,
             op_a          => opA_as1,
             op_b          => opB_as1,
             start_i       => start_as1,
             addsub_out    => out_as1,
             ready_as      => ready_as1);

   adsb2: addsubfsm_v6
   port map (reset         => reset,
             clk           => clk,
             op            => op_as2,
             op_a          => opA_as2,
             op_b          => opB_as2,
             start_i       => start_as2,
             addsub_out    => out_as2,
             ready_as      => ready_as2);

   adsb3: addsubfsm_v6
   port map (reset         => reset,
             clk           => clk,
             op            => op_as3,
             op_a          => opA_as3,
             op_b          => opB_as3,
             start_i       => start_as3,
             addsub_out    => out_as3,
             ready_as      => ready_as3);

   mul1: multiplierfsm_v2
   port map (reset         => reset,
             clk           => clk,
             op_a          => opA_mul1,
             op_b          => opB_mul1,
             start_i       => start_mul1,
             mul_out       => out_mul1,
             ready_mul     => ready_mul1);

   CdecX1: decFP_quad
   port map(reset  => reset,
            clk    => clk,
   		 start  => start_decX,
   		 Xin	=> out_mul1,
   		 quad	=> quad,
   		 decX	=> decX,
   		 ready 	=> ready_decX);

process(reset,clk)
variable Iter : std_logic_vector(4 downto 0) := "00000";
begin
   if rising_edge(clk) then
       if reset='1' then
           Iter		:= "00000";
           quadrant 	<= "000";

           start_as1  <= '0';
           start_as2  <= '0';
           start_as3  <= '0';
           start_mul1 <= '0';
           start_decX <= '0';

           op_as1   <= '0';
           op_as2   <= '0';
           op_as3   <= '0';

           sin      <= (others => '0');
           cos      <= (others => '0');

           ready    <= '0';
           state    <= waiting;
       else
           case state is 
               when waiting =>
                   start_as1  	<= '0';
                   start_as2  	<= '0';
                   start_as3  	<= '0';
                   start_mul1 	<= '0';
                   start_decX  <= '0';

                   ready   <= '0';
                   quadrant	<= "000";
                   Iter		:= "00000";
                   if start = '1' then
                       opA_mul1 	<= Ain;
                       opB_mul1 	<= s_2dpi;
                       start_mul1 	<= '1';
                       state   	<= cordicmul1;
                   else
                       state <= waiting;
                   end if;

               when cordicmul1 =>
                   Iter	:= "00000";
                   start_mul1 <= '0';
                   ready   <= '0';
                   if ready_mul1 = '1' then
                       start_decX  <= '1';
                       state    	<= cordicdec1;
                   else
                       state <= cordicmul1;
                   end if;

               when cordicdec1 =>
                   Iter	:= "00000";
                   start_decX <= '0';
                   ready   <= '0';
                   if ready_decX = '1' then
                       quadrant 	<= Ain(FP_WIDTH-1) & quad(1 downto 0);
                       opA_mul1  	<= decX;
                       opB_mul1  	<= s_pid2;
                       start_mul1	<= '1';
                       state 		<= cordicmul2;
                   else 
                       state <= cordicdec1;
                   end if;

               when cordicmul2 =>
                   start_mul1 <= '0';
                   ready   <= '0';
                   if ready_mul1 = '1' then
                       op_as1 	<= not Ain(FP_WIDTH-1);
                       opA_as1 	<= P(FP_WIDTH-1 downto 0);
                       opB_as1(FP_WIDTH-1) <= Zero(FP_WIDTH-1);
                       opB_as1(FP_WIDTH-2 DOWNTO FRAC_WIDTH) <= (Zero(FP_WIDTH-2 DOWNTO FRAC_WIDTH) - Iter);
                       opB_as1(FRAC_WIDTH-1  DOWNTO 0) <= Zero(FRAC_WIDTH-1  DOWNTO 0);
                       start_as1 <= '1';

                       op_as2 	<= Ain(FP_WIDTH-1);
                       opA_as2 	<= Zero;
                       opB_as2(FP_WIDTH-1) <= P(FP_WIDTH-1);
                       opB_as2(FP_WIDTH-2 DOWNTO FRAC_WIDTH) <= (P(FP_WIDTH-2 DOWNTO FRAC_WIDTH) - Iter);
                       opB_as2(FRAC_WIDTH-1  DOWNTO 0) <= P(FRAC_WIDTH-1  DOWNTO 0);
                       start_as2 <= '1';

                       op_as3 	<= not Ain(FP_WIDTH-1);
                       opA_as3 	<= out_mul1;
                       opB_as3  <= STD_LOGIC_VECTOR(MEM(conv_integer(Iter)));
                       start_as3 <= '1';

                       state <= cordicrot;
                   else 
                       state <= cordicmul2;
                   end if;

               when cordicrot =>
                   start_as1 <= '0';
                   start_as2 <= '0';
                   start_as3 <= '0';
                   if ready_as1='1' and ready_as2='1' and ready_as3='1' then
                       Iter := Iter+'1';
                       op_as1  <= not out_as3(FP_WIDTH-1);
                       opA_as1 <= out_as1;
                       opB_as1(FP_WIDTH-1) <= out_as2(FP_WIDTH-1);
                       opB_as1(FP_WIDTH-2 DOWNTO FRAC_WIDTH) <= (out_as2(FP_WIDTH-2 DOWNTO FRAC_WIDTH) - Iter);
                       opB_as1(FRAC_WIDTH-1  DOWNTO 0) <= out_as2(FRAC_WIDTH-1  DOWNTO 0);

                       op_as2  <= out_as3(FP_WIDTH-1);
                       opA_as2 <= out_as2;
                       opB_as2(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
                       opB_as2(FP_WIDTH-2 DOWNTO FRAC_WIDTH) <= (out_as1(FP_WIDTH-2 DOWNTO FRAC_WIDTH) - Iter);
                       opB_as2(FRAC_WIDTH-1 DOWNTO 0) <= out_as1(FRAC_WIDTH-1  DOWNTO 0);

                       op_as3  <= not out_as3(FP_WIDTH-1);
                       opA_as3 <= out_as3;
                       opB_as3 <= STD_LOGIC_VECTOR(MEM(conv_integer(Iter))); --atan;
                       if Iter = MAX_ITER_CORDIC then
                           if Ain(FP_WIDTH-2 DOWNTO FRAC_WIDTH) <= bias_MIN then
                               sin <= Zero;
                               cos <= s_one;
                           else
                               if quadrant = "000" then
                                   sin <= out_as2;
                                   cos <= out_as1;
                               elsif quadrant = "001" then
                                   sin <= out_as1;
                                   cos <= not(out_as2(FP_WIDTH-1)) & out_as2(FP_WIDTH-2 downto 0);
                               elsif quadrant = "010" then
                                   sin <= not(out_as2(FP_WIDTH-1)) & out_as2(FP_WIDTH-2 downto 0);
                                   cos <= not(out_as1(FP_WIDTH-1)) & out_as1(FP_WIDTH-2 downto 0);
                               elsif quadrant = "011" then
                                   sin <= not(out_as1(FP_WIDTH-1)) & out_as1(FP_WIDTH-2 downto 0);
                                   cos <= out_as2;
                               elsif quadrant = "100" then
                                   sin <= out_as2;
                                   cos <= out_as1;
                               elsif quadrant = "101" then
                                   sin <= not(out_as1(FP_WIDTH-1)) & out_as1(FP_WIDTH-2 downto 0);
                                   cos <= out_as2;
                               elsif quadrant = "110" then
                                   sin <= not(out_as2(FP_WIDTH-1)) & out_as2(FP_WIDTH-2 downto 0);
                                   cos <= not(out_as1(FP_WIDTH-1)) & out_as1(FP_WIDTH-2 downto 0);
                               else
                                   sin <= out_as1;
                                   cos <= not(out_as2(FP_WIDTH-1)) & out_as2(FP_WIDTH-2 downto 0);
                               end if;
                           end if;
                           ready <= '1';
                           state <= waiting;
                       else
                           start_as1 <= '1';
                           start_as2 <= '1';
                           start_as3 <= '1';
                           ready <= '0';
                           state <= cordicrot;
                       end if;
                   else
                       state <= cordicrot;
                   end if;

               when others => state <= waiting;
           end case;
       end if;
	end if;
end process;

end Behavioral;
