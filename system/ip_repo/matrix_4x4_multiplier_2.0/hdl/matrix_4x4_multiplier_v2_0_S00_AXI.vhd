library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.m4x4_mult_pkg.all;

entity matrix_4x4_multiplier_v2_0_S00_AXI is
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
		CLK_DSP_I	: in std_logic;
		INHIBIT_I	: in std_logic;

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
end matrix_4x4_multiplier_v2_0_S00_AXI;

architecture arch_imp of matrix_4x4_multiplier_v2_0_S00_AXI is

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
	signal axi_reset_high	: std_logic;

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
        -- Slave Registers description (R/W=Read/Write, RO=Read-Only, WO=Write-Only):
        -- REG0 : CSR, R/W
        -- REG1 : TIMER, WO
        -- REG02...REG17 : MATA_ROWS, RO
        -- REG18...REG33 : MATB_COLS, RO
        -- REG34...REG49 : MATC_ELEM, WO
        -- CSR (REG0) declaration
        signal csr_start_reg      : std_logic; -- s_axi_aclk domain
        signal csr_ena_timer_reg  : std_logic; -- s_axi_aclk domain
        signal csr_clr_timer_reg  : std_logic; -- s_axi_aclk domain
        signal csr_auto_timer_reg : std_logic; -- s_axi_aclk domain
        signal start_sync         : std_logic; -- clk_dsp_i domain
        signal ena_timer_sync     : std_logic; -- clk_dsp_i domain
        signal clr_timer_sync     : std_logic; -- clk_dsp_i domain
        signal aut_timer_sync     : std_logic; -- clk_dsp_i domain
        signal done               : std_logic; -- clk_dsp_i domain
        signal done_sync          : std_logic; -- s_axi_aclk domain
        -- TIMER (REG1) declaration
        signal timer_cnt         : std_logic_vector(31 downto 0); -- clk_dsp_i domain
        signal timer_cnt_sync    : std_logic_vector(31 downto 0); -- s_axi_aclk domain
        -- MATA & MATB (REG2...REG33) declaration
        type slv_reg_mat_in_array is array (3 downto 0) of std_logic_vector(31 downto 0);
        signal mata_row0_reg02_05 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal mata_row1_reg06_09 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal mata_row2_reg10_13 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal mata_row3_reg14_17 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal matb_col0_reg18_21 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal matb_col1_reg22_25 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal matb_col2_reg26_29 : slv_reg_mat_in_array; -- s_axi_aclk domain
        signal matb_col3_reg30_33 : slv_reg_mat_in_array; -- s_axi_aclk domain
        -- MATA & MATB (REG2...REG33) declaration
        type slv_reg_mat_out_array is array (3 downto 0) of std_logic_vector(17 downto 0);
        signal matc_row0_reg34_37 : slv_reg_mat_out_array; -- s_axi_aclk domain
        signal matc_row1_reg38_41 : slv_reg_mat_out_array; -- s_axi_aclk domain
        signal matc_row2_reg42_45 : slv_reg_mat_out_array; -- s_axi_aclk domain
        signal matc_row3_reg46_49 : slv_reg_mat_out_array; -- s_axi_aclk domain

	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	: std_logic;

        signal reset_sync0       : std_logic; -- clk_dsp_i domain
        signal reset_sync1       : std_logic; -- clk_dsp_i domain
        signal reset_sync        : std_logic; -- clk_dsp_i domain
        signal inhibit_debounced : std_logic; -- clk_dsp_i domain
        signal mata_rows_in      : mat_4x4_8bits; -- clk_dsp_i domain
        signal matb_cols_in      : mat_4x4_8bits; -- clk_dsp_i domain
        signal matc_rows0_out    : mat_1x4_18bits; -- clk_dsp_i domain
        signal matc_rows1_out    : mat_1x4_18bits; -- clk_dsp_i domain
        signal matc_rows2_out    : mat_1x4_18bits; -- clk_dsp_i domain
        signal matc_rows3_out    : mat_1x4_18bits; -- clk_dsp_i domain

        signal ena_timer     : std_logic; -- clk_dsp_i domain
        signal clr_timer     : std_logic; -- clk_dsp_i domain
        --
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

        component gc_synchronizer is
          port (
            clk_i : in  std_logic;
            rst_i : in  std_logic;
            d_i   : in  std_logic;
            q_o   : out std_logic);
        end component;

        component gc_sync_monostable is
          port (
            clk_i : in  std_logic;
            rst_i : in  std_logic;
            d_i   : in  std_logic;
            q_o   : out std_logic);
        end component;

        component gc_sync_register is
          generic (
            g_width : integer := 32);
          port (
            clk_i : in  std_logic;
            rst_i : in  std_logic;
            d_i   : in  std_logic_vector(g_width-1 downto 0);
            q_o   : out std_logic_vector(g_width-1 downto 0)
            );
        end component;

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

        -- SLAVE RAED process (MASTER, i.e processor, initiated WRITE cycle)
	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
              csr_start_reg      <= '0';
              csr_ena_timer_reg  <= '0';
              csr_clr_timer_reg  <= '0';
              csr_auto_timer_reg <= '0';
              mata_row0_reg02_05 <= (others => (others => '0'));
              mata_row1_reg06_09 <= (others => (others => '0'));
              mata_row2_reg10_13 <= (others => (others => '0'));
              mata_row3_reg14_17 <= (others => (others => '0'));
              matb_col0_reg18_21 <= (others => (others => '0'));
              matb_col1_reg22_25 <= (others => (others => '0'));
              matb_col2_reg26_29 <= (others => (others => '0'));
              matb_col3_reg30_33 <= (others => (others => '0'));
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is
	          when b"000000" =>
                    csr_start_reg <= S_AXI_WDATA(0);
                    csr_ena_timer_reg <= S_AXI_WDATA(2);
                    csr_clr_timer_reg <= S_AXI_WDATA(3);
                    csr_auto_timer_reg <= S_AXI_WDATA(4);
	          when b"000010" =>
                    mata_row0_reg02_05(0) <= S_AXI_WDATA;
	          when b"000011" =>
                    mata_row0_reg02_05(1) <= S_AXI_WDATA;
	          when b"000100" =>
                    mata_row0_reg02_05(2) <= S_AXI_WDATA;
	          when b"000101" =>
                    mata_row0_reg02_05(3) <= S_AXI_WDATA;
	          when b"000110" =>
                    mata_row1_reg06_09(0) <= S_AXI_WDATA;
	          when b"000111" =>
                    mata_row1_reg06_09(1) <= S_AXI_WDATA;
	          when b"001000" =>
                    mata_row1_reg06_09(2) <= S_AXI_WDATA;
	          when b"001001" =>
                    mata_row1_reg06_09(3) <= S_AXI_WDATA;
	          when b"001010" =>
                    mata_row2_reg10_13(0) <= S_AXI_WDATA;
	          when b"001011" =>
                    mata_row2_reg10_13(1) <= S_AXI_WDATA;
	          when b"001100" =>
                    mata_row2_reg10_13(2) <= S_AXI_WDATA;
	          when b"001101" =>
                    mata_row2_reg10_13(3) <= S_AXI_WDATA;
	          when b"001110" =>
                    mata_row3_reg14_17(0) <= S_AXI_WDATA;
	          when b"001111" =>
                    mata_row3_reg14_17(1) <= S_AXI_WDATA;
	          when b"010000" =>
                    mata_row3_reg14_17(2) <= S_AXI_WDATA;
	          when b"010001" =>
                    mata_row3_reg14_17(3) <= S_AXI_WDATA;
	          when b"010010" =>
                    matb_col0_reg18_21(0) <= S_AXI_WDATA;
	          when b"010011" =>
                    matb_col0_reg18_21(1) <= S_AXI_WDATA;
	          when b"010100" =>
                    matb_col0_reg18_21(2) <= S_AXI_WDATA;
	          when b"010101" =>
                    matb_col0_reg18_21(3) <= S_AXI_WDATA;
	          when b"010110" =>
                    matb_col1_reg22_25(0) <= S_AXI_WDATA;
	          when b"010111" =>
                    matb_col1_reg22_25(1) <= S_AXI_WDATA;
	          when b"011000" =>
                    matb_col1_reg22_25(2) <= S_AXI_WDATA;
	          when b"011001" =>
                    matb_col1_reg22_25(3) <= S_AXI_WDATA;
	          when b"011010" =>
                    matb_col2_reg26_29(0) <= S_AXI_WDATA;
	          when b"011011" =>
                    matb_col2_reg26_29(1) <= S_AXI_WDATA;
	          when b"011100" =>
                    matb_col2_reg26_29(2) <= S_AXI_WDATA;
	          when b"011101" =>
                    matb_col2_reg26_29(3) <= S_AXI_WDATA;
	          when b"011110" =>
                    matb_col3_reg30_33(0) <= S_AXI_WDATA;
	          when b"011111" =>
                    matb_col3_reg30_33(1) <= S_AXI_WDATA;
	          when b"100000" =>
                    matb_col3_reg30_33(2) <= S_AXI_WDATA;
	          when b"100001" =>
                    matb_col3_reg30_33(3) <= S_AXI_WDATA;
	          when others =>
                    mata_row0_reg02_05(0) <= mata_row0_reg02_05(0);
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

