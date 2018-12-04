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

entity cordic_exp is
	port(reset	:  in std_logic;
	     clk	:  in std_logic;
		 start	:  in std_logic;
		 Ain	:  in std_logic_vector(FP_WIDTH-1 downto 0);
		 exp    : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready  : out std_logic);
end cordic_exp;

architecture Behavioral of cordic_exp is

type RAM is array (FP_WIDTH-1 downto 0) of std_logic;
type RRAM is array (0 to 26) of RAM;
constant MEM : RRAM := ("001111110000110010011111010",
                        "001111101000001011000101011",
                        "001111100000000010101100010",
                        "001111011000000000101010110",
                        "001111010000000000001010101",
                        "001111001000000000000010101",
                        "001111000000000000000000101",
                        "001110111000000000000000001",
                        "001110110000000000000000000",
                        "001110101000000000000000000",
                        "001110100000000000000000000",
                        "001110011000000000000000000",
                        "001110010000000000000000000",
                        "001110001000000000000000000",
                        "001110000000000000000000000",
                        "001101111000000000000000000",
                        "001101110000000000000000000",
                        "001101101000000000000000000",
                        "001101100000000000000000000",
                        "001101011000000000000000000",
                        "001101010000000000000000000",
                        "001101001000000000000000000",
                        "001101000000000000000000000",
                        "001100111000000000000000000",
                        "001100110000000000000000000",
                        "001100101000000000000000000",
                        "001100100000000000000000000");

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

signal start_mul1 : std_logic := '0';
signal opA_mul1 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal opB_mul1 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal out_mul1 : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_mul1 : std_logic := '0';

signal start_decX : std_logic := '0';
signal intX 	   : std_logic_vector(EXP_WIDTH-1 downto 0) := (others=> '0');
signal decX	   : std_logic_vector(FP_WIDTH-1 downto 0) := (others=> '0');
signal ready_decX : std_logic := '0';

signal signAin     : std_logic := '0';
signal dW : std_logic_vector(FP_WIDTH-1 downto 0) := (others => '0');
signal atanh : std_logic_vector(FP_WIDTH-1 downto 0)  := (others=> '0');
signal signW : std_logic := '0';
signal signZ : std_logic := '0';
signal Iter  : std_logic_vector(4 downto 0) := "00001";

type t_state is (waiting,exp_reduc1,exp_decFP,exp_reduc2,taylor,taylor_mul,taylor_add,cordic,rotation);
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

   mul1: multiplierfsm_v2
   port map (reset         => reset,
             clk           => clk,
             op_a          => opA_mul1,
             op_b          => opB_mul1,
             start_i       => start_mul1,
             mul_out       => out_mul1,
             ready_mul     => ready_mul1);

   CdecX1: decFP
   port map(reset  => reset,
            clk    => clk,
   		 start  => start_decX,
   		 Xin	=> out_mul1,
   		 intX	=> intX,
   		 decX	=> decX,
   		 ready 	=> ready_decX);

