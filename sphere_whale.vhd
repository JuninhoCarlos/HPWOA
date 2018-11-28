library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.entities.all;
use work.fpupack.all;
use work.woapack.all;

entity sphere_whale is
	port (
		reset    :  in std_logic;
      clk      :  in std_logic;
      pstart   :  in std_logic;
--      init     :  in std_logic_vector(7 downto 0);
--      weight   :  in std_logic_vector(FP_WIDTH-1 downto 0);
--      pos_act  :  in std_logic_vector(FP_WIDTH-1 downto 0);
--      best_ys  :  in std_logic_vector(FP_WIDTH-1 downto 0);
--      best_yi  :  in std_logic_vector(FP_WIDTH-1 downto 0);
--      new_pos  : out std_logic_vector(FP_WIDTH-1 downto 0);
      pready   : out std_logic;

      fstart   :  in std_logic;
      x1_in    :  in std_logic_vector(FP_WIDTH-1 downto 0);
      x2_in    :  in std_logic_vector(FP_WIDTH-1 downto 0);
      x3_in    :  in std_logic_vector(FP_WIDTH-1 downto 0);
      x4_in    :  in std_logic_vector(FP_WIDTH-1 downto 0);
      x5_in    :  in std_logic_vector(FP_WIDTH-1 downto 0);
      x6_in    :  in std_logic_vector(FP_WIDTH-1 downto 0);
      f_out    : out std_logic_vector(FP_WIDTH-1 downto 0);
      fready   : out std_logic
	);
end sphere_whale;

architecture rlt of sphere_whale is

--Sinais do multiplexador que contrala as entradas do multiplicador para paralelizar o calculo dos quadrados
signal count      : std_logic_vector(3 downto 0);
signal out_mux1   : std_logic_vector(FP_WIDTH-1 downto 0);
signal out_mux2   : std_logic_vector(FP_WIDTH-1 downto 0);

--Sinais que se comunicam com multicplicador 1
signal opA_mul1	: std_logic_vector(FP_WIDTH-1 downto 0);
signal opB_mul1	: std_logic_vector(FP_WIDTH-1 downto 0);
signal start_mul1	: std_logic;
signal out_mul1	: std_logic_vector(FP_WIDTH-1 downto 0);
signal ready_mul1	: std_logic;

--Sinais que se comunicam com multicplicador 2
signal opA_mul2	: std_logic_vector(FP_WIDTH-1 downto 0);
signal opB_mul2	: std_logic_vector(FP_WIDTH-1 downto 0);
signal start_mul2	: std_logic;
signal out_mul2	: std_logic_vector(FP_WIDTH-1 downto 0);
signal ready_mul2	: std_logic;

--Sinais que se comunicam com o aditor/subtrator
signal op_as 		: std_logic;
signal opA_as		: std_logic_vector(FP_WIDTH-1 downto 0);
signal opB_as		: std_logic_vector(FP_WIDTH-1 downto 0);
signal start_as	: std_logic;
signal out_as		: std_logic_vector(FP_WIDTH-1 downto 0);
signal ready_as	: std_logic;


type   t_state is (waiting,multiplier,add1,acc);
signal state : t_state;

begin

--Instanciação de componentes
mul1: multiplierfsm_v2
   port map (reset         => reset,
             clk           => clk,
             op_a          => opA_mul1,
             op_b          => opB_mul1,
             start_i       => start_mul1,
             mul_out       => out_mul1,
             ready_mul     => ready_mul1);

mul2: multiplierfsm_v2
port map (reset         => reset,
			 clk           => clk,
			 op_a          => opA_mul2,
			 op_b          => opB_mul2,
			 start_i       => start_mul2,
			 mul_out       => out_mul2,
			 ready_mul     => ready_mul2);

adsb: addsubfsm_v6
   port map (reset         => reset,
             clk           => clk,
             op            => op_as,
             op_a          => opA_as,
             op_b          => opB_as,
             start_i       => start_as,
             addsub_out    => out_as,
             ready_as      => ready_as);
			 
			 
process(reset,clk,fstart)
	variable acc_v   : std_logic_vector(FP_WIDTH-1 downto 0);
   variable dim     : integer range 0 to 6;
	
	begin
		if rising_edge(clk) then
			if reset='1' then
				state    <= waiting;
				--Reseta sinais de comunicação com as unidades funcionais
				start_mul1 <= '0';
				start_mul2 <= '0';
				opA_mul1   <= (others => '0');
				opB_mul1   <= (others => '0');
				opA_mul2   <= (others => '0');
				opB_mul2   <= (others => '0');
				start_as   <= '0';
				op_as      <= '0';
				opA_as     <= (others => '0');
				opB_as     <= (others => '0');
				
				--Reseta sinais de controle da maquina de estados
				acc_v    := (others => '0');
				count    <= (others => '0');
				
				--Reseta sinais de comunicação com a entidade externa
				f_out    <= (others => '0');				
				fready   <= '0';
				pready 	<= '0';
				

			else
				case state is 
					when waiting =>
						fready <= '0';
						pready <= '0';
						op_as <= '0';
						if fstart = '1' then
							acc_v 	:= (others => '0'); --zera o acumulador
							count		<= (others => '0'); --zera contador que controla mux
							opA_mul1       <= out_mux1;
							opB_mul1       <= out_mux1;
							start_mul1     <= '1';
							opA_mul2       <= out_mux2;
							opB_mul2       <= out_mux2;
							start_mul2     <= '1';
							state          <= multiplier;					
						end if;
					
					when multiplier =>
						start_mul1     <= '0';
						start_mul2     <= '0';
						op_as <= '0';
						if (ready_mul1 AND ready_mul2)='1' then
							 opA_as      <= out_mul1;
							 opB_as      <= out_mul2;
							 start_as    <= '1';
							 state 			<= add1;
						end if;
					
					when add1 =>
						start_as <= '0';
						op_as <= '0';
						if ready_as = '1' then
							opA_as     <= out_as;
							opB_as     <= acc_v;
							start_as   <= '1';
							count      <= count + '1';
							state      <= acc;
						else 
							state <= add1;               
						end if;
						
					when acc =>
						start_as <= '0';
						op_as <= '0';
						if ready_as = '1' then
							if count = "11" then
								fready <= '1';
								f_out  <= out_as;
								state  <= waiting;
							else
								acc_v      := out_as;
								opA_mul1   <= out_mux1;
								opB_mul1   <= out_mux1;
								start_mul1 <= '1';
								opA_mul2   <= out_mux2;
								opB_mul2   <= out_mux2;
								start_mul2 <= '1';
								state      <= multiplier;
							end if;
						else 
							state <= acc;               
						end if;
						
					when others =>
				end case;
			end if;
		end if;
	end process;
			 
			 
			 
			 
			 
			 
--Dois multiplexadores para pode fazer o somatório da função esfera em paralelo em em trÊs passos
process(clk,count)
begin
	case count is
       when "0000" => out_mux1 <= x1_in;
       when "0001" => out_mux1 <= x3_in;
       when "0010" => out_mux1 <= x5_in;
       when others => out_mux1 <= x1_in;
	end case;
end process;

process(clk,count)
begin
	case count is
       when "0000" => out_mux2 <= x2_in;
       when "0001" => out_mux2 <= x4_in;
       when "0010" => out_mux2 <= x6_in;
       when others => out_mux2 <= x2_in;
	end case;
end process;

end rlt;