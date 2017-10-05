--author     :broquet.antonin@gmail.com
--date       :03/10/2017
--file       :tb_mult_xilinx_dsp48.vhd
--description:module multiplying 2 vectors of 8 bits using DSP48

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.m4x4_mult_pkg.all;

entity tb_mult_xilinx_dsp48 is
end entity;


architecture rtl of tb_mult_xilinx_dsp48 is

  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal dina_i : std_logic_vector(7 downto 0);
  signal dinb_i : std_logic_vector(7 downto 0);
  signal dout_o : std_logic_vector(15 downto 0);

begin

  uut:mult_xilinx_dsp48
    generic map (
      g_dina_width => 8,
      g_dinb_width => 8
      )
    port map(
      clk_i => clk_i,
      rst_i => rst_i,
      dina_i => dina_i,
      dinb_i => dinb_i,
      dout_o => dout_o
      );
  
  process
  begin
    clk_i <= '0';
    wait for 2 ns;
    clk_i <= '1';
    wait for 2 ns;
  end process;

  stimuli:process
  begin

    rst_i <= '0';
    dina_i <= "11111111"; --255
    dinb_i <= "11111111"; --255
    wait for 13 ns;
    rst_i <= '1';
    wait for 37 ns;
    rst_i <= '0';

    wait for 233 ns;
    dina_i <= "00000010"; --2
    dinb_i <= "00000011"; --3
    
    wait;
  end process;
  

end architecture;
