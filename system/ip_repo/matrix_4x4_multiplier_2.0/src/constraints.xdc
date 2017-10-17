create_clock -period 10.000 -name s_axi_aclk -waveform {0.000 5.000} [get_ports s00_axi_aclk]

create_clock -period 4.000 -name clk_dsp -waveform {0.000 2.000} [get_ports CLK_DSP_I]

set_clock_groups -asynchronous -group [get_clocks clk_dsp] -group [get_clocks s_axi_aclk]
