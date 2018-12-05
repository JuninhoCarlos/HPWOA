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
		i_start		: 	in std_logic;
		best_fitness: 	out std_logic_vector(FP_WIDTH-1 downto 0);
      ready			:  out std_logic
	);
end HPWOA;

architecture rlt of HPWOA is


type   t_state is (waiting,init_x,fitness_x,verifica_best_fitness,updatep, wait_rand);
signal state : t_state;

--Sinal que indica o inicio do algoritmo

signal countIter		: integer range 0 to numIter := 0;
signal lock_iter : std_logic := '0';


--Sinais do gerador de números aleatorio para inicializacao das baleias
signal s_start_lfsr_px	: std_logic := '0';
signal s_lfsr_out_px 	: std_logic_vector(FP_WIDTH-1 downto 0) := (others => '0');
signal s_ready_lfsr_px 	: std_logic := '0';


--Sinal que armazena as posições das partículas para function evaluation
type matrix2D is array (1 to NP, 1 to ND) of std_logic_vector(FP_WIDTH-1 downto 0);
signal s_nx : matrix2D;



type matriz1D is array (1 to NP) of std_logic_vector(FP_WIDTH-1 downto 0);
signal fout : matriz1D; --Sinal que possui o valor da função fitness para cada baleia

--gera os p para o sorteio
signal p_sorteio : matriz1D;
signal start_lfsr_p : std_logic;
signal ready_lfsr_p : std_logic_vector(1 to NP);

type matrizPos is array (1 to ND) of std_logic_vector(FP_WIDTH-1 downto 0);
signal leader_pos    : matrizPos;
signal leader_score 	: std_logic_vector(FP_WIDTH-1 downto 0) := Inf;

type arrayPstart is array (1 to NP) of std_logic_vector(2 downto 0);
signal pstart : arrayPstart;

signal pready : std_logic_vector(1 to NP);

signal muxAtualizaPos : std_logic_vector(1 to NP);

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

--Sinais para calculo do a2
signal new_a2 				: std_logic_vector(FP_WIDTH-1 downto 0);
signal ready_a2			: std_logic;

signal best_baleia_from_mux : matriz1D;

signal pos_atual_whale  : matriz1D;
signal pos_rand_whale 	: matriz1D;
signal new_pos				: matriz1D;
signal pos_best_whale 	: std_logic_vector(FP_WIDTH-1 downto 0);

--Sinais para gerar o X_rand da fase exploração
type mux1D is array (1 to NP) of std_logic_vector(NUM_BITS-1 downto 0);


signal s_start_rand	 	: std_logic := '0'; -- inicia o calculo de todos os x_rand em paralelo
signal s_out_rand_whale : mux1D;
signal ready_rand_whale	: std_logic_vector(1 to NP);

signal andPready	: std_logic;

begin

best_fitness <= leader_score;

-- Instanciação de componentes
rand_px: lfsr_px
   port map (reset         => reset,
             clk           => clk,
             start         => s_start_lfsr_px,
             init 		    => init_random,
             lfsr_out      => s_lfsr_out_px,
             ready         => s_ready_lfsr_px);

p_generator: for I in 1 to NP generate
	p_sort: lfsr_fixtofloat_20bits   port map (
				reset         => reset,
            clk           => clk,
            start         => start_lfsr_p,
            init          => init_p(I),
            lfsr_out      => p_sorteio(I),
				ready			=> ready_lfsr_p(I)
	);
end generate;
				 
--Rand whale
rand_generator: for I in 1 to NP generate
	rand_generator: lfsr_select_whale port map(
		reset     => reset,
		clk       => clk,
		start     => s_start_rand,
		init      => init_p(I),
		lfsr_out  => s_out_rand_whale(I),
		ready     => ready_rand_whale(I)
  );
