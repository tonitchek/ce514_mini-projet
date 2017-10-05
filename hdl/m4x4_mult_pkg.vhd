--author     :broquet.antonin@gmail.com
--date       :03/10/2017
--file       :m4x4_mult_pkg.vhd
--description:package for matrix 4x4 multiplier

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package m4x4_mult_pkg is

  -- 2D array containing input matrix (4,4) elements 
  type mat_4x4_8bits is array (3 downto 0, 3 downto 0) of std_logic_vector(7 downto 0);
  type mat_1x4_8bits is array (3 downto 0) of std_logic_vector(7 downto 0);

  -- 1D vector containing outpu matrix elements (order: E00,E01,...,E33)
  type mat_1x16_18bits is array (15 downto 0) of std_logic_vector(17 downto 0);

  component mult_xilinx_dsp48 is
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
  end component;

  component m4x4_ele_macc is
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      acc_i      : in  std_logic;
      row_i      : in  mat_1x4_8bits;
      col_i      : in  mat_1x4_8bits;
      ele_macc_o : out std_logic_vector(17 downto 0)
      );
  end component;

end package;