--	process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, slv_reg10, slv_reg11, slv_reg12, slv_reg13, slv_reg14, slv_reg15, slv_reg16, slv_reg17, slv_reg18, slv_reg19, slv_reg20, slv_reg21, slv_reg22, slv_reg23, slv_reg24, slv_reg25, slv_reg26, slv_reg27, slv_reg28, slv_reg29, slv_reg30, slv_reg31, slv_reg32, slv_reg33, slv_reg34, slv_reg35, slv_reg36, slv_reg37, slv_reg38, slv_reg39, slv_reg40, slv_reg41, slv_reg42, slv_reg43, slv_reg44, slv_reg45, slv_reg46, slv_reg47, slv_reg48, slv_reg49, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
--	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
--	begin
--	    -- Address decoding for reading registers
--	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
--	    case loc_addr is
--	      when b"000000" =>
--	        reg_data_out <= slv_reg0;
--	      when b"000001" =>
--	        reg_data_out <= slv_reg1;
--	      when b"000010" =>
--	        reg_data_out <= slv_reg2;
--	      when b"000011" =>
--	        reg_data_out <= slv_reg3;
--	      when b"000100" =>
--	        reg_data_out <= slv_reg4;
--	      when b"000101" =>
--	        reg_data_out <= slv_reg5;
--	      when b"000110" =>
--	        reg_data_out <= slv_reg6;
--	      when b"000111" =>
--	        reg_data_out <= slv_reg7;
--	      when b"001000" =>
--	        reg_data_out <= slv_reg8;
--	      when b"001001" =>
--	        reg_data_out <= slv_reg9;
--	      when b"001010" =>
--	        reg_data_out <= slv_reg10;
--	      when b"001011" =>
--	        reg_data_out <= slv_reg11;
--	      when b"001100" =>
--	        reg_data_out <= slv_reg12;
--	      when b"001101" =>
--	        reg_data_out <= slv_reg13;
--	      when b"001110" =>
--	        reg_data_out <= slv_reg14;
--	      when b"001111" =>
--	        reg_data_out <= slv_reg15;
--	      when b"010000" =>
--	        reg_data_out <= slv_reg16;
--	      when b"010001" =>
--	        reg_data_out <= slv_reg17;
--	      when b"010010" =>
--	        reg_data_out <= slv_reg18;
--	      when b"010011" =>
--	        reg_data_out <= slv_reg19;
--	      when b"010100" =>
--	        reg_data_out <= slv_reg20;
--	      when b"010101" =>
--	        reg_data_out <= slv_reg21;
--	      when b"010110" =>
--	        reg_data_out <= slv_reg22;
--	      when b"010111" =>
--	        reg_data_out <= slv_reg23;
--	      when b"011000" =>
--	        reg_data_out <= slv_reg24;
--	      when b"011001" =>
--	        reg_data_out <= slv_reg25;
--	      when b"011010" =>
--	        reg_data_out <= slv_reg26;
--	      when b"011011" =>
--	        reg_data_out <= slv_reg27;
--	      when b"011100" =>
--	        reg_data_out <= slv_reg28;
--	      when b"011101" =>
--	        reg_data_out <= slv_reg29;
--	      when b"011110" =>
--	        reg_data_out <= slv_reg30;
--	      when b"011111" =>
--	        reg_data_out <= slv_reg31;
--	      when b"100000" =>
--	        reg_data_out <= slv_reg32;
--	      when b"100001" =>
--	        reg_data_out <= slv_reg33;
--	      when b"100010" =>
--	        reg_data_out <= slv_reg34;
--	      when b"100011" =>
--	        reg_data_out <= slv_reg35;
--	      when b"100100" =>
--	        reg_data_out <= slv_reg36;
--	      when b"100101" =>
--	        reg_data_out <= slv_reg37;
--	      when b"100110" =>
--	        reg_data_out <= slv_reg38;
--	      when b"100111" =>
--	        reg_data_out <= slv_reg39;
--	      when b"101000" =>
--	        reg_data_out <= slv_reg40;
--	      when b"101001" =>
--	        reg_data_out <= slv_reg41;
--	      when b"101010" =>
--	        reg_data_out <= slv_reg42;
--	      when b"101011" =>
--	        reg_data_out <= slv_reg43;
--	      when b"101100" =>
--	        reg_data_out <= slv_reg44;
--	      when b"101101" =>
--	        reg_data_out <= slv_reg45;
--	      when b"101110" =>
--	        reg_data_out <= slv_reg46;
--	      when b"101111" =>
--	        reg_data_out <= slv_reg47;
--	      when b"110000" =>
--	        reg_data_out <= slv_reg48;
--	      when b"110001" =>
--	        reg_data_out <= slv_reg49;
--	      when others =>
--	        reg_data_out  <= (others => '0');
--	    end case;
--	end process; 

        -- SLAVE WRITE process (MASTER, i.e processor, initiated READ cycle)
	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
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
                --axi_rdata <= reg_data_out;     -- register read data
                -- Address decoding for reading registers
                loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
                case loc_addr is
                  when b"000000" =>
                    axi_rdata <= "000000000000000000000000000" & csr_auto_timer_reg & '0' & csr_ena_timer_reg & done_sync & '0';
                  when b"000001" =>
                    axi_rdata <= timer_cnt_sync;
                  when b"000010" =>
                    axi_rdata <= mata_row0_reg02_05(0);
                  when b"000011" =>
                    axi_rdata <= mata_row0_reg02_05(1);
                  when b"000100" =>
                    axi_rdata <= mata_row0_reg02_05(2);
                  when b"000101" =>
                    axi_rdata <= mata_row0_reg02_05(3);
                  when b"000110" =>
                    axi_rdata <= mata_row1_reg06_09(0);
                  when b"000111" =>
                    axi_rdata <= mata_row1_reg06_09(1);
                  when b"001000" =>
                    axi_rdata <= mata_row1_reg06_09(2);
                  when b"001001" =>
                    axi_rdata <= mata_row1_reg06_09(3);
                  when b"001010" =>
                    axi_rdata <= mata_row2_reg10_13(0);
                  when b"001011" =>
                    axi_rdata <= mata_row2_reg10_13(1);
                  when b"001100" =>
                    axi_rdata <= mata_row2_reg10_13(2);
                  when b"001101" =>
                    axi_rdata <= mata_row2_reg10_13(3);
                  when b"001110" =>
                    axi_rdata <= mata_row3_reg14_17(0);
                  when b"001111" =>
                    axi_rdata <= mata_row3_reg14_17(1);
                  when b"010000" =>
                    axi_rdata <= mata_row3_reg14_17(2);
                  when b"010001" =>
                    axi_rdata <= mata_row3_reg14_17(3);
                  when b"010010" =>
                    axi_rdata <= matb_col0_reg18_21(0);
                  when b"010011" =>
                    axi_rdata <= matb_col0_reg18_21(1);
                  when b"010100" =>
                    axi_rdata <= matb_col0_reg18_21(2);
                  when b"010101" =>
                    axi_rdata <= matb_col0_reg18_21(3);
                  when b"010110" =>
                    axi_rdata <= matb_col1_reg22_25(0);
                  when b"010111" =>
                    axi_rdata <= matb_col1_reg22_25(1);
                  when b"011000" =>
                    axi_rdata <= matb_col1_reg22_25(2);
                  when b"011001" =>
                    axi_rdata <= matb_col1_reg22_25(3);
                  when b"011010" =>
                    axi_rdata <= matb_col2_reg26_29(0);
                  when b"011011" =>
                    axi_rdata <= matb_col2_reg26_29(1);
                  when b"011100" =>
                    axi_rdata <= matb_col2_reg26_29(2);
                  when b"011101" =>
                    axi_rdata <= matb_col2_reg26_29(3);
                  when b"011110" =>
                    axi_rdata <= matb_col3_reg30_33(0);
                  when b"011111" =>
                    axi_rdata <= matb_col3_reg30_33(1);
                  when b"100000" =>
                    axi_rdata <= matb_col3_reg30_33(2);
                  when b"100001" =>
                    axi_rdata <= matb_col3_reg30_33(3);
                  when b"100010" =>
                    axi_rdata <= "00000000000000" & matc_row0_reg34_37(0);
                  when b"100011" =>
                    axi_rdata <= "00000000000000" & matc_row0_reg34_37(1);
                  when b"100100" =>
                    axi_rdata <= "00000000000000" & matc_row0_reg34_37(2);
                  when b"100101" =>
                    axi_rdata <= "00000000000000" & matc_row0_reg34_37(3);
                  when b"100110" =>
                    axi_rdata <= "00000000000000" & matc_row1_reg38_41(0);
                  when b"100111" =>
                    axi_rdata <= "00000000000000" & matc_row1_reg38_41(1);
                  when b"101000" =>
                    axi_rdata <= "00000000000000" & matc_row1_reg38_41(2);
                  when b"101001" =>
                    axi_rdata <= "00000000000000" & matc_row1_reg38_41(3);
                  when b"101010" =>
                    axi_rdata <= "00000000000000" & matc_row2_reg42_45(0);
                  when b"101011" =>
                    axi_rdata <= "00000000000000" & matc_row2_reg42_45(1);
                  when b"101100" =>
                    axi_rdata <= "00000000000000" & matc_row2_reg42_45(2);
                  when b"101101" =>
                    axi_rdata <= "00000000000000" & matc_row2_reg42_45(3);
                  when b"101110" =>
                    axi_rdata <= "00000000000000" & matc_row3_reg46_49(0);
                  when b"101111" =>
                    axi_rdata <= "00000000000000" & matc_row3_reg46_49(1);
                  when b"110000" =>
                    axi_rdata <= "00000000000000" & matc_row3_reg46_49(2);
                  when b"110001" =>
                    axi_rdata <= "00000000000000" & matc_row3_reg46_49(3);
                  when others =>
                    axi_rdata  <= (others => '0');
                end case;

	      end if;   
	    end if;
	  end if;
	end process;


	-- Add user logic here
        axi_reset_high <= not S_AXI_ARESETN;

        matrix_4x4_mult_inst:m4x4_mult
          port map (
            clk_i        => CLK_DSP_I,
            rst_i        => reset_sync,
            inhibit_i    => inhibit_debounced,
            start_i      => start_sync,
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
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            ena_i => ena_timer,
            clr_i => clr_timer_sync,
            ofw_o => open,
            cnt_o => timer_cnt
            );

        ena_timer <= not done when aut_timer_sync = '1' else ena_timer_sync;
