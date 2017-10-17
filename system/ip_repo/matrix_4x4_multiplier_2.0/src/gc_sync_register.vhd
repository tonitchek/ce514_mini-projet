library ieee;
use ieee.std_logic_1164.all;

entity gc_sync_register is
  generic (
    g_width : integer := 32);
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    d_i   : in  std_logic_vector(g_width-1 downto 0);
    q_o   : out std_logic_vector(g_width-1 downto 0));
end gc_sync_register;


architecture rtl of gc_sync_register is

  signal sync0 : std_logic_vector(g_width-1 downto 0);
  signal sync1 : std_logic_vector(g_width-1 downto 0);
  signal sync2 : std_logic_vector(g_width-1 downto 0);

begin

  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        sync0 <= (others => '0');
        sync1 <= (others => '0');
        sync2 <= (others => '0');
      else
        sync0 <= d_i;
        sync1 <= sync0;
        sync2 <= sync1;
      end if;
    end if;
  end process;

  q_o <= sync2;

end architecture;
