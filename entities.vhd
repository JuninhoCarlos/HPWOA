-------------------------------------------------
-- Company:       GRACO-UnB
-- Engineer:      DANIEL MAURICIO MU�OZ ARBOLEDA
-- 
-- Create Date:   06-Oct-2012 
-- Design name:   HPABC
-- Module name:   entities
-- Description:   package defining IO of the components
-- Automatically generated using the vHABCgen.m v1.0
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fpupack.all;
use work.woapack.all;

package Entities is

component a_minusculo is
	port(
		reset       : in  std_logic;
		clk      	  : in  std_logic;
		start		  : in  std_logic;		  
		new_weight  : out std_logic_vector(FP_WIDTH-1 downto 0);		  
		ready_inerti: out std_logic
	);
end component;

component cordic_exp is
	port(reset	:  in std_logic;
	     clk	:  in std_logic;
		 start	:  in std_logic;
		 Ain	:  in std_logic_vector(FP_WIDTH-1 downto 0);
		 exp    : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready  : out std_logic);
end component;


component cordic_sincos is
	port(reset	:  in std_logic;
	     clk	:  in std_logic;
		 start	:  in std_logic;
		 Ain	:  in std_logic_vector(FP_WIDTH-1 downto 0);
		 sin    : out std_logic_vector(FP_WIDTH-1 downto 0);
		 cos	: out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready  : out std_logic);
end component;

-- Essa unidade gera números aleatorios no range de [0,1]				 
component lfsr_fixtofloat_20bits	is
port (	
	reset     : in  std_logic;
	clk       : in  std_logic;
	start     : in  std_logic;
	init      : in  std_logic_vector(7 downto 0);	
	lfsr_out  : out std_logic_vector(FP_WIDTH-1 downto 0);
	ready     : out std_logic);
end component;

--Essa unidade sorteia uma das 10 baleias (utilizado na fase de exploração)
component lfsr_select_whale is
	port(reset     : in  std_logic;
	     clk       : in  std_logic;
		  start     : in  std_logic;
		  init      : in  std_logic_vector(7 downto 0);	
		  lfsr_out  : out std_logic_vector(NUM_BITS-1 downto 0);
		  ready     : out std_logic
		  );
end component;

component lfsr_px is
port (reset    :  in std_logic;
      clk      :  in std_logic;
      start	:  in std_logic;
      init     :  in std_logic_vector(7 downto 0);
      lfsr_out : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready    : out std_logic);
end component;

component addsubfsm_v6 is
port (reset     :  in std_logic;
      clk       :  in std_logic;
      op        :  in std_logic;
      op_a    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      op_b    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      start_i	 :  in std_logic;
      addsub_out : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready_as  : out std_logic);
end component;

component multiplierfsm_v2 is
port (reset     :  in std_logic;
      clk       :  in std_logic;
      op_a    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      op_b    	 :  in std_logic_vector(FP_WIDTH-1 downto 0);
      start_i	 :  in std_logic;
      mul_out   : out std_logic_vector(FP_WIDTH-1 downto 0);
      ready_mul : out std_logic);
end component;

component compara_baleias is
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
end component;

component sphere_whale is
	port (
		reset    		: in std_logic;
      clk      		: in std_logic;
      pstart   		: in std_logic_vector(2 downto 0);
      init_1     		: in std_logic_vector(7 downto 0);		--serve para gerar o número aleatório
      init_2			: in std_logic_vector(7 downto 0);
		a   				: in std_logic_vector(FP_WIDTH-1 downto 0);
		a2					: in std_logic_vector(FP_WIDTH-1 downto 0);
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
end component;


component decFP is
	port (reset     :  in std_logic;
		 clk        :  in std_logic;
		 start      :  in std_logic;
		 Xin        :  in std_logic_vector(FP_WIDTH-1 downto 0);
		 intX       : out std_logic_vector(EXP_WIDTH-1 downto 0);
		 decX       : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready      : out std_logic);
end component;

component decFP_quad is
	port (reset     :  in std_logic;
		 clk        :  in std_logic;
		 start      :  in std_logic;
		 Xin        :  in std_logic_vector(FP_WIDTH-1 downto 0);
		 quad       : out std_logic_vector(1 downto 0);
		 decX       : out std_logic_vector(FP_WIDTH-1 downto 0);
		 ready      : out std_logic);
end component;

end package;