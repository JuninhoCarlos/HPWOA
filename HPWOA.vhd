library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.entities.all;
use work.fpupack.all;
use work.woapack.all;

-- radix define float27 -float -fraction 18 
-- comando para visualizar o valor

entity HPWOA is
	port (
		reset    	:  in std_logic;
      clk      	:  in std_logic;
		best_fitness: 	out std_logic_vector(FP_WIDTH-1 downto 0)
      
	);
end HPWOA;

architecture rlt of HPWOA is


type   t_state is (waiting,init_x,fitness_x,verifica_best_fitness,updatep);
signal state : t_state;

--Sinal que indica o inicio do algoritmo
signal i_start	 		: std_logic := '0';


--Sinais do gerador de números aleatorio para inicializacao das baleias
signal s_start_lfsr_px	: std_logic := '0';
signal s_lfsr_out_px 	: std_logic_vector(FP_WIDTH-1 downto 0) := (others => '0');
signal s_ready_lfsr_px 	: std_logic := '0';


--Sinal que armazena as posições das partículas para function evaluation
type matrix2D is array (1 to NP, 1 to ND) of std_logic_vector(FP_WIDTH-1 downto 0);
signal s_nx : matrix2D;

type matriz1D is array (1 to NP) of std_logic_vector(FP_WIDTH-1 downto 0);
signal fout : matriz1D; --Sinal que possui o valor da função fitness para cada baleia


signal pstart : std_logic;
signal pready : std_logic_vector(1 to NP);

--Sinais para avaliação de função custo na particula
signal s_start_eval : std_logic := '0'; --Sinal que sinaliza inicio de avaliação do fitness da função
signal fready_eval : std_logic_vector(1 to NP) := (others => '0');

--sinais para comparação das funções custo
signal s_start_cmp_baleia : std_logic := '0';
signal s_ready_cmp_baleia : std_logic := '0';
signal best_baleia		  : std_logic_vector(3 downto 0);
signal fitness_best_baleia: std_logic_vector(FP_WIDTH-1 downto 0);


--sinais para o calcula da inercia (azinho)
signal s_start_inertia 	: std_logic;
signal new_a				: std_logic_vector(FP_WIDTH-1 downto 0);
signal ready_inertia		: std_logic;



signal pos_atual_whale  : matriz1D;
signal new_pos				: matriz1D;
signal pos_best_whale : std_logic_vector(FP_WIDTH-1 downto 0);

begin

best_fitness <= fitness_best_baleia;

-- Instanciação de componentes
rand_px: lfsr_px
   port map (reset         => reset,
             clk           => clk,
             start         => s_start_lfsr_px,
             init 		    => init_random,
             lfsr_out      => s_lfsr_out_px,
             ready         => s_ready_lfsr_px);
				 
--Instancia as 10 (NP) baleias e faz o port map
whale_generate : for I in 1 to NP generate
	whale : sphere_whale port map(
		reset    		=> reset,
      clk      		=> clk,
      pstart   		=> pstart,
		init_1     		=> init_p(I),
		init_2			=> init_p(2),
      a   				=> new_a,
      pos_act  		=> pos_atual_whale(I),
      pos_best_whale	=> pos_best_whale,
      new_pos  		=> new_pos(I),
      pready   		=> pready(I),

      fstart   => s_start_eval,
      x1_in    => s_nx(I,1),
      x2_in    => s_nx(I,2),
      x3_in    => s_nx(I,3),
      x4_in    => s_nx(I,4),
      x5_in    => s_nx(I,5),
      x6_in    => s_nx(I,6),
      f_out    => fout(I),
      fready   => fready_eval(I)
	);
end generate;
								 
cmp_whale: compara_baleias 
	port map(
		reset     			=> reset,
      clk       			=> clk,
      start_cmp_baleia 	=> s_start_cmp_baleia,
      f_y_p1   			=> fout(1),
      f_y_p2   			=> fout(2),
      f_y_p3   			=> fout(3),
      f_y_p4   			=> fout(4),
      f_y_p5   			=> fout(5),
      f_y_p6   			=> fout(6),
      f_y_p7   			=> fout(7),
      f_y_p8   			=> fout(8),
      f_y_p9   			=> fout(9),
		f_y_p10   			=> fout(10),
      y_pj      			=> best_baleia,
      cmpsc_out 			=> fitness_best_baleia,
      ready_cmpsc 		=> s_ready_cmp_baleia
	);

inertia : a_minusculo 
	port map (
		reset    		=> reset,
		clk      		=> clk,
		start		   	=> s_start_inertia,
		new_weight  	=> new_a,
		ready_inerti	=> ready_inertia
	);

								 
--Máquina de estados que controla as baleias
process(clk,reset,i_start)
variable icp : integer range 1 to NP := 1;
variable icd : integer range 1 to ND := 1;
begin
if rising_edge(clk) then
   if reset='1' then
       state <= waiting;
       --Resetar os sinais necessarios dps
   else

		case state is 
			when waiting =>
				if i_start = '1' then
					s_start_lfsr_px <= '1';
               icp             := 1;
               icd             := 1;
               state 		    <= init_x;
				else 
					state <= waiting;
				end if;

			when init_x =>
				s_start_lfsr_px <= '0';
				if s_ready_lfsr_px = '1' then
					 s_nx(icp,icd) <= s_lfsr_out_px;
					 if icd = ND then
						  if icp = NP then
								icp   := 1;
								icd   := 1;
								s_start_eval <= '1';								
								state <= fitness_x;
						  else
								icd := 1;
								icp := icp + 1;
								s_start_lfsr_px <= '1';
								state <= init_x;
						  end if;
					 else						
						  icd := icd + 1;
						  s_start_lfsr_px <= '1';
						  state <= init_x;
					 end if;
				else 
					state <= init_x;
				end if;

			when fitness_x =>
				s_start_eval <= '0';
				s_start_inertia <= '0';
				if fready_eval(1) = '1' then
					 s_start_cmp_baleia <= '1';
					 state <= verifica_best_fitness;						
				else 
					state <= fitness_x;
				end if;
				
			when verifica_best_fitness =>
				s_start_cmp_baleia <= '0';
				
				if s_ready_cmp_baleia = '1' then
					pstart <= '1'; -- Inicia a atualizacao de posicao
					state <= updatep;
				end if;
				
			when updatep =>
				pstart <= '0';
				if pready(1) = '1' then
					state <= waiting;
					s_start_inertia <= '1'; -- aqui faz a azinho decrementar
				end if;
									
				
			
			when others => 
				state <= waiting;
				
       end case;
   end if;
end if;
end process;	

end rlt;