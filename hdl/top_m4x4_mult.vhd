--author     :broquet.antonin@gmail.com
--date       :05/10/2017
--file       :top_m4x4_mult.vhd
--description:top of matrix 4x4 multiplier

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.m4x4_mult_pkg.all;

entity top_m4x4_mult is
  port (
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;
    inhibit_i : in  std_logic;
    start_i   : in  std_logic;
    row_i     : in  std_logic_vector(7 downto 0);
    col_i     : in  std_logic_vector(7 downto 0);
    done_o    : out std_logic;
    matc_o    : out std_logic_vector(17 downto 0)
    );
end entity;

architecture rtl of top_m4x4_mult is

--  signal mata_rows_in   : mat_4x4_8bits := ((X"FF",X"FF",X"FF",X"FF"),
--                                            (X"FF",X"FF",X"FF",X"FF"),
--                                            (X"FF",X"FF",X"FF",X"FF"),
--                                            (X"FF",X"FF",X"FF",X"FF"));
--  signal matb_cols_in   : mat_4x4_8bits := ((X"FF",X"FF",X"FF",X"FF"),
--                                            (X"FF",X"FF",X"FF",X"FF"),
--                                            (X"FF",X"FF",X"FF",X"FF"),
--                                            (X"FF",X"FF",X"FF",X"FF"));
  signal mata_rows_in   : mat_4x4_8bits;
  signal matb_cols_in   : mat_4x4_8bits;
  signal matc_rows0_out : mat_1x4_18bits;
  signal matc_rows1_out : mat_1x4_18bits;
  signal matc_rows2_out : mat_1x4_18bits;
  signal matc_rows3_out : mat_1x4_18bits;

begin

  rows:for I in 0 to 3 generate
    cols:for J in 0 to 3 generate
      mata_rows_in(I,J) <= row_i;
      matb_cols_in(I,J) <= col_i;
    end generate cols;
  end generate rows;
  
  mult:m4x4_mult
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      inhibit_i => inhibit_i,
      start_i => start_i,
      mata_rows_i => mata_rows_in,
      matb_cols_i => matb_cols_in,
      matc_rows0_o => matc_rows0_out,
      matc_rows1_o => matc_rows1_out,
      matc_rows2_o => matc_rows2_out,
      matc_rows3_o => matc_rows3_out,
      done_o => done_o
      );

  matc_o <= matc_rows0_out(0) and matc_rows0_out(1) and matc_rows0_out(2) and matc_rows0_out(3) and
            matc_rows1_out(0) and matc_rows1_out(1) and matc_rows1_out(2) and matc_rows1_out(3) and
            matc_rows2_out(0) and matc_rows2_out(1) and matc_rows2_out(2) and matc_rows2_out(3) and
            matc_rows3_out(0) and matc_rows3_out(1) and matc_rows3_out(2) and matc_rows3_out(3);

end architecture;
