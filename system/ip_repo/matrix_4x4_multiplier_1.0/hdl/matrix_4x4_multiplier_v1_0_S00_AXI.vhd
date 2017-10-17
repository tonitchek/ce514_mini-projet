library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.m4x4_mult_pkg.all;

entity matrix_4x4_multiplier_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 8
	);
	port (
		-- Users to add ports here
          clk_250MHz_i : in std_logic;
          inhibit_i    : in std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end matrix_4x4_multiplier_v1_0_S00_AXI;

architecture arch_imp of matrix_4x4_multiplier_v1_0_S00_AXI is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 5;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 50
--	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	       : std_logic_vector(31 downto 0);
        signal slv_reg2_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg2_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg3	       : std_logic_vector(31 downto 0);
        signal slv_reg3_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg3_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg4	       : std_logic_vector(31 downto 0);
        signal slv_reg4_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg4_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg5	       : std_logic_vector(31 downto 0);
        signal slv_reg5_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg5_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg6	       : std_logic_vector(31 downto 0);
        signal slv_reg6_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg6_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg7	       : std_logic_vector(31 downto 0);
        signal slv_reg7_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg7_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg8	       : std_logic_vector(31 downto 0);
        signal slv_reg8_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg8_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg9	       : std_logic_vector(31 downto 0);
        signal slv_reg9_sync0  : std_logic_vector(31 downto 0);
        signal slv_reg9_sync1  : std_logic_vector(31 downto 0);
	signal slv_reg10       : std_logic_vector(31 downto 0);
        signal slv_reg10_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg10_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg11       : std_logic_vector(31 downto 0);
        signal slv_reg11_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg11_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg12       : std_logic_vector(31 downto 0);
        signal slv_reg12_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg12_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg13       : std_logic_vector(31 downto 0);
        signal slv_reg13_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg13_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg14       : std_logic_vector(31 downto 0);
        signal slv_reg14_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg14_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg15       : std_logic_vector(31 downto 0);
        signal slv_reg15_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg15_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg16       : std_logic_vector(31 downto 0);
        signal slv_reg16_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg16_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg17       : std_logic_vector(31 downto 0);
        signal slv_reg17_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg17_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg18       : std_logic_vector(31 downto 0);
        signal slv_reg18_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg18_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg19       : std_logic_vector(31 downto 0);
        signal slv_reg19_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg19_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg20       : std_logic_vector(31 downto 0);
        signal slv_reg20_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg20_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg21       : std_logic_vector(31 downto 0);
        signal slv_reg21_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg21_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg22       : std_logic_vector(31 downto 0);
        signal slv_reg22_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg22_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg23       : std_logic_vector(31 downto 0);
        signal slv_reg23_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg23_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg24       : std_logic_vector(31 downto 0);
        signal slv_reg24_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg24_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg25       : std_logic_vector(31 downto 0);
        signal slv_reg25_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg25_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg26       : std_logic_vector(31 downto 0);
        signal slv_reg26_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg26_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg27       : std_logic_vector(31 downto 0);
        signal slv_reg27_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg27_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg28       : std_logic_vector(31 downto 0);
        signal slv_reg28_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg28_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg29       : std_logic_vector(31 downto 0);
        signal slv_reg29_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg29_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg30       : std_logic_vector(31 downto 0);
        signal slv_reg30_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg30_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg31       : std_logic_vector(31 downto 0);
        signal slv_reg31_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg31_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg32       : std_logic_vector(31 downto 0);
        signal slv_reg32_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg32_sync1 : std_logic_vector(31 downto 0);
	signal slv_reg33       : std_logic_vector(31 downto 0);
        signal slv_reg33_sync0 : std_logic_vector(31 downto 0);
        signal slv_reg33_sync1 : std_logic_vector(31 downto 0);
--	signal slv_reg34	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg35	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg36	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg37	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg38	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg39	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg40	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg41	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg42	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg43	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg44	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg45	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg46	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg47	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg48	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg49	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden	  : std_logic;
	signal slv_reg_wren	  : std_logic;
	signal reg_data_out	  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	: std_logic;

        -- user declaration
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

        --reset active HIGH for user IP (AXI is active LOW)
        signal reset_h     : std_logic;
        signal reset_sync0 : std_logic := '0';
        signal reset_sync1 : std_logic := '0';
        --matrix mult
        signal start          : std_logic;
        signal mata_rows_in   : mat_4x4_8bits;
        signal matb_cols_in   : mat_4x4_8bits;
        signal matc_rows0_out : mat_1x4_18bits;
        signal matc_rows1_out : mat_1x4_18bits;
        signal matc_rows2_out : mat_1x4_18bits;
        signal matc_rows3_out : mat_1x4_18bits;
        signal done           : std_logic;
        --timer
        signal ena_timer       : std_logic;
        signal ena_timer_sync0 : std_logic;
        signal ena_timer_sync1 : std_logic;
        signal clear_timer     : std_logic;
        signal timer_cnt       : std_logic_vector(31 downto 0);
--        signal timer_cnt_sync0 : std_logic_vector(31 downto 0);
--        signal timer_cnt_sync1 : std_logic_vector(31 downto 0);
--        signal timer_cnt_sync2 : std_logic_vector(31 downto 0);
        --registers from slave (m4x4_mult) to master (processor)
        signal csr_start_int       : std_logic;
        signal csr_start_sync0     : std_logic;
        signal csr_start_sync1     : std_logic;
        signal csr_start_sync2     : std_logic;
        signal csr_ena_timer_int   : std_logic;
        signal csr_clr_timer_int   : std_logic;
        signal clr_timer           : std_logic;
        signal csr_clr_timer_sync0 : std_logic;
        signal csr_clr_timer_sync1 : std_logic;
        signal csr_clr_timer_sync2 : std_logic;
        signal csr_auto_timer_int  : std_logic;
        signal csr_out_reg         : std_logic_vector(31 downto 0);
        signal csr_out_reg_sync0   : std_logic_vector(31 downto 0);
        signal csr_out_reg_sync1   : std_logic_vector(31 downto 0);
        
        signal matout_e00_reg       : std_logic_vector(31 downto 0);
        signal matout_e00_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e00_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e01_reg       : std_logic_vector(31 downto 0);
        signal matout_e01_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e01_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e02_reg       : std_logic_vector(31 downto 0);
        signal matout_e02_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e02_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e03_reg       : std_logic_vector(31 downto 0);
        signal matout_e03_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e03_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e10_reg       : std_logic_vector(31 downto 0);
        signal matout_e10_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e10_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e11_reg       : std_logic_vector(31 downto 0);
        signal matout_e11_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e11_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e12_reg       : std_logic_vector(31 downto 0);
        signal matout_e12_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e12_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e13_reg       : std_logic_vector(31 downto 0);
        signal matout_e13_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e13_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e20_reg       : std_logic_vector(31 downto 0);
        signal matout_e20_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e20_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e21_reg       : std_logic_vector(31 downto 0);
        signal matout_e21_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e21_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e22_reg       : std_logic_vector(31 downto 0);
        signal matout_e22_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e22_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e23_reg       : std_logic_vector(31 downto 0);
        signal matout_e23_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e23_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e30_reg       : std_logic_vector(31 downto 0);
        signal matout_e30_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e30_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e31_reg       : std_logic_vector(31 downto 0);
        signal matout_e31_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e31_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e32_reg       : std_logic_vector(31 downto 0);
        signal matout_e32_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e32_reg_sync1 : std_logic_vector(31 downto 0);
        signal matout_e33_reg       : std_logic_vector(31 downto 0);
        signal matout_e33_reg_sync0 : std_logic_vector(31 downto 0);
        signal matout_e33_reg_sync1 : std_logic_vector(31 downto 0);

begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	        axi_awready <= '1';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	            aw_en <= '1';
	        	axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
              csr_start_int <= '0';
              csr_ena_timer_int <= '0';
              csr_clr_timer_int <= '0';
              csr_auto_timer_int <= '0';
--	      slv_reg0 <= (others => '0');
--	      slv_reg1 <= (others => '0');
	      slv_reg2 <= (others => '0');
	      slv_reg3 <= (others => '0');
	      slv_reg4 <= (others => '0');
	      slv_reg5 <= (others => '0');
	      slv_reg6 <= (others => '0');
	      slv_reg7 <= (others => '0');
	      slv_reg8 <= (others => '0');
	      slv_reg9 <= (others => '0');
	      slv_reg10 <= (others => '0');
	      slv_reg11 <= (others => '0');
	      slv_reg12 <= (others => '0');
	      slv_reg13 <= (others => '0');
	      slv_reg14 <= (others => '0');
	      slv_reg15 <= (others => '0');
	      slv_reg16 <= (others => '0');
	      slv_reg17 <= (others => '0');
	      slv_reg18 <= (others => '0');
	      slv_reg19 <= (others => '0');
	      slv_reg20 <= (others => '0');
	      slv_reg21 <= (others => '0');
	      slv_reg22 <= (others => '0');
	      slv_reg23 <= (others => '0');
	      slv_reg24 <= (others => '0');
	      slv_reg25 <= (others => '0');
	      slv_reg26 <= (others => '0');
	      slv_reg27 <= (others => '0');
	      slv_reg28 <= (others => '0');
	      slv_reg29 <= (others => '0');
	      slv_reg30 <= (others => '0');
	      slv_reg31 <= (others => '0');
	      slv_reg32 <= (others => '0');
	      slv_reg33 <= (others => '0');
--	      slv_reg34 <= (others => '0');
--	      slv_reg35 <= (others => '0');
--	      slv_reg36 <= (others => '0');
--	      slv_reg37 <= (others => '0');
--	      slv_reg38 <= (others => '0');
--	      slv_reg39 <= (others => '0');
--	      slv_reg40 <= (others => '0');
--	      slv_reg41 <= (others => '0');
--	      slv_reg42 <= (others => '0');
--	      slv_reg43 <= (others => '0');
--	      slv_reg44 <= (others => '0');
--	      slv_reg45 <= (others => '0');
--	      slv_reg46 <= (others => '0');
--	      slv_reg47 <= (others => '0');
--	      slv_reg48 <= (others => '0');
--	      slv_reg49 <= (others => '0');
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is
	          when b"000000" =>
                    csr_start_int <= S_AXI_WDATA(0);
                    csr_ena_timer_int <= S_AXI_WDATA(2);
                    csr_clr_timer_int <= S_AXI_WDATA(3);
                    csr_auto_timer_int <= S_AXI_WDATA(4);
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 0
--	                slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"000001" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 1
--	                slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
	          when b"000010" =>
                    slv_reg2 <= S_AXI_WDATA;
	          when b"000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 3
	                slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 4
	                slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 5
	                slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 7
	                slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 8
	                slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 9
	                slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 10
	                slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 11
	                slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 12
	                slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 13
	                slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 14
	                slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 15
	                slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 16
	                slv_reg16(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 17
	                slv_reg17(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 18
	                slv_reg18(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 19
	                slv_reg19(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 20
	                slv_reg20(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 21
	                slv_reg21(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 22
	                slv_reg22(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 23
	                slv_reg23(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 24
	                slv_reg24(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 25
	                slv_reg25(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 26
	                slv_reg26(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 27
	                slv_reg27(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 28
	                slv_reg28(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 29
	                slv_reg29(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 30
	                slv_reg30(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 31
	                slv_reg31(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 32
	                slv_reg32(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 33
	                slv_reg33(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
--	          when b"100010" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 34
--	                slv_reg34(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"100011" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 35
--	                slv_reg35(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"100100" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 36
--	                slv_reg36(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"100101" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 37
--	                slv_reg37(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"100110" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 38
--	                slv_reg38(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"100111" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 39
--	                slv_reg39(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101000" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 40
--	                slv_reg40(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101001" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 41
--	                slv_reg41(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101010" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 42
--	                slv_reg42(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101011" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 43
--	                slv_reg43(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101100" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 44
--	                slv_reg44(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101101" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 45
--	                slv_reg45(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101110" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 46
--	                slv_reg46(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"101111" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 47
--	                slv_reg47(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"110000" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 48
--	                slv_reg48(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"110001" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 49
--	                slv_reg49(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
	          when others =>
--	            slv_reg0 <= slv_reg0;
--	            slv_reg1 <= slv_reg1;
	            slv_reg2 <= slv_reg2;
	            slv_reg3 <= slv_reg3;
	            slv_reg4 <= slv_reg4;
	            slv_reg5 <= slv_reg5;
	            slv_reg6 <= slv_reg6;
	            slv_reg7 <= slv_reg7;
	            slv_reg8 <= slv_reg8;
	            slv_reg9 <= slv_reg9;
	            slv_reg10 <= slv_reg10;
	            slv_reg11 <= slv_reg11;
	            slv_reg12 <= slv_reg12;
	            slv_reg13 <= slv_reg13;
	            slv_reg14 <= slv_reg14;
	            slv_reg15 <= slv_reg15;
	            slv_reg16 <= slv_reg16;
	            slv_reg17 <= slv_reg17;
	            slv_reg18 <= slv_reg18;
	            slv_reg19 <= slv_reg19;
	            slv_reg20 <= slv_reg20;
	            slv_reg21 <= slv_reg21;
	            slv_reg22 <= slv_reg22;
	            slv_reg23 <= slv_reg23;
	            slv_reg24 <= slv_reg24;
	            slv_reg25 <= slv_reg25;
	            slv_reg26 <= slv_reg26;
	            slv_reg27 <= slv_reg27;
	            slv_reg28 <= slv_reg28;
	            slv_reg29 <= slv_reg29;
	            slv_reg30 <= slv_reg30;
	            slv_reg31 <= slv_reg31;
	            slv_reg32 <= slv_reg32;
	            slv_reg33 <= slv_reg33;
--	            slv_reg34 <= slv_reg34;
--	            slv_reg35 <= slv_reg35;
--	            slv_reg36 <= slv_reg36;
--	            slv_reg37 <= slv_reg37;
--	            slv_reg38 <= slv_reg38;
--	            slv_reg39 <= slv_reg39;
--	            slv_reg40 <= slv_reg40;
--	            slv_reg41 <= slv_reg41;
--	            slv_reg42 <= slv_reg42;
--	            slv_reg43 <= slv_reg43;
--	            slv_reg44 <= slv_reg44;
--	            slv_reg45 <= slv_reg45;
--	            slv_reg46 <= slv_reg46;
--	            slv_reg47 <= slv_reg47;
--	            slv_reg48 <= slv_reg48;
--	            slv_reg49 <= slv_reg49;
	        end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00";
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (csr_out_reg, timer_cnt, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, slv_reg10, slv_reg11, slv_reg12, slv_reg13, slv_reg14, slv_reg15, slv_reg16, slv_reg17, slv_reg18, slv_reg19, slv_reg20, slv_reg21, slv_reg22, slv_reg23, slv_reg24, slv_reg25, slv_reg26, slv_reg27, slv_reg28, slv_reg29, slv_reg30, slv_reg31, slv_reg32, slv_reg33, matout_e00_reg, matout_e01_reg, matout_e02_reg, matout_e03_reg, matout_e10_reg, matout_e11_reg, matout_e12_reg, matout_e13_reg, matout_e20_reg, matout_e21_reg, matout_e22_reg, matout_e23_reg, matout_e30_reg, matout_e31_reg, matout_e32_reg, matout_e33_reg, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	      when b"000000" =>
	        reg_data_out <= csr_out_reg;
	      when b"000001" =>
	        reg_data_out <= timer_cnt;
	      when b"000010" =>
	        reg_data_out <= slv_reg2;
	      when b"000011" =>
	        reg_data_out <= slv_reg3;
	      when b"000100" =>
	        reg_data_out <= slv_reg4;
	      when b"000101" =>
	        reg_data_out <= slv_reg5;
	      when b"000110" =>
	        reg_data_out <= slv_reg6;
	      when b"000111" =>
	        reg_data_out <= slv_reg7;
	      when b"001000" =>
	        reg_data_out <= slv_reg8;
	      when b"001001" =>
	        reg_data_out <= slv_reg9;
	      when b"001010" =>
	        reg_data_out <= slv_reg10;
	      when b"001011" =>
	        reg_data_out <= slv_reg11;
	      when b"001100" =>
	        reg_data_out <= slv_reg12;
	      when b"001101" =>
	        reg_data_out <= slv_reg13;
	      when b"001110" =>
	        reg_data_out <= slv_reg14;
	      when b"001111" =>
	        reg_data_out <= slv_reg15;
	      when b"010000" =>
	        reg_data_out <= slv_reg16;
	      when b"010001" =>
	        reg_data_out <= slv_reg17;
	      when b"010010" =>
	        reg_data_out <= slv_reg18;
	      when b"010011" =>
	        reg_data_out <= slv_reg19;
	      when b"010100" =>
	        reg_data_out <= slv_reg20;
	      when b"010101" =>
	        reg_data_out <= slv_reg21;
	      when b"010110" =>
	        reg_data_out <= slv_reg22;
	      when b"010111" =>
	        reg_data_out <= slv_reg23;
	      when b"011000" =>
	        reg_data_out <= slv_reg24;
	      when b"011001" =>
	        reg_data_out <= slv_reg25;
	      when b"011010" =>
	        reg_data_out <= slv_reg26;
	      when b"011011" =>
	        reg_data_out <= slv_reg27;
	      when b"011100" =>
	        reg_data_out <= slv_reg28;
	      when b"011101" =>
	        reg_data_out <= slv_reg29;
	      when b"011110" =>
	        reg_data_out <= slv_reg30;
	      when b"011111" =>
	        reg_data_out <= slv_reg31;
	      when b"100000" =>
	        reg_data_out <= slv_reg32;
	      when b"100001" =>
	        reg_data_out <= slv_reg33;
	      when b"100010" =>
	        reg_data_out <= matout_e00_reg;
	      when b"100011" =>
	        reg_data_out <= matout_e01_reg;
	      when b"100100" =>
	        reg_data_out <= matout_e02_reg;
	      when b"100101" =>
	        reg_data_out <= matout_e03_reg;
	      when b"100110" =>
	        reg_data_out <= matout_e10_reg;
	      when b"100111" =>
	        reg_data_out <= matout_e11_reg;
	      when b"101000" =>
	        reg_data_out <= matout_e12_reg;
	      when b"101001" =>
	        reg_data_out <= matout_e13_reg;
	      when b"101010" =>
	        reg_data_out <= matout_e20_reg;
	      when b"101011" =>
	        reg_data_out <= matout_e21_reg;
	      when b"101100" =>
	        reg_data_out <= matout_e22_reg;
	      when b"101101" =>
	        reg_data_out <= matout_e23_reg;
	      when b"101110" =>
	        reg_data_out <= matout_e30_reg;
	      when b"101111" =>
	        reg_data_out <= matout_e31_reg;
	      when b"110000" =>
	        reg_data_out <= matout_e32_reg;
	      when b"110001" =>
	        reg_data_out <= matout_e33_reg;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process; 

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;


	-- Add user logic here
  matrix_4x4_mult_inst:m4x4_mult
  generic map (
    g_simulation => false
  )
  port map (
    clk_i        => clk_250MHz_i,
    rst_i        => reset_h,
    inhibit_i    => inhibit_i,
    start_i      => start,
    mata_rows_i  => mata_rows_in,
    matb_cols_i  => matb_cols_in,
    matc_rows0_o => matc_rows0_out,
    matc_rows1_o => matc_rows1_out,
    matc_rows2_o => matc_rows2_out,
    matc_rows3_o => matc_rows3_out,
    done_o       => done
    );

  timer_inst:generic_counter
    generic map (
      g_width => 32
      )
    port map (
      clk_i => clk_250MHz_i,
      rst_i => reset_h,
      ena_i => ena_timer,
      clr_i => clear_timer,
      ofw_o => open,
      cnt_o => timer_cnt
      );

        --reset active high (AXI active low)
        reset_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if S_AXI_ARESETN ='0' then
              reset_sync0 <= '0';
              reset_sync1 <= '0';
              reset_h <='1';
            else
              reset_sync0 <= '0';
              reset_sync1 <= reset_sync0;
              reset_h <= reset_sync1;
            end if;
          end if;
        end process;

        --monstable in 250MHz domain of CSR start bit
        csr_start_monstable:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              start <= '0';
              csr_start_sync0 <= '0';
              csr_start_sync1 <= '0';
              csr_start_sync2 <= '0';
            else
              csr_start_sync0 <= csr_start_int;
              csr_start_sync1 <= csr_start_sync0;
              csr_start_sync2 <= csr_start_sync1;
              start <= csr_start_sync2 and (not csr_start_sync1);
            end if;
          end if;
        end process;

        --monstable in 250MHz domain of CSR clear timer bit
        csr_clr_monstable:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              clr_timer <= '0';
              csr_clr_timer_sync0 <= '0';
              csr_clr_timer_sync1 <= '0';
              csr_clr_timer_sync2 <= '0';
            else
              csr_clr_timer_sync0 <= csr_clr_timer_int;
              csr_clr_timer_sync1 <= csr_clr_timer_sync0;
              csr_clr_timer_sync2 <= csr_clr_timer_sync1;
              clr_timer <= csr_clr_timer_sync2 and (not csr_clr_timer_sync1);
            end if;
          end if;
        end process;

        --timer clear & enable
--        ena_timer <= (not done) when csr_auto_timer_int = '1' else csr_ena_timer_int;
--        clear_timer <= start when csr_auto_timer_int = '1' else clr_timer;
        csr_ena_clr_timer:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              ena_timer_sync0 <= '0';
              ena_timer_sync1 <= '0';
            else
              ena_timer_sync0 <= csr_ena_timer_int;
              ena_timer_sync1 <= ena_timer_sync0;
              if csr_auto_timer_int = '1' then
                ena_timer <= not done;
                clear_timer <= start;
              else
                ena_timer <= ena_timer_sync1;
                clear_timer <= clr_timer;
              end if;
            end if;
          end if;
        end process;

        --CSR to master (processor)
        csr_out_reg(31 downto 5) <= (others =>'0');
        csr_out_reg(4 downto 0)  <= csr_auto_timer_int & '0' & csr_ena_timer_int & done & '0';
        
        -- map input matrices elements from master (processor)
        -- pipeline mapping due to cross clock doamin
        sync_slv_reg2:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg2_sync0 <= (others => '0');
              slv_reg2_sync1 <= (others => '0');
            else
              slv_reg2_sync0 <= slv_reg2;
              slv_reg2_sync1 <= slv_reg2_sync0;
              mata_rows_in(0,0) <= slv_reg2_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg3:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg3_sync0 <= (others => '0');
              slv_reg3_sync1 <= (others => '0');
            else
              slv_reg3_sync0 <= slv_reg3;
              slv_reg3_sync1 <= slv_reg3_sync0;
              mata_rows_in(0,1) <= slv_reg3_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg4:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg4_sync0 <= (others => '0');
              slv_reg4_sync1 <= (others => '0');
            else
              slv_reg4_sync0 <= slv_reg4;
              slv_reg4_sync1 <= slv_reg4_sync0;
              mata_rows_in(0,2) <= slv_reg4_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg5:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg5_sync0 <= (others => '0');
              slv_reg5_sync1 <= (others => '0');
            else
              slv_reg5_sync0 <= slv_reg5;
              slv_reg5_sync1 <= slv_reg5_sync0;
              mata_rows_in(0,3) <= slv_reg5_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg6:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg6_sync0 <= (others => '0');
              slv_reg6_sync1 <= (others => '0');
            else
              slv_reg6_sync0 <= slv_reg6;
              slv_reg6_sync1 <= slv_reg6_sync0;
              mata_rows_in(1,0) <= slv_reg6_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg7:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg7_sync0 <= (others => '0');
              slv_reg7_sync1 <= (others => '0');
            else
              slv_reg7_sync0 <= slv_reg7;
              slv_reg7_sync1 <= slv_reg7_sync0;
              mata_rows_in(1,1) <= slv_reg7_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg8:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg8_sync0 <= (others => '0');
              slv_reg8_sync1 <= (others => '0');
            else
              slv_reg8_sync0 <= slv_reg8;
              slv_reg8_sync1 <= slv_reg8_sync0;
              mata_rows_in(1,2) <= slv_reg8_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg9:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg9_sync0 <= (others => '0');
              slv_reg9_sync1 <= (others => '0');
            else
              slv_reg9_sync0 <= slv_reg9;
              slv_reg9_sync1 <= slv_reg9_sync0;
              mata_rows_in(1,3) <= slv_reg9_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg10:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg10_sync0 <= (others => '0');
              slv_reg10_sync1 <= (others => '0');
            else
              slv_reg10_sync0 <= slv_reg10;
              slv_reg10_sync1 <= slv_reg10_sync0;
              mata_rows_in(2,0) <= slv_reg10_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg11:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg11_sync0 <= (others => '0');
              slv_reg11_sync1 <= (others => '0');
            else
              slv_reg11_sync0 <= slv_reg11;
              slv_reg11_sync1 <= slv_reg11_sync0;
              mata_rows_in(2,1) <= slv_reg11_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg12:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg12_sync0 <= (others => '0');
              slv_reg12_sync1 <= (others => '0');
            else
              slv_reg12_sync0 <= slv_reg12;
              slv_reg12_sync1 <= slv_reg12_sync0;
              mata_rows_in(2,2) <= slv_reg12_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg13:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg13_sync0 <= (others => '0');
              slv_reg13_sync1 <= (others => '0');
            else
              slv_reg13_sync0 <= slv_reg13;
              slv_reg13_sync1 <= slv_reg13_sync0;
              mata_rows_in(2,3) <= slv_reg13_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg14:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg14_sync0 <= (others => '0');
              slv_reg14_sync1 <= (others => '0');
            else
              slv_reg14_sync0 <= slv_reg14;
              slv_reg14_sync1 <= slv_reg14_sync0;
              mata_rows_in(3,0) <= slv_reg14_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg15:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg15_sync0 <= (others => '0');
              slv_reg15_sync1 <= (others => '0');
            else
              slv_reg15_sync0 <= slv_reg15;
              slv_reg15_sync1 <= slv_reg15_sync0;
              mata_rows_in(3,1) <= slv_reg15_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg16:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg16_sync0 <= (others => '0');
              slv_reg16_sync1 <= (others => '0');
            else
              slv_reg16_sync0 <= slv_reg16;
              slv_reg16_sync1 <= slv_reg16_sync0;
              mata_rows_in(3,2) <= slv_reg16_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg17:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg17_sync0 <= (others => '0');
              slv_reg17_sync1 <= (others => '0');
            else
              slv_reg17_sync0 <= slv_reg17;
              slv_reg17_sync1 <= slv_reg17_sync0;
              mata_rows_in(3,3) <= slv_reg17_sync1(7 downto 0);
            end if;
          end if;
        end process;

        sync_slv_reg18:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg18_sync0 <= (others => '0');
              slv_reg18_sync1 <= (others => '0');
            else
              slv_reg18_sync0 <= slv_reg18;
              slv_reg18_sync1 <= slv_reg18_sync0;
              matb_cols_in(0,0) <= slv_reg18_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg19:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg19_sync0 <= (others => '0');
              slv_reg19_sync1 <= (others => '0');
            else
              slv_reg19_sync0 <= slv_reg19;
              slv_reg19_sync1 <= slv_reg19_sync0;
              matb_cols_in(0,1) <= slv_reg19_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg20:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg20_sync0 <= (others => '0');
              slv_reg20_sync1 <= (others => '0');
            else
              slv_reg20_sync0 <= slv_reg20;
              slv_reg20_sync1 <= slv_reg20_sync0;
              matb_cols_in(0,2) <= slv_reg20_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg21:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg21_sync0 <= (others => '0');
              slv_reg21_sync1 <= (others => '0');
            else
              slv_reg21_sync0 <= slv_reg21;
              slv_reg21_sync1 <= slv_reg21_sync0;
              matb_cols_in(0,3) <= slv_reg21_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg22:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg22_sync0 <= (others => '0');
              slv_reg22_sync1 <= (others => '0');
            else
              slv_reg22_sync0 <= slv_reg22;
              slv_reg22_sync1 <= slv_reg22_sync0;
              matb_cols_in(1,0) <= slv_reg22_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg23:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg23_sync0 <= (others => '0');
              slv_reg23_sync1 <= (others => '0');
            else
              slv_reg23_sync0 <= slv_reg23;
              slv_reg23_sync1 <= slv_reg23_sync0;
              matb_cols_in(1,1) <= slv_reg23_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg24:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg24_sync0 <= (others => '0');
              slv_reg24_sync1 <= (others => '0');
            else
              slv_reg24_sync0 <= slv_reg24;
              slv_reg24_sync1 <= slv_reg24_sync0;
              matb_cols_in(1,2) <= slv_reg24_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg25:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg25_sync0 <= (others => '0');
              slv_reg25_sync1 <= (others => '0');
            else
              slv_reg25_sync0 <= slv_reg25;
              slv_reg25_sync1 <= slv_reg25_sync0;
              matb_cols_in(1,3) <= slv_reg25_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg26:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg26_sync0 <= (others => '0');
              slv_reg26_sync1 <= (others => '0');
            else
              slv_reg26_sync0 <= slv_reg26;
              slv_reg26_sync1 <= slv_reg26_sync0;
              matb_cols_in(2,0) <= slv_reg26_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg27:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg27_sync0 <= (others => '0');
              slv_reg27_sync1 <= (others => '0');
            else
              slv_reg27_sync0 <= slv_reg27;
              slv_reg27_sync1 <= slv_reg27_sync0;
              matb_cols_in(2,1) <= slv_reg27_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg28:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg28_sync0 <= (others => '0');
              slv_reg28_sync1 <= (others => '0');
            else
              slv_reg28_sync0 <= slv_reg28;
              slv_reg28_sync1 <= slv_reg28_sync0;
              matb_cols_in(2,2) <= slv_reg28_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg29:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg29_sync0 <= (others => '0');
              slv_reg29_sync1 <= (others => '0');
            else
              slv_reg29_sync0 <= slv_reg29;
              slv_reg29_sync1 <= slv_reg29_sync0;
              matb_cols_in(2,3) <= slv_reg29_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg30:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg30_sync0 <= (others => '0');
              slv_reg30_sync1 <= (others => '0');
            else
              slv_reg30_sync0 <= slv_reg30;
              slv_reg30_sync1 <= slv_reg30_sync0;
              matb_cols_in(3,0) <= slv_reg30_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg31:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg31_sync0 <= (others => '0');
              slv_reg31_sync1 <= (others => '0');
            else
              slv_reg31_sync0 <= slv_reg31;
              slv_reg31_sync1 <= slv_reg31_sync0;
              matb_cols_in(3,1) <= slv_reg31_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg32:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg32_sync0 <= (others => '0');
              slv_reg32_sync1 <= (others => '0');
            else
              slv_reg32_sync0 <= slv_reg32;
              slv_reg32_sync1 <= slv_reg32_sync0;
              matb_cols_in(3,2) <= slv_reg32_sync1(7 downto 0);
            end if;
          end if;
        end process;
        sync_slv_reg33:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              slv_reg33_sync0 <= (others => '0');
              slv_reg33_sync1 <= (others => '0');
            else
              slv_reg33_sync0 <= slv_reg33;
              slv_reg33_sync1 <= slv_reg33_sync0;
              matb_cols_in(3,3) <= slv_reg33_sync1(7 downto 0);
            end if;
          end if;
        end process;

        -- map output matrix elements to master (processor)
        matout_e00_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e00_reg_sync0 <= (others => '0');
              matout_e00_reg_sync1 <= (others => '0');
            else
              matout_e00_reg_sync0(17 downto 0) <= matc_rows0_out(0);
              matout_e00_reg_sync1 <= matout_e00_reg_sync0;
              matout_e00_reg <= matout_e00_reg_sync1;
            end if;
          end if;
        end process;
        matout_e01_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e01_reg_sync0 <= (others => '0');
              matout_e01_reg_sync1 <= (others => '0');
            else
              matout_e01_reg_sync0(17 downto 0) <= matc_rows0_out(1);
              matout_e01_reg_sync1 <= matout_e01_reg_sync0;
              matout_e01_reg <= matout_e01_reg_sync1;
            end if;
          end if;
        end process;
        matout_e02_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e02_reg_sync0 <= (others => '0');
              matout_e02_reg_sync1 <= (others => '0');
            else
              matout_e02_reg_sync0(17 downto 0) <= matc_rows0_out(2);
              matout_e02_reg_sync1 <= matout_e02_reg_sync0;
              matout_e02_reg <= matout_e02_reg_sync1;
            end if;
          end if;
        end process;
        matout_e03_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e03_reg_sync0 <= (others => '0');
              matout_e03_reg_sync1 <= (others => '0');
            else
              matout_e03_reg_sync0(17 downto 0) <= matc_rows0_out(3);
              matout_e03_reg_sync1 <= matout_e03_reg_sync0;
              matout_e03_reg <= matout_e03_reg_sync1;
            end if;
          end if;
        end process;
        matout_e10_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e10_reg_sync0 <= (others => '0');
              matout_e10_reg_sync1 <= (others => '0');
            else
              matout_e10_reg_sync0(17 downto 0) <= matc_rows1_out(0);
              matout_e10_reg_sync1 <= matout_e10_reg_sync0;
              matout_e10_reg <= matout_e10_reg_sync1;
            end if;
          end if;
        end process;
        matout_e11_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e11_reg_sync0 <= (others => '0');
              matout_e11_reg_sync1 <= (others => '0');
            else
              matout_e11_reg_sync0(17 downto 0) <= matc_rows1_out(1);
              matout_e11_reg_sync1 <= matout_e11_reg_sync0;
              matout_e11_reg <= matout_e11_reg_sync1;
            end if;
          end if;
        end process;
        matout_e12_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e12_reg_sync0 <= (others => '0');
              matout_e12_reg_sync1 <= (others => '0');
            else
              matout_e12_reg_sync0(17 downto 0) <= matc_rows1_out(2);
              matout_e12_reg_sync1 <= matout_e12_reg_sync0;
              matout_e12_reg <= matout_e12_reg_sync1;
            end if;
          end if;
        end process;
        matout_e13_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e13_reg_sync0 <= (others => '0');
              matout_e13_reg_sync1 <= (others => '0');
            else
              matout_e13_reg_sync0(17 downto 0) <= matc_rows1_out(3);
              matout_e13_reg_sync1 <= matout_e13_reg_sync0;
              matout_e13_reg <= matout_e13_reg_sync1;
            end if;
          end if;
        end process;
        matout_e20_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e20_reg_sync0 <= (others => '0');
              matout_e20_reg_sync1 <= (others => '0');
            else
              matout_e20_reg_sync0(17 downto 0) <= matc_rows2_out(0);
              matout_e20_reg_sync1 <= matout_e20_reg_sync0;
              matout_e20_reg <= matout_e20_reg_sync1;
            end if;
          end if;
        end process;
        matout_e21_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e21_reg_sync0 <= (others => '0');
              matout_e21_reg_sync1 <= (others => '0');
            else
              matout_e21_reg_sync0(17 downto 0) <= matc_rows2_out(1);
              matout_e21_reg_sync1 <= matout_e21_reg_sync0;
              matout_e21_reg <= matout_e21_reg_sync1;
            end if;
          end if;
        end process;
        matout_e22_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e22_reg_sync0 <= (others => '0');
              matout_e22_reg_sync1 <= (others => '0');
            else
              matout_e22_reg_sync0(17 downto 0) <= matc_rows2_out(2);
              matout_e22_reg_sync1 <= matout_e22_reg_sync0;
              matout_e22_reg <= matout_e22_reg_sync1;
            end if;
          end if;
        end process;
        matout_e23_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e23_reg_sync0 <= (others => '0');
              matout_e23_reg_sync1 <= (others => '0');
            else
              matout_e23_reg_sync0(17 downto 0) <= matc_rows2_out(3);
              matout_e23_reg_sync1 <= matout_e23_reg_sync0;
              matout_e23_reg <= matout_e23_reg_sync1;
            end if;
          end if;
        end process;
        matout_e30_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e30_reg_sync0 <= (others => '0');
              matout_e30_reg_sync1 <= (others => '0');
            else
              matout_e30_reg_sync0(17 downto 0) <= matc_rows3_out(0);
              matout_e30_reg_sync1 <= matout_e30_reg_sync0;
              matout_e30_reg <= matout_e30_reg_sync1;
            end if;
          end if;
        end process;
        matout_e31_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e31_reg_sync0 <= (others => '0');
              matout_e31_reg_sync1 <= (others => '0');
            else
              matout_e31_reg_sync0(17 downto 0) <= matc_rows3_out(1);
              matout_e31_reg_sync1 <= matout_e31_reg_sync0;
              matout_e31_reg <= matout_e31_reg_sync1;
            end if;
          end if;
        end process;
        matout_e32_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e32_reg_sync0 <= (others => '0');
              matout_e32_reg_sync1 <= (others => '0');
            else
              matout_e32_reg_sync0(17 downto 0) <= matc_rows3_out(2);
              matout_e32_reg_sync1 <= matout_e32_reg_sync0;
              matout_e32_reg <= matout_e32_reg_sync1;
            end if;
          end if;
        end process;
        matout_e33_sync:process(clk_250MHz_i)
        begin
          if clk_250MHz_i'event and clk_250MHz_i = '1' then
            if reset_h = '1' then
              matout_e33_reg_sync0 <= (others => '0');
              matout_e33_reg_sync1 <= (others => '0');
            else
              matout_e33_reg_sync0(17 downto 0) <= matc_rows3_out(3);
              matout_e33_reg_sync1 <= matout_e33_reg_sync0;
              matout_e33_reg <= matout_e33_reg_sync1;
            end if;
          end if;
        end process;

--        matout_e00_reg(17 downto 0) <= matc_rows0_out(0);
--        matout_e01_reg(17 downto 0) <= matc_rows0_out(1);
--        matout_e02_reg(17 downto 0) <= matc_rows0_out(2);
--        matout_e03_reg(17 downto 0) <= matc_rows0_out(3);
--        matout_e10_reg(17 downto 0) <= matc_rows1_out(0);
--        matout_e11_reg(17 downto 0) <= matc_rows1_out(1);
--        matout_e12_reg(17 downto 0) <= matc_rows1_out(2);
--        matout_e13_reg(17 downto 0) <= matc_rows1_out(3);
--        matout_e20_reg(17 downto 0) <= matc_rows2_out(0);
--        matout_e21_reg(17 downto 0) <= matc_rows2_out(1);
--        matout_e22_reg(17 downto 0) <= matc_rows2_out(2);
--        matout_e23_reg(17 downto 0) <= matc_rows2_out(3);
--        matout_e30_reg(17 downto 0) <= matc_rows3_out(0);
--        matout_e31_reg(17 downto 0) <= matc_rows3_out(1);
--        matout_e32_reg(17 downto 0) <= matc_rows3_out(2);
--        matout_e33_reg(17 downto 0) <= matc_rows3_out(3);

	-- User logic ends

end arch_imp;
