--author     :broquet.antonin@gmail.com
--date       :04/10/2017
--file       :m4x4_ele_macc.vhd
--description:module processing row and column of input matrices to give
--            product matrix output element

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.m4x4_mult_pkg.all;

entity m4x4_ele_macc is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    acc_i      : in  std_logic;
    row_i      : in  mat_1x4_8bits;
    col_i      : in  mat_1x4_8bits;
    ele_macc_o : out std_logic_vector(17 downto 0)
    );
end entity;

architecture rtl of m4x4_ele_macc is

  constant zero : unsigned(17 downto 0) := (others => '0');
  type m1x4_16bits is array (3 downto 0) of std_logic_vector(15 downto 0);
  signal mult_int : m1x4_16bits;
  signal ele_macc_int : unsigned(17 downto 0);
  
begin

  mult_array:for I in 0 to 3 generate
    dsp48:mult_xilinx_dsp48
      generic map (
        g_dina_width => 8,
        g_dinb_width => 8,
        g_use_dsp48  => "yes"
        )
      port map (
        clk_i => clk_i,
        rst_i => rst_i,
        dina_i => row_i(I),
        dinb_i => col_i(I),
        dout_o => mult_int(I)
        );
  end generate mult_array;

  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        ele_macc_int <= (others => '0');
      else
        if acc_i = '1' then
          -- zero is added to extend 16bits to 18bits in order to prevent
          -- overflow
          ele_macc_int <= zero + unsigned(mult_int(0)) + unsigned(mult_int(1)) + unsigned(mult_int(2)) + unsigned(mult_int(3));
        end if;
      end if;
    end if;
  end process;

  ele_macc_o <= std_logic_vector(ele_macc_int);

end architecture;
