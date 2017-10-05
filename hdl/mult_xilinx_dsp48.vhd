--author     :broquet.antonin@gmail.com
--date       :03/10/2017
--file       :mult_xilinx_dsp48.vhd
--description:module multiplying 2 vectors of N bits infering dedicated xilinx
--component DSP48

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult_xilinx_dsp48 is
  generic (
    g_dina_width : integer := 8;
    g_dinb_width : integer := 8;
    g_use_dsp48  : string  := "yes"
    );
  port (
    clk_i  : in  std_logic;
    rst_i  : in  std_logic;
    dina_i : in  std_logic_vector((g_dina_width - 1) downto 0);
    dinb_i : in  std_logic_vector((g_dinb_width - 1) downto 0);
    dout_o : out std_logic_vector((g_dina_width + g_dinb_width - 1) downto 0)
    );
  attribute use_dsp48 : string;
  attribute use_dsp48 of mult_xilinx_dsp48 : entity is g_use_dsp48;
end entity;


architecture rtl of mult_xilinx_dsp48 is

  signal dout_int : unsigned((dina_i'length + dinb_i'length - 1) downto 0);
  signal dout_int1 : unsigned((dina_i'length + dinb_i'length - 1) downto 0);
  
begin

  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        dout_int <= (others => '0');
      else
        dout_int <= unsigned(dina_i) * unsigned(dinb_i);
        -- pipeline to meet timing constraint
        dout_int1 <= dout_int;
      end if;
    end if;
  end process;

  dout_o <= std_logic_vector(dout_int1);

end architecture;
