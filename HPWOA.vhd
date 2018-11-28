library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.entities.all;
use work.fpupack.all;
use work.woapack.all;

entity HPWOA is
	port (
		reset    :  in std_logic;
      clk      :  in std_logic;
		fout		: 	out std_logic_vector(FP_WIDTH-1 downto 0)
      
	);
end HPWOA;

architecture rlt of HPWOA is


type   t_state is (waiting,init_x,fitness_x,verifica_best_fitness,update_params,update_positions);
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


signal pstart : std_logic;
signal pready : std_logic;

--Sinais para avaliação de função custo na particula
signal s_start_eval : std_logic := '0'; --Sinal que sinaliza inicio de avaliação do fitness da função
signal fready_eval : std_logic := '0';


begin

-- Instanciação de componentes
rand_px: lfsr_px
   port map (reset         => reset,
             clk           => clk,
             start         => s_start_lfsr_px,
             init 		    => init_random,
             lfsr_out      => s_lfsr_out_px,
             ready         => s_ready_lfsr_px);

whale_1 : sphere_whale
	port map(
		reset    => reset,
      clk      => clk,
      pstart   => pstart,
      pready   => pready,

      fstart   => s_start_eval,
      x1_in    => s_nx(1,1),
      x2_in    => s_nx(1,2),
      x3_in    => s_nx(1,3),
      x4_in    => s_nx(1,4),
      x5_in    => s_nx(1,5),
      x6_in    => s_nx(1,6),
      f_out    => fout,
      fready   => fready_eval
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
--               s_start_inertia <= '0';
--               icd := 1;
               if fready_eval = '1' then
                   --s_start_cmpsc <= '1';
--                   state <= compara_soc;
						state <= waiting;
--               else state <= fitness_x;
               end if;
				when others => state <= waiting;
       end case;
   end if;
end if;
end process;	

end rlt;