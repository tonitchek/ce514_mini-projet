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
  signal mata_rows_i  : mat_4x4_8bits := ((X"5A",X"2B",X"A7",X"43"),
                                          (X"80",X"20",X"0A",X"F7"),
                                          (X"5A",X"36",X"4E",X"02"),
                                          (X"CA",X"17",X"38",X"FF"));
  signal matb_cols_i  : mat_4x4_8bits := ((X"01",X"4E",X"0F",X"EA"),
                                          (X"40",X"EA",X"0A",X"08"),
                                          (X"00",X"02",X"C4",X"38"),
                                          (X"08",X"17",X"02",X"04"));
  signal matc_rows0_o : mat_1x4_18bits;
  signal matc_rows1_o : mat_1x4_18bits;
  signal matc_rows2_o : mat_1x4_18bits;
  signal matc_rows3_o : mat_1x4_18bits;

  signal ena_timer_i : std_logic;
  signal clr_timer_i : std_logic;
  signal aut_timer_i : std_logic;
  signal ena_timer   : std_logic;
  signal clr_timer   : std_logic;
  signal timer_cnt   : std_logic_vector(31 downto 0);

  component generic_counter is
    generic (
      g_width : integer := 32
      );
    port (
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      ena_i : in  std_logic;
      clr_i : in  std_logic;
      ofw_o : out std_logic;
      cnt_o : out std_logic_vector(g_width - 1 downto 0)
      );
  end component;

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

  clr_timer <= start_i when aut_timer_i = '1' else clr_timer_i;
  ena_timer <= not done_o when aut_timer_i = '1' else ena_timer_i;
  
  uut2:generic_counter
    generic map (
      g_width => 32
      )
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      ena_i => ena_timer,
      clr_i => clr_timer,
      ofw_o => open,
      cnt_o => timer_cnt
      );

  
  clock:process
  begin
    clk_i <= '1';
    wait for clk_period/2;
    clk_i <= '0';
    wait for clk_period/2;
  end process;

  stimuli:process
  begin
    rst_i <= '0';
    inhibit_i <= '1';
    start_i <= '0';
    ena_timer_i <= '0';
    clr_timer_i <= '0';
    aut_timer_i <= '0';
    wait for 11 ns;
    rst_i <= '1';
    wait for 52 ns;
    rst_i <= '0';
    wait for 73 ns;
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';
    inhibit_i <= '0';
    wait for 123 ns;
    ena_timer_i <= '1';
    wait for 133 ns;
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';
    wait for 23 ns;
    ena_timer_i <= '0';
    wait for 135 ns;
    clr_timer_i <= '1';
    wait for clk_period;
    clr_timer_i <= '0';
    wait for 48 ns;
    aut_timer_i <= '1';
    wait for 78 ns;
    start_i <= '1';
    wait for clk_period;
    start_i <= '0';
    wait for 172 ns;
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
