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

  -- 1D vector containing output matrix rows elements (order: [E00,E01,E02,E03]
  -- or [E10,E11,E12,E13], etc...)
  type mat_1x4_18bits is array (3 downto 0) of std_logic_vector(17 downto 0);

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

  component m4x4_mult is
    generic (
      g_simulation : boolean := false
    );
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
  end component;

  component top_m4x4_mult is
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
  end component;

  component debouncer is
    generic (
      g_stability_counter_max : integer := 1000000; -- 10ms for 100MHz system frequency
      g_stability_counter_width : integer := 20 -- ln(1000000)/ln(2) + 1
      );
    port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      button_i : in  std_logic;
      button_o : out std_logic
      );
  end component;

end package;
