--author     :broquet.antonin@gmail.com
--date       :06/10/2017
--file       :tb_m4x4_mult.vhd
--description:testbench of matrix 4x4 multiplier

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

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
  signal mata_rows_i : mat_4x4_8bits;
--  signal mata_rows_i  : mat_4x4_8bits := ((X"5A",X"2B",X"A7",X"43"),
--                                          (X"80",X"20",X"0A",X"F7"),
--                                          (X"5A",X"36",X"4E",X"02"),
--                                          (X"CA",X"17",X"38",X"FF"));
  signal matb_cols_i  : mat_4x4_8bits := ((X"01",X"4E",X"0F",X"EA"),
                                          (X"40",X"EA",X"0A",X"08"),
                                          (X"00",X"02",X"C4",X"38"),
                                          (X"08",X"17",X"02",X"04"));
  signal matc_rows0_o : mat_1x4_18bits;
  signal matc_rows1_o : mat_1x4_18bits;
  signal matc_rows2_o : mat_1x4_18bits;
  signal matc_rows3_o : mat_1x4_18bits;

  constant matc_row_zero : mat_1x4_18bits := (others => (others => '0'));
  signal matc_row0_file : mat_1x4_18bits;
  signal matc_row1_file : mat_1x4_18bits;
  signal matc_row2_file : mat_1x4_18bits;
  signal matc_row3_file : mat_1x4_18bits;

  file stimul : text open read_mode is "/home/broquet/common/inpg/esisar/5APP/CE514_syst-on-chip/mini-projet/ce514_mini-projet/hdl/tb/tb_matrix.dat";

begin

  uut1:m4x4_mult
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
    clk_i <= '1';
    wait for clk_period/2;
    clk_i <= '0';
    wait for clk_period/2;
  end process;

  stimuli:process
    variable mat_row : line;
    variable element  : integer;
  begin
    -- READ matrrix A
    for I in 0 to 3 loop
      readline(stimul,mat_row);
      read(mat_row,element);
      report "A(I,0): " & integer'image(element);
      mata_rows_i(I,0) <= std_logic_vector(to_unsigned(element,8));
      read(mat_row,element);
      report "A(I,1): " & integer'image(element);
      mata_rows_i(I,1) <= std_logic_vector(to_unsigned(element,8));
      read(mat_row,element);
      report "A(I,2): " & integer'image(element);
      mata_rows_i(I,2) <= std_logic_vector(to_unsigned(element,8));
      read(mat_row,element);
      report "A(I,3): " & integer'image(element);
      mata_rows_i(I,3) <= std_logic_vector(to_unsigned(element,8));
    end loop;
    -- READ matrrix B
    for I in 0 to 3 loop
      readline(stimul,mat_row);
      read(mat_row,element);
      report "B(0,I): " & integer'image(element);
      matb_cols_i(0,I) <= std_logic_vector(to_unsigned(element,8));
      read(mat_row,element);
      report "B(1,I): " & integer'image(element);
      matb_cols_i(1,I) <= std_logic_vector(to_unsigned(element,8));
      read(mat_row,element);
      report "B(2,I): " & integer'image(element);
      matb_cols_i(2,I) <= std_logic_vector(to_unsigned(element,8));
      read(mat_row,element);
      report "B(3,I): " & integer'image(element);
      matb_cols_i(3,I) <= std_logic_vector(to_unsigned(element,8));
    end loop;
    -- READ matrrix C
    --ROW 0
    readline(stimul,mat_row);
    read(mat_row,element);
    report "C(0,0): " & integer'image(element);
    matc_row0_file(0) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(0,1): " & integer'image(element);
    matc_row0_file(1) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(0,2): " & integer'image(element);
    matc_row0_file(2) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(0,3): " & integer'image(element);
    matc_row0_file(3) <= std_logic_vector(to_unsigned(element,18));
    --ROW 1
    readline(stimul,mat_row);
    read(mat_row,element);
    report "C(1,0): " & integer'image(element);
    matc_row1_file(0) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(1,1): " & integer'image(element);
    matc_row1_file(1) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(1,2): " & integer'image(element);
    matc_row1_file(2) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(1,3): " & integer'image(element);
    matc_row1_file(3) <= std_logic_vector(to_unsigned(element,18));
    --ROW 2
    readline(stimul,mat_row);
    read(mat_row,element);
    report "C(2,0): " & integer'image(element);
    matc_row2_file(0) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(2,1): " & integer'image(element);
    matc_row2_file(1) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(2,2): " & integer'image(element);
    matc_row2_file(2) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(2,3): " & integer'image(element);
    matc_row2_file(3) <= std_logic_vector(to_unsigned(element,18));
    --ROW 3
    readline(stimul,mat_row);
    read(mat_row,element);
    report "C(3,0): " & integer'image(element);
    matc_row3_file(0) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(3,1): " & integer'image(element);
    matc_row3_file(1) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(3,2): " & integer'image(element);
    matc_row3_file(2) <= std_logic_vector(to_unsigned(element,18));
    read(mat_row,element);
    report "C(3,3): " & integer'image(element);
    matc_row3_file(3) <= std_logic_vector(to_unsigned(element,18));
    
    
    rst_i <= '0';
    inhibit_i <= '1';
    start_i <= '0';

    wait for 11 ns;
    rst_i <= '1';
    wait for 52 ns;
    rst_i <= '0';

    wait for 73 ns;
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';

    assert matc_rows0_o = matc_row_zero report "INHIBIT FAILED" severity ERROR;
    assert matc_rows1_o = matc_row_zero report "INHIBIT FAILED" severity ERROR;
    assert matc_rows2_o = matc_row_zero report "INHIBIT FAILED" severity ERROR;
    assert matc_rows3_o = matc_row_zero report "INHIBIT FAILED" severity ERROR;

    wait for 31 ns;
    inhibit_i <= '0';
    wait for 123 ns;
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';

    wait until done_o = '1';
    wait for clk_period;
    assert matc_rows0_o = matc_row0_file report "CALCUL FAILED" severity ERROR;
    assert matc_rows1_o = matc_row1_file report "CALCUL FAILED" severity ERROR;
    assert matc_rows2_o = matc_row2_file report "CALCUL FAILED" severity ERROR;
    assert matc_rows3_o = matc_row3_file report "CALCUL FAILED" severity ERROR;

    wait;
  end process;

end architecture;
