library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.entities.all;
use work.fpupack.all;
use work.woapack.all;

entity sphere_whale is
	port (
		reset    		: in std_logic;
      clk      		: in std_logic;
      pstart   		: in std_logic_vector(1 downto 0); -- "01" ->calcula A e C; "10" -> nao calcula A e C; -- "00" -> faz nada
      init_1     		: in std_logic_vector(7 downto 0);		--serve para gerar o número aleatório
      init_2			: in std_logic_vector(7 downto 0);
		a   				: in std_logic_vector(FP_WIDTH-1 downto 0);
      pos_act  		: in std_logic_vector(FP_WIDTH-1 downto 0);
		pos_best_whale	: in std_logic_vector(FP_WIDTH-1 downto 0);
		pos_rand_whale : in std_logic_vector(FP_WIDTH-1 downto 0);
      new_pos  		: out std_logic_vector(FP_WIDTH-1 downto 0);
      pready   		: out std_logic;

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



--Sinais que se comunicam com os geradores de num. aleatorios
signal start_lfsr_1  : std_logic := '0';
signal lfsr_out_1		: std_logic_vector(FP_WiDTH-1 downto 0);
signal ready_lfsr_1	: std_logic := '0';


signal start_lfsr_2  : std_logic := '0';
signal lfsr_out_2		: std_logic_vector(FP_WiDTH-1 downto 0);
signal ready_lfsr_2	: std_logic := '0';

type   t_state is (waiting,
						multiplier,add1,acc, -- estados de cálculo da função custo
						calculo_AC_1,calculo_AC_2,calculo_AC_3,calculo_AC_4, --Estados do calculo do A e do C
						calculo_D, atualiza_pos,atualiza_pos_2,atualiza_pos_3 -- Estados que atualizam a posicao da particula
						);
						
signal state : t_state;


signal C_register		: std_logic_vector(FP_WIDTH-1 downto 0);
signal A_register		: std_logic_vector(FP_WIDTH-1 downto 0);
signal pos_register	: std_logic_vector(FP_WIDTH-1 downto 0); -- Armazena a posição atual (rand ou best_whale) para atualização da posição dependendo do valor de |A|

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
			 
				 
-- Essa unidade gera números aleatorios no range de [0,1]				 
Random_1: lfsr_fixtofloat_20bits
   port map (reset         => reset,
             clk           => clk,
             start         => start_lfsr_1,
             init          => init_1,
             lfsr_out      => lfsr_out_1,
				 ready			=> ready_lfsr_1);

-- Essa unidade gera números aleatorios no range de [0,1]				 				 
Random_2: lfsr_fixtofloat_20bits
   port map (reset         => reset,
             clk           => clk,
             start         => start_lfsr_2,
             init          => init_2,
             lfsr_out      => lfsr_out_2,
				 ready			=> ready_lfsr_2);				 
			 
process(reset,clk,fstart)
	variable acc_v   : std_logic_vector(FP_WIDTH-1 downto 0);   
	
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
				
				
				--Sinais dos geradores de num aleatorios
				start_lfsr_1 <= '0';
				start_lfsr_2 <= '0';
				
				
				--Reseta sinais de controle da maquina de estados
				acc_v    := (others => '0');
				count    <= (others => '0');
				
				C_register 		<= (others => '0');
				A_register 		<= (others => '0');
				pos_register 	<= (others => '0');
				
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
						
						if pstart = "01" then
							start_lfsr_1 <= '1'; --gera os r's para calculo do A e do C
							start_lfsr_2 <= '1';
							opA_mul1 <= s_two;
							state <= calculo_AC_1;
						end if;
						
						if pstart = "10" then
							opA_mul1 <= C_register;
							
							if '0'&A_register(FP_WIDTH-2 downto 0) < s_one then -- if |A| < 1								
								opB_mul1 		<= pos_best_whale;	-- D = C*x_best																
								pos_register 	<= pos_best_whale;								
							else
								-- Faz exploracao e vai em direcao de rand_whale
								opB_mul1 		<= pos_rand_whale;
								pos_register 	<= pos_rand_whale;								
							end if;							
							start_mul1 <= '1';							
							state <= calculo_D;
						end if;
						
					when calculo_AC_1 =>
						start_lfsr_1 <= '0';
						start_lfsr_2 <= '0';
						if ((ready_lfsr_1 and ready_lfsr_2) = '1') then
							opA_mul1 <= s_two;
							opB_mul1 <= lfsr_out_1;  
							start_mul1 <= '1';		-- 2*r parte do (2*a*r)
						
							opA_mul2 <= s_two;
							opB_mul2 <= lfsr_out_2;  
							start_mul2 <= '1';	   -- 2*r (c = 2*r)							
							state <= calculo_AC_2;
						end if;
					
					when calculo_AC_2 =>
						start_mul1 <= '0';
						start_mul2 <= '0';
						if((ready_mul1 and ready_mul2) = '1') then
							opA_mul1 <= out_mul1;
							opB_mul1 <= a;
							start_mul1 <= '1';	-- 2*r*a
						
							C_register <= out_mul2;
							state <= calculo_AC_3;
						end if;
						
					when calculo_AC_3 =>
						start_mul1 <= '0';
						start_mul2 <= '0';
						
						if ready_mul1 = '1' then
							opA_as <= out_mul1;
							opB_as <= a;
							op_as <= SUBTRACTION; 
							start_as <= '1'; --2*a*r - a
														
							state <= calculo_AC_4;
													
							
						end if;
					
					when calculo_AC_4 =>
						start_as <= '0';						
						
						if(ready_as = '1') then	
						
							A_register <= out_as;
							
							opA_mul1 <= C_register;
							
							if '0'&out_as(FP_WIDTH-2 downto 0) < s_one then -- if |A| < 1								
								opB_mul1 		<= pos_best_whale;	-- D = C*x_best																
								pos_register 	<= pos_best_whale;								
							else
								-- Faz exploracao e vai em direcao de rand_whale
								opB_mul1 		<= pos_rand_whale;
								pos_register 	<= pos_rand_whale;								
							end if;
							
							start_mul1 <= '1';							
							state <= calculo_D; 
						end if;
					
					when calculo_D =>
						start_mul1 <= '0';
						if(ready_mul1 = '1') then
							opA_as <= out_mul1;
							opB_as <= pos_act;
							op_as <= SUBTRACTION;		
							start_as <= '1';							-- D = C*X(rand ou best) - pos_act			
							state <= atualiza_pos;
						end if;
					
					when atualiza_pos =>
						start_as <= '0';
						if(ready_as = '1') then
							opA_mul1 <= A_register;
							opB_mul1 <= '0'&out_as(FP_WIDTH-2 downto 0); -- A*D parte do x = x* - A*D //D= |c*x_best - pos_act|
							start_mul1 <= '1';
							state <= atualiza_pos_2;
						end if;
					
					when atualiza_pos_2 =>
						start_mul1 <= '0';
						if (ready_mul1 = '1') then
							opA_as <= pos_register;
							opB_as <= out_mul1;
							op_as <= SUBTRACTION;
							start_as <= '1';					-- X(t+1) = x(rand ou best) - A*D
							state <= atualiza_pos_3;
						end if;
					
					when atualiza_pos_3 =>
						start_as <= '0';
						if(ready_as = '1') then
							pready <= '1';
							new_pos <= out_as;
							state <= waiting;
						end if;

					
-- =======================       Estados para cálculo da função custo					
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