-- Cordic uRotations
dW(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
dW(FP_WIDTH-2 downto FRAC_WIDTH) <= (out_as1(FP_WIDTH-2 downto FRAC_WIDTH) - Iter);
dW(FRAC_WIDTH-1  downto 0) <= out_as1(FRAC_WIDTH-1  downto 0);
signW <= '0' xor not(signZ);
signZ <= '1' xor out_as2(FP_WIDTH-1);
atanh <= STD_LOGIC_VECTOR(MEM(conv_integer(Iter-1)));
signAin <= Ain(FP_WIDTH-1);

process(reset,clk)
begin
   if rising_edge(clk) then
       if reset='1' then
           Iter	   <= "00001";
           start_as1  <= '0';
           start_as2  <= '0';
           start_mul1 <= '0';
           start_decX <= '0';
           op_as1     <= '0';
           op_as2     <= '0';
           exp        <= (others => '0');
           ready      <= '0';
           state    <= waiting;
       else
           case state is 
               when waiting =>
                   start_as1  	<= '0';
                   start_as2  	<= '0';
                   start_mul1 <= '0';
                   start_decX <= '0';
                   ready       <= '0';
                   Iter		<= "00001";
                   if start = '1' then
							if Ain = Zero then
								exp   <= s_one;
								Iter  <= "00001";
								ready <= '1';
								state <= waiting;
							else
								opA_mul1 <= Ain;
								opB_mul1 <= log2e;
								start_mul1 <= '1';
								state <= exp_reduc1;
							end if;
                   else
                       state <= waiting;
                   end if;

			when exp_reduc1 =>
				start_mul1 <= '0';
				if ready_mul1='1' then
					if out_mul1(FP_WIDTH-2 downto FRAC_WIDTH) > EXP_DF then
						start_decX <= '0';
                       if Ain(FP_WIDTH-1)='0' then
							exp   <= Inf;
						else
                           exp   <= Zero;
						end if;
						Iter  <= "00001";
						ready <= '1';
						state <= waiting;
					else
						start_decX <= '1';
						state <= exp_decFP;
					end if;
				else
					state <= exp_reduc1;
				end if;

			when exp_decFP =>
				start_decX <= '0';
				if ready_decX='1' then
					opA_mul1 <= decX;
					opB_mul1 <= ilog2e;
					start_mul1 <= '1';
					state <= exp_reduc2;
				else
					state <= exp_decFP;
				end if;

			when exp_reduc2 =>
				start_mul1 <= '0';
				if ready_mul1='1' then
					if out_mul1(FP_WIDTH-2 downto 0) < d_043(FP_WIDTH-2 downto 0) then  -- activa correccion por taylor
						state <= taylor;
					else
						Iter <= "00001";
						state <= cordic;
					end if;
				else
					state <= exp_reduc2;
				end if;

			when taylor =>
				if out_mul1 = Zero then
					exp     <= s_one;
					ready   <= '1';
					state   <= waiting;
				else
					opA_mul1 <= out_mul1;
					opB_mul1 <= out_mul1;
					start_mul1 <= '1';
					op_as1  <= '0';
					opA_as1 <= s_one;
					opB_as1 <= out_mul1;
					start_as1 <= '1';
					state <= taylor_mul;
				end if;

			when taylor_mul =>
				start_mul1 <= '0';
				start_as1 <= '0';
				if ready_as1 = '1' then
					op_as1  <= '0';
					opA_as1 <= out_as1;
					opB_as1(FP_WIDTH-1) <= '0';
					opB_as1(FP_WIDTH-2 downto FRAC_WIDTH) <= out_mul1(FP_WIDTH-2 downto FRAC_WIDTH) - '1';
					opB_as1(FRAC_WIDTH-1 downto 0) <= out_mul1(FRAC_WIDTH-1 downto 0); 
					start_as1 <= '1';
					state   <= taylor_add;
				else 
					state <= taylor_mul;
				end if;

			when taylor_add =>
				start_as1 <= '0';
				if ready_as1 = '1' then
					exp(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
					if signAin = '0' then
						exp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) + intX;
					else 
						exp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) - intX;
					end if;
					exp(FRAC_WIDTH-1 downto 0) <= out_as1(FRAC_WIDTH-1 downto 0);
					ready   <= '1';
					state   <= waiting;
				else
					state <= taylor_add;
				end if;

			when cordic =>
				if out_mul1 = Zero then
					exp     <= s_one;
					ready <= '1';
					state <= waiting;
				else
					if out_mul1(FP_WIDTH-1) = '0' then 
						op_as2 <= '1';
						op_as1 <= '0';
					else
						op_as2 <= '0';
						op_as1 <= '1';
					end if;
					opA_as1 <= Phyp;
					opB_as1(FP_WIDTH-1) <= Phyp(FP_WIDTH-1);
					opB_as1(FP_WIDTH-2 downto FRAC_WIDTH) <= (Phyp(FP_WIDTH-2 downto FRAC_WIDTH) - Iter);
					opB_as1(FRAC_WIDTH-1 downto 0) <= Phyp(FRAC_WIDTH-1  downto 0);
					start_as1 <= '1';
					opA_as2 <= out_mul1;
					opB_as2 <= atanh;
					start_as2 <= '1';
					Iter <= Iter+'1';
					state <= rotation;
				end if;

			when rotation =>
				start_as1 <= '0';
				start_as2 <= '0';
				if ready_as1='1' and ready_as2='1' then
					op_as1  <= signW;
					opA_as1 <= out_as1;
					opB_as1 <= dW;
					op_as2  <= signZ;
					opA_as2 <= out_as2;
					opB_as2 <= atanh;
					if Iter = MAX_ITER_CORDIC then
						exp(FP_WIDTH-1) <= out_as1(FP_WIDTH-1);
						if signAin = '0' then
							exp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) + intX;
						else 
							exp(FP_WIDTH-2 downto FRAC_WIDTH) <= out_as1(FP_WIDTH-2 downto FRAC_WIDTH) - intX;
						end if;
						exp(FRAC_WIDTH-1 downto 0) <= out_as1(FRAC_WIDTH-1 downto 0);
                       ready <= '1';
						state <= waiting;
					else
						Iter <= Iter+'1';
						start_as1 <= '1';
						start_as2 <= '1';
						state <= rotation;
					end if;
				else
					state <= rotation;
				end if;

               when others => state <= waiting;
           end case;
       end if;
	end if;
end process;

end Behavioral;
