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
      init     :  in std_logic_vector(7 downto 0);
      weight   :  in std_logic_vector(FP_WIDTH-1 downto 0);
      pos_act  :  in std_logic_vector(FP_WIDTH-1 downto 0);
      best_ys  :  in std_logic_vector(FP_WIDTH-1 downto 0);
      best_yi  :  in std_logic_vector(FP_WIDTH-1 downto 0);
      new_pos  : out std_logic_vector(FP_WIDTH-1 downto 0);
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



begin
end rlt;