--        clr_timer <= start_sync when aut_timer_sync = '1' else clr_timer_sync;

        -- stability time calcul: clk_i is 250MHz
        -- consider button stable within 10ms
        -- we look for counter width giving counter_max * 1/clk_i = 10ms
        -- so counter_max = 0.01 * clk_i = 2500000
        -- and counter_width = ceil[ln(2500000)/ln2] = 22 bits
        debouncer_inst:debouncer
          generic map (
            g_stability_counter_max => 2500000,
            g_stability_counter_width => 22
            )
          port map (
            clk_i    => CLK_DSP_I,
            rst_i    => reset_sync,
            button_i => INHIBIT_I,
            button_o => inhibit_debounced
            );

        -- reset HIGH sync (AXI reset active LOW)
        process(CLK_DSP_I)
        begin
          if CLK_DSP_I'event and CLK_DSP_I = '1' then
            reset_sync0 <= not S_AXI_ARESETN;
            reset_sync1 <= reset_sync0;
            reset_sync  <= reset_sync1;
          end if;
        end process;

        -- CSR monostable
        csr_start_monstable:gc_sync_monostable
          port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => csr_start_reg,
            q_o   => start_sync
            );
        csr_clr_timer_monstable:gc_sync_monostable
          port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => csr_clr_timer_reg,
            q_o   => clr_timer_sync
            );

        --CSR synchronizer
        csr_ena_timer_sync:gc_synchronizer
          port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => csr_ena_timer_reg,
            q_o   => ena_timer_sync
            );
        csr_auto_timer_sync:gc_synchronizer
          port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => csr_auto_timer_reg,
            q_o   => aut_timer_sync
            );
        csr_done_sync:gc_synchronizer
          port map (
            clk_i => S_AXI_ACLK,
            rst_i => axi_reset_high,
            d_i   => done,
            q_o   => done_sync
            );

        -- TIMER register sync
        timer_reg_sync:gc_sync_register
          generic map (
            g_width => 32
            )
          port map (
            clk_i => S_AXI_ACLK,
            rst_i => axi_reset_high,
            d_i   => timer_cnt,
            q_o   => timer_cnt_sync
            );
        
        -- MATA REGISTERS synchonizers from S_AXI_ACLK to CLK_DSP_I
        mata_row0_reg_sync:for I in 0 to 3 generate
          mata_row0_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => mata_row0_reg02_05(I)(7 downto 0),
            q_o   => mata_rows_in(0,I)
            );
        end generate mata_row0_reg_sync;
        mata_row1_reg_sync:for I in 0 to 3 generate
          mata_row1_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => mata_row1_reg06_09(I)(7 downto 0),
            q_o   => mata_rows_in(1,I)
            );
        end generate mata_row1_reg_sync;
        mata_row2_reg_sync:for I in 0 to 3 generate
          mata_row2_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => mata_row2_reg10_13(I)(7 downto 0),
            q_o   => mata_rows_in(2,I)
            );
        end generate mata_row2_reg_sync;
        mata_row3_reg_sync:for I in 0 to 3 generate
          mata_row3_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => mata_row3_reg14_17(I)(7 downto 0),
            q_o   => mata_rows_in(3,I)
            );
        end generate mata_row3_reg_sync;
        -- MATB REGISTERS synchonizers from S_AXI_ACLK to CLK_DSP_I
        matb_col0_reg_sync:for I in 0 to 3 generate
          matb_col0_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => matb_col0_reg18_21(I)(7 downto 0),
            q_o   => matb_cols_in(0,I)
            );
        end generate matb_col0_reg_sync;
        matb_col1_reg_sync:for I in 0 to 3 generate
          matb_col1_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => matb_col1_reg22_25(I)(7 downto 0),
            q_o   => matb_cols_in(1,I)
            );
        end generate matb_col1_reg_sync;
        matb_col2_reg_sync:for I in 0 to 3 generate
          matb_col2_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => matb_col2_reg26_29(I)(7 downto 0),
            q_o   => matb_cols_in(2,I)
            );
        end generate matb_col2_reg_sync;
        matb_col3_reg_sync:for I in 0 to 3 generate
          matb_col3_sync:gc_sync_register
            generic map (
              g_width => 8
              )
            port map (
            clk_i => CLK_DSP_I,
            rst_i => reset_sync,
            d_i   => matb_col3_reg30_33(I)(7 downto 0),
            q_o   => matb_cols_in(3,I)
            );
        end generate matb_col3_reg_sync;

        -- MATC REGISTERS synchronizers from CLK_DSP_I to S_AXI_ACLK
        matc_row0_reg_sync:for I in 0 to 3 generate
          matc_row0_sync:gc_sync_register
            generic map (
              g_width => 18
              )
            port map (
            clk_i => S_AXI_ACLK,
            rst_i => axi_reset_high,
            d_i   => matc_rows0_out(I),
            q_o   => matc_row0_reg34_37(I)
            );
        end generate matc_row0_reg_sync;
        matc_row1_reg_sync:for I in 0 to 3 generate
          matc_row1_sync:gc_sync_register
            generic map (
              g_width => 18
              )
            port map (
            clk_i => S_AXI_ACLK,
            rst_i => axi_reset_high,
            d_i   => matc_rows1_out(I),
            q_o   => matc_row1_reg38_41(I)
            );
        end generate matc_row1_reg_sync;
        matc_row2_reg_sync:for I in 0 to 3 generate
          matc_row2_sync:gc_sync_register
            generic map (
              g_width => 18
              )
            port map (
            clk_i => S_AXI_ACLK,
            rst_i => axi_reset_high,
            d_i   => matc_rows2_out(I),
            q_o   => matc_row2_reg42_45(I)
            );
        end generate matc_row2_reg_sync;
        matc_row3_reg_sync:for I in 0 to 3 generate
          matc_row3_sync:gc_sync_register
            generic map (
              g_width => 18
              )
            port map (
            clk_i => S_AXI_ACLK,
            rst_i => axi_reset_high,
            d_i   => matc_rows3_out(I),
            q_o   => matc_row3_reg46_49(I)
            );
        end generate matc_row3_reg_sync;

	-- User logic ends

end arch_imp;
