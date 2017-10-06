--author     :broquet.antonin@gmail.com
--date       :05/10/2017
--file       :tb_top_m4x4_mult.vhd
--description:testbench of top of matrix 4x4 multiplier

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.m4x4_mult_pkg.all;

entity tb_top_m4x4_mult is
end entity;

architecture Behavorial of tb_top_m4x4_mult is

  constant clk_period : time := 4 ns;

  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal inhibit_i : std_logic;
  signal start_i : std_logic;
  signal row_i   : std_logic_vector(7 downto 0);
  signal col_i   : std_logic_vector(7 downto 0);
  signal done_o : std_logic;
  signal matc_o : std_logic_vector(17 downto 0);

begin

  uut:top_m4x4_mult
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      inhibit_i => inhibit_i,
      start_i => start_i,
      row_i => row_i,
      col_i => col_i,
      done_o => done_o,
      matc_o => matc_o
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
    inhibit_i <= '1';
    start_i <= '0';
    row_i <= X"FF";
    col_i <= X"FF";
    wait for 13 ns;
    rst_i <= '1';
    wait for 52 ns;
    rst_i <= '0';
    wait for 72 ns;
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';
    inhibit_i <= '0';
    wait for 123 ns;
    row_i <= X"80";
    col_i <= X"80";
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';
    wait for 53 ns;
    rst_i <= '1';
    wait for 23 ns;
    rst_i <= '0';


    wait;
  end process;

end architecture;
