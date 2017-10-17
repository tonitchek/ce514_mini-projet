library ieee;
use ieee.std_logic_1164.all;

entity gc_sync_monostable is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    d_i   : in  std_logic;
    q_o   : out std_logic);
end gc_sync_monostable;


architecture rtl of gc_sync_monostable is

  signal sync0 : std_logic;
  signal sync1 : std_logic;
  signal sync2 : std_logic;

begin

  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        sync0 <= '0';
        sync1 <= '0';
        sync2 <= '0';
      else
        sync0 <= d_i;
        sync1 <= sync0;
        sync2 <= sync1;
        q_o   <= not sync2 and sync1;
      end if;
    end if;
  end process;

end architecture;
