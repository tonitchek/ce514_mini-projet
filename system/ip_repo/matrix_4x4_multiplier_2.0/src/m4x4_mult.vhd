--author     :broquet.antonin@gmail.com
--date       :03/10/2017
--file       :m4x4_mult.vhd
--description:matrix 4x4 multiplier

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.m4x4_mult_pkg.all;

entity m4x4_mult is
  port (
    clk_i        : in  std_logic;
    rst_i        : in  std_logic;
    inhibit_i    : in  std_logic;
    start_i      : in  std_logic;
    mata_rows_i  : in  mat_4x4_8bits;
    matb_cols_i  : in  mat_4x4_8bits;
    matc_rows0_o : out mat_1x4_18bits;
    matc_rows1_o : out mat_1x4_18bits;
    matc_rows2_o : out mat_1x4_18bits;
    matc_rows3_o : out mat_1x4_18bits;
    done_o       : out std_logic
    );
end entity;

architecture rtl of m4x4_mult is

  type stmac is (idle, acc, done);
  signal state   : stmac;
  signal acc_int : std_logic;

begin

  row_0:for I in 0 to 3 generate
    macc_r0:m4x4_ele_macc
      port map (
        clk_i => clk_i,
        rst_i => rst_i,
        acc_i => acc_int,
        row_i(0) => mata_rows_i(0,0),
        row_i(1) => mata_rows_i(0,1),
        row_i(2) => mata_rows_i(0,2),
        row_i(3) => mata_rows_i(0,3),
        col_i(0) => matb_cols_i(I,0),
        col_i(1) => matb_cols_i(I,1),
        col_i(2) => matb_cols_i(I,2),
        col_i(3) => matb_cols_i(I,3),
        ele_macc_o => matc_rows0_o(I)
        );
  end generate row_0;

  row_1:for I in 0 to 3 generate
    macc_r1:m4x4_ele_macc
      port map (
        clk_i => clk_i,
        rst_i => rst_i,
        acc_i => acc_int,
        row_i(0) => mata_rows_i(1,0),
        row_i(1) => mata_rows_i(1,1),
        row_i(2) => mata_rows_i(1,2),
        row_i(3) => mata_rows_i(1,3),
        col_i(0) => matb_cols_i(I,0),
        col_i(1) => matb_cols_i(I,1),
        col_i(2) => matb_cols_i(I,2),
        col_i(3) => matb_cols_i(I,3),
        ele_macc_o => matc_rows1_o(I)
        );
  end generate row_1;

  row_2:for I in 0 to 3 generate
    macc_r2:m4x4_ele_macc
      port map (
        clk_i => clk_i,
        rst_i => rst_i,
        acc_i => acc_int,
        row_i(0) => mata_rows_i(2,0),
        row_i(1) => mata_rows_i(2,1),
        row_i(2) => mata_rows_i(2,2),
        row_i(3) => mata_rows_i(2,3),
        col_i(0) => matb_cols_i(I,0),
        col_i(1) => matb_cols_i(I,1),
        col_i(2) => matb_cols_i(I,2),
        col_i(3) => matb_cols_i(I,3),
        ele_macc_o => matc_rows2_o(I)
        );
  end generate row_2;

  row_3:for I in 0 to 3 generate
    macc_r3:m4x4_ele_macc
      port map (
        clk_i => clk_i,
        rst_i => rst_i,
        acc_i => acc_int,
        row_i(0) => mata_rows_i(3,0),
        row_i(1) => mata_rows_i(3,1),
        row_i(2) => mata_rows_i(3,2),
        row_i(3) => mata_rows_i(3,3),
        col_i(0) => matb_cols_i(I,0),
        col_i(1) => matb_cols_i(I,1),
        col_i(2) => matb_cols_i(I,2),
        col_i(3) => matb_cols_i(I,3),
        ele_macc_o => matc_rows3_o(I)
        );
  end generate row_3;
  
  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        state <= idle;
        done_o <= '1';
        acc_int <= '0';
      else

        case state is
          when idle =>
            if start_i = '1' then
              if inhibit_i = '0' then
                done_o <= '0';
                state <= acc;
              else
                state <= idle;
              end if;
            else
              state <= idle;
            end if;

          when acc =>
            acc_int <='1';
            state <= done;

          when done =>
            done_o <= '1';
            acc_int <= '0';
            state <= idle;

          when others =>
            state <= idle;
            done_o <= '1';
        end case;
        
      end if;
    end if;
  end process;

end architecture;