end generate;

				 
--Instancia as 10 (NP) baleias e faz o port map
whale: for I in 1 to NP generate
	whale : sphere_whale port map(
		reset    		=> reset,
      clk      		=> clk,
      pstart   		=> pstart(I),
		init_1     		=> init_p(I),
		init_2			=> init_p(2),
      a   				=> new_a,
		a2					=> new_a2,
      pos_act  		=> pos_atual_whale(I),
      pos_best_whale	=> pos_best_whale,
		pos_rand_whale => pos_rand_whale(I),
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
	generic map(
		INITIAL_VALUE => INITIAL_A_MINUSCULO,
		SLOPE => A_SLOPE
	)
	port map (
		reset    		=> reset,
		clk      		=> clk,
		start		   	=> s_start_inertia,
		new_weight  	=> new_a,
		ready_inerti	=> ready_inertia
	);

a2: a_minusculo
	generic map(
		INITIAL_VALUE 	=> INITIAL_A2,
		SLOPE 			=> A2_SLOPE
	)
	port map(
		reset => reset,
		clk 	=> clk,
		start	=> s_start_inertia,
		new_weight => new_a2,
		ready_inerti => ready_a2
	);
								 
--Máquina de estados que controla as baleias
process(clk,reset,i_start)
variable icp : integer range 1 to NP := 1;
variable icd : integer range 1 to ND := 1;
begin
if rising_edge(clk) then
   if reset='1' then
       state <= waiting;
		 s_start_rand 		<= '0';
		 s_start_lfsr_px 	<= '0';
		 s_start_eval <= '0';
		 s_start_inertia <= '0';
		 s_start_cmp_baleia <= '0';
		 
		 start_lfsr_p <= '0';
		 
		 for I in 1 to NP loop
			pos_atual_whale(I) <= (others => '0');
			pstart(I) <= "000"; 
		 end loop;
       
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
					 s_start_rand <= '1'; --Manda gerar o aleatorio para selecionar a baleia quando |A| > 1
					 start_lfsr_p <= '1'; --Manda sortear como vai ser a atualizacao da proxima iteracao
					 state <= verifica_best_fitness;						
				else 
					state <= fitness_x;
				end if;
				
			when verifica_best_fitness =>
				s_start_cmp_baleia <= '0';
				s_start_rand <= '0'; -- O valor vai ficar armazenado no registrador s_out_rand_whale
				start_lfsr_p <= '0'; -- Os valores do sorteio vai estar no registrador de saida do lfsr_p
				
				if s_ready_cmp_baleia = '1' then
					
					icd := 1;
					
					pos_atual_whale(1) <= s_nx(1,1);
					pos_atual_whale(2) <= s_nx(2,1);
					pos_atual_whale(3) <= s_nx(3,1);
					pos_atual_whale(4) <= s_nx(4,1);
					pos_atual_whale(5) <= s_nx(5,1);
					pos_atual_whale(6) <= s_nx(6,1);
					pos_atual_whale(7) <= s_nx(7,1);
					pos_atual_whale(8) <= s_nx(8,1);
					pos_atual_whale(9) <= s_nx(9,1);
					pos_atual_whale(10) <= s_nx(10,1);
					
					--Faz isso pq nesse ciclo não vai ter dado tempo de escrever no registrador leader_pos, então faz o forward do dado que vai pra ele
					if  (fitness_best_baleia < leader_score) then
						pos_best_whale <= best_baleia_from_mux(1); --x1 da melhor baleias, no proximos estados ler de leader_pos (registrador)
					else
						pos_best_whale <= leader_pos(1);
					end if;
					
					if countIter = numIter then
						
						for I in 1 to NP loop --Multiplexador para selecionar a forma de atualizacao da particula
							pstart(I) <= "000";
						end loop;
						
						state <= waiting;						
					else
						
						for I in 1 to NP loop
							if muXAtualizaPos(I) = '0' then
								pstart(I) <= "001"; -- Inicia a atualizacao de posicao calculando A e C
							else
								pstart(I) <= "011"; -- Inicia a atualizacao de posição em espiral calculando L
							end if;							
						end loop;						
						state <= updatep;
					end if;
				end if;
				
			when updatep =>
			
				for I in 1 to NP loop
					pstart(I) <= "000";
				end loop;
				
				
--				if pready(1) = '1' then

				if andPready = '1' then
				
					--Atualizacao das dimensões das baleias para cada dimensão
					for I in 1 to NP loop
						s_nx(I,icd)  <= new_pos(I);
					end loop;
					
					if icd = ND then
						icd := 1;
						s_start_inertia <= '1'; -- aqui faz a azinho decrementar
						s_start_eval <= '1';  
						
						for I in 1 to NP loop
							pstart(I) <= "101"; -- nop e zera ready
						end loop;
						state <= fitness_x;
					else
					
						icd := icd + 1;
						for I in 1 to NP loop
							pos_atual_whale(I)  <= s_nx(I,icd);
							pstart(I) <= "101"; -- nop e zera ready
						end loop;
					
						pos_best_whale <= leader_pos(icd);
						s_start_rand <= '1'; -- Manda gerar a baleia aleatoria para a outra dimensão
						
						
						state <= wait_rand;
					end if;
					
					
				end if;
									
			when wait_rand => 
				--Numero aleatorio fica pronto em 1 ciclo;
				s_start_rand <= '0';
				
				for I in 1 to NP loop
					if muxAtualizaPos(I) = '0' then
						pstart(I) <= "010"; -- atualizacao da posicao usando A e C ja calculado da dimensao 1
					else
						pstart(I) <= "100"; --atualiza usando espiral e L register
					end if;					
				end loop;
				
				
				state <= updatep;		
				
			when others => 
				state <= waiting;
				
       end case;
   end if;
end if;
end process;	


andPready <= pready(1) and pready(2) and pready(3) and pready(4) and pready(5) and pready(6) and pready(7) and pready(8) and pready(9) and pready(10);

--Processo para informar se a baleia vai atualizar usando o espiral ou não
seleciona_atualizacao: for I in 1 to NP generate
process(ready_lfsr_p(I),p_sorteio(I))
begin
	if p_sorteio(I) < s_meio then
		muxAtualizaPos(I) <= '0'; --Atualização sem ser em espiral
	else -- Espiral
		muxAtualizaPos(I) <= '1'; --Atualização em espiral
	end if;
end process;
end generate;

process(reset,clk,i_start,s_ready_cmp_baleia)
begin
if rising_edge(clk) then
	if reset = '1' then
		countIter <= 0;
		lock_iter <= '0';
		ready <= '0';
	else
		if i_start = '1' then
			countIter <= 0;
         lock_iter <= '0';
			ready <= '0';
		elsif s_ready_cmp_baleia = '1' and lock_iter='0' then
			countIter <= countIter+1;
         lock_iter <= '0';
			ready <= '0';
		elsif countIter = numIter then
			countIter <= numIter;
			lock_iter <= '1';
			ready <= '1';
		end if;
	end if;
end if;
end process;


--Processo para atualização da melhor baleia 
process(clk, s_ready_cmp_baleia)
begin
	if rising_edge(clk) and s_ready_cmp_baleia = '1' then
		if fitness_best_baleia < leader_score then --melhor baleia teve seu valor melhorado
			leader_score <= fitness_best_baleia;
			leader_pos(1) <= best_baleia_from_mux(1);
			leader_pos(2) <= best_baleia_from_mux(2);
			leader_pos(3) <= best_baleia_from_mux(3);
			leader_pos(4) <= best_baleia_from_mux(4);
			leader_pos(5) <= best_baleia_from_mux(5);
			leader_pos(6) <= best_baleia_from_mux(6);
		end if;
	end if;
end process;


--Mux que seleciona a melhor baleia para cada dimensão
mux_best_whale: for I in 1 to ND generate
process(s_ready_cmp_baleia)
begin
	case best_baleia is
		when "0000" => best_baleia_from_mux(I) <= s_nx(1,I);
		when "0001" => best_baleia_from_mux(I) <= s_nx(2,I);
		when "0010" => best_baleia_from_mux(I) <= s_nx(3,I);
		when "0011" => best_baleia_from_mux(I) <= s_nx(4,I);
		when "0100" => best_baleia_from_mux(I) <= s_nx(5,I);
		when "0101" => best_baleia_from_mux(I) <= s_nx(6,I);
		when "0110" => best_baleia_from_mux(I) <= s_nx(7,I);
		when "0111" => best_baleia_from_mux(I) <= s_nx(8,I);
		when "1000" => best_baleia_from_mux(I) <= s_nx(9,I);
		when "1001" => best_baleia_from_mux(I) <= s_nx(10,I);
		when others => best_baleia_from_mux(I) <= s_nx(1,I);	
	end case;
end process;
end generate;

--Multiplexadores que manda a baleia aleatoria da fase de explocação
muxes_rand_whale : for I in 1 to NP generate
	with s_out_rand_whale(I) select
		pos_rand_whale(I) <= pos_atual_whale(1)  when "0000",
									pos_atual_whale(2)  when "0001",
									pos_atual_whale(3)  when "0010",
									pos_atual_whale(4)  when "0011",
									pos_atual_whale(5)  when "0100",
									pos_atual_whale(6)  when "0101",
									pos_atual_whale(7)  when "0110",
									pos_atual_whale(8)  when "0111",
									pos_atual_whale(9)  when "1000",
									pos_atual_whale(10) when others;
									
end generate;		

end rlt;