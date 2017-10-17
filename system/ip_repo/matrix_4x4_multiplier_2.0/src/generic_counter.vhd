--author     :broquet.antonin@gmail.com
--date       :06/10/2017
--file       :generic_counter.vhd
--description:generic counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter is
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
end entity;

architecture rtl of generic_counter is

  signal cnt_int : unsigned(cnt_o'range);
  constant cnt_max : unsigned(cnt_o'range) := (others => '1');

begin

  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        cnt_int <= (others => '0');
        ofw_o <= '0';
      else
        if ena_i = '1' then
          cnt_int <= cnt_int + 1;
          if cnt_int = cnt_max then
            ofw_o <= '1';
          end if;
        end if;
        if clr_i = '1' then
          cnt_int <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  cnt_o <= std_logic_vector(cnt_int);

end architecture;

      
