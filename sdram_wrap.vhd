library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

--library work;
--use work.zpu_config.all;
--use work.zpuino_config.all;
--use work.zpuinopkg.all;
--use work.zpupkg.all;
--use work.wishbonepkg.all;

library unisim;
use unisim.vcomponents.all;


entity sdram_ctrl is
  port (
    wb_clk_i: in std_logic;
	 wb_rst_i: in std_logic;

    wb_data_o: out std_logic_vector(31 downto 0);
    wb_data_i: in std_logic_vector(31 downto 0);
    wb_adr_i: in std_logic_vector(24 downto 2);
    wb_we_i:  in std_logic;
    wb_cyc_i: in std_logic;
    wb_stb_i: in std_logic;
    wb_sel_i: in std_logic_vector(3 downto 0);
    wb_ack_o: out std_logic;
    wb_stall_o: out std_logic;

    -- extra clocking
    clk_off_3ns: in std_logic;

    -- SDRAM signals
     SDRAM_ADDR    : OUT   STD_LOGIC_VECTOR (12 downto 0);
     SDRAM_BA      : OUT   STD_LOGIC_VECTOR (1 downto 0);
     SDRAM_CAS     : OUT   STD_LOGIC;
     SDRAM_CKE     : OUT   STD_LOGIC;
     SDRAM_CLK     : OUT   STD_LOGIC;
     SDRAM_CS      : OUT   STD_LOGIC;
     SDRAM_DATA    : INOUT STD_LOGIC_VECTOR(15 downto 0);
     SDRAM_DQM     : OUT   STD_LOGIC_VECTOR(1 downto 0);
     SDRAM_RAS     : OUT   STD_LOGIC;
     SDRAM_WE      : OUT   STD_LOGIC
  
  );

end entity sdram_ctrl;

architecture behave of sdram_ctrl is

  component sdram_controller is
  generic (
    HIGH_BIT: integer := 24
  );

   PORT (
      clock_100:  in std_logic;
      clock_100_delayed_3ns: in std_logic;
      rst: in std_logic;

   -- Signals to/from the SDRAM chip
   DRAM_ADDR   : OUT   STD_LOGIC_VECTOR (12 downto 0);
   DRAM_BA      : OUT   STD_LOGIC_VECTOR (1 downto 0);
   DRAM_CAS_N   : OUT   STD_LOGIC;
   DRAM_CKE      : OUT   STD_LOGIC;
   DRAM_CLK      : OUT   STD_LOGIC;
   DRAM_CS_N   : OUT   STD_LOGIC;
   DRAM_DQ      : INOUT STD_LOGIC_VECTOR(15 downto 0);
   DRAM_DQM      : OUT   STD_LOGIC_VECTOR(1 downto 0);
   DRAM_RAS_N   : OUT   STD_LOGIC;
   DRAM_WE_N    : OUT   STD_LOGIC;
   pending:  out std_logic;
   --- Inputs from rest of the system
   address      : IN     STD_LOGIC_VECTOR (HIGH_BIT downto 2);
   req_read      : IN     STD_LOGIC;
   req_write   : IN     STD_LOGIC;
   data_out      : OUT     STD_LOGIC_VECTOR (31 downto 0);
   data_out_valid : OUT     STD_LOGIC;
   data_in      : IN     STD_LOGIC_VECTOR (31 downto 0);
   data_mask    : in std_logic_vector(3 downto 0)
   );
  end component;

  signal sdr_address:    STD_LOGIC_VECTOR (22 downto 2);
  signal sdr_req_read      :     STD_LOGIC;
  signal sdr_req_write   :      STD_LOGIC;
  signal sdr_data_out      :      STD_LOGIC_VECTOR (31 downto 0);
  signal sdr_data_out_valid :      STD_LOGIC;
  signal sdr_data_in      : STD_LOGIC_VECTOR (31 downto 0);

  signal sdr_data_mask: std_logic_vector(3 downto 0);

  signal pending: std_logic;

begin

  ctrl: sdram_controller
    generic map (
      HIGH_BIT => 22
   )
   port map (
    clock_100   => wb_clk_i,
    clock_100_delayed_3ns => clk_off_3ns,
    rst => wb_rst_i,

    DRAM_ADDR   => SDRAM_ADDR,
    DRAM_BA     => SDRAM_BA,
    DRAM_CAS_N  => SDRAM_CAS,
    DRAM_CKE    => SDRAM_CKE,
    DRAM_CLK    => SDRAM_CLK,
    DRAM_CS_N   => SDRAM_CS,
    DRAM_DQ     => SDRAM_DATA,
    DRAM_DQM    => SDRAM_DQM,
    DRAM_RAS_N  => SDRAM_RAS,
    DRAM_WE_N   => SDRAM_WE,

    pending     => pending,
    address     => sdr_address,
    req_read    => sdr_req_read,
    req_write   => sdr_req_write,
    data_out    => sdr_data_out,
    data_out_valid => sdr_data_out_valid,
    data_in      => sdr_data_in,
    data_mask  => sdr_data_mask
   );


  sdr_address(22 downto 2) <= wb_adr_i(22 downto 2);

  sdr_req_read<='1' when wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='0' else '0';
  sdr_req_write<='1' when wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1' else '0';

  sdr_data_in <= wb_data_i;
  sdr_data_mask <= wb_sel_i;

  wb_stall_o <= '1' when pending='1' else '0';

  process(wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then

     wb_ack_o <= sdr_data_out_valid;
     wb_data_o <= sdr_data_out;
    end if;
  end process;

end behave;



