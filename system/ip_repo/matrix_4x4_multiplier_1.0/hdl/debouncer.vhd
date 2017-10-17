--author     :broquet.antonin@gmail.com
--date       :06/10/2017
--file       :debouncer.vhd
--description:debouncer for input button stability and synchronization

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
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
end entity;

architecture rtl of debouncer is

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

  signal button_sync0 : std_logic;
  signal button_sync1 : std_logic;
  signal button_switch_level : std_logic;
  signal ena_int : std_logic;
  signal cnt_int : std_logic_vector(g_stability_counter_width - 1 downto 0);

begin

  button_switch_level <= button_sync0 xor button_sync1;

  stability_counter:generic_counter
    generic map (
      g_width => g_stability_counter_width
      )
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      ena_i => ena_int,
      clr_i => button_switch_level,
      ofw_o => open,
      cnt_o => cnt_int
      );

  
  process(clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst_i = '1' then
        button_sync0 <= '0';
        button_sync1 <= '0';
        button_o   <= button_i; --debouncer is used for transition button
                                --state. So during reset, suppose no transition
                                --and get the input state
        ena_int <= '1'; -- counter always enable (counting)
      else
        button_sync0 <= button_i;
        button_sync1 <= button_sync0;
        if cnt_int = std_logic_vector(to_unsigned(g_stability_counter_max,g_stability_counter_width)) then
          button_o <= button_sync1;
        end if;
      end if;
    end if;
  end process;

end architecture;

