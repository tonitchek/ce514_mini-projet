--author     :broquet.antonin@gmail.com
--date       :04/10/2017
--file       :tb_m4x4_ele_macc.vhd
--description:test bench of m4x4_ele_macc

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.m4x4_mult_pkg.all;

entity tb_m4x4_ele_macc is
end entity;

architecture Behavorial of tb_m4x4_ele_macc is

  constant clk_period : time := 4 ns;
  
  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal acc_i : std_logic;
  signal row_i : mat_1x4_8bits := (X"02",X"06",X"FF",X"0F");
  signal col_i : mat_1x4_8bits := (X"03",X"80",X"FF",X"0F");
  signal ele_macc_o : std_logic_vector(17 downto 0);
  
begin

  uut:m4x4_ele_macc
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      acc_i => acc_i,
      row_i => row_i,
      col_i => col_i,
      ele_macc_o => ele_macc_o
      );

  clock:process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  stimuli:process
  begin
    rst_i <= '0';
    acc_i <= '0';
    wait for 13 ns;
    rst_i <= '1';
    wait for 53 ns;
    rst_i <= '0';
    wait for 138 ns;
    acc_i <= '1';
    wait for clk_period;
    acc_i <= '0';

    wait;
  end process;

end architecture;
