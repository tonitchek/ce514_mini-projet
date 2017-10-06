--author     :broquet.antonin@gmail.com
--date       :06/10/2017
--file       :tb_m4x4_mult.vhd
--description:testbench of matrix 4x4 multiplier

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.m4x4_mult_pkg.all;

entity tb_m4x4_mult is
end entity;

architecture Behavorial of tb_m4x4_mult is

  constant clk_period : time := 4 ns;

  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal inhibit_i : std_logic;
  signal start_i : std_logic;
  signal done_o : std_logic;
  signal mata_rows_i  : mat_4x4_8bits := ((X"FF",X"38",X"17",X"CA"),
                                          (X"02",X"4E",X"36",X"5A"),
                                          (X"F7",X"0A",X"20",X"80"),
                                          (X"43",X"A7",X"2B",X"5A"));
  signal matb_cols_i  : mat_4x4_8bits := ((X"04",X"02",X"17",X"08"),
                                          (X"38",X"C4",X"02",X"00"),
                                          (X"08",X"0A",X"EA",X"40"),
                                          (X"EA",X"0F",X"4E",X"01"));
  signal matc_rows0_o : mat_1x4_18bits;
  signal matc_rows1_o : mat_1x4_18bits;
  signal matc_rows2_o : mat_1x4_18bits;
  signal matc_rows3_o : mat_1x4_18bits;

begin

  uut:m4x4_mult
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      inhibit_i => inhibit_i,
      start_i => start_i,
      mata_rows_i  => mata_rows_i,
      matb_cols_i  => matb_cols_i,
      matc_rows0_o => matc_rows0_o,
      matc_rows1_o => matc_rows1_o,
      matc_rows2_o => matc_rows2_o,
      matc_rows3_o => matc_rows3_o,
      done_o => done_o
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
