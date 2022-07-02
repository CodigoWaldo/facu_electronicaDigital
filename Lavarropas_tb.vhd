library ieee;
use ieee.std_logic_1164.all;

entity Lavarropas_tb is
end entity;

architecture sens of Lavarropas_tb is
    component Lavarropas
    port(
        perilla          : in std_logic_vector(2 downto 0);
        inicio           : in std_logic;
        clk              : in std_logic;
        led_tapa         : out std_logic;
        led_lavado       : out std_logic;
        led_centrifugado : out std_logic;
        led_enjuague     : out std_logic
    );
    end component;

    
    signal perilla          :  std_logic_vector(2 downto 0) := (others =>  '0');
    signal inicio           :  std_logic;
    signal clk              :  std_logic := '0';
    signal led_tapa         :  std_logic;
    signal led_lavado       :  std_logic;
    signal led_centrifugado :  std_logic;
    signal led_enjuague     :  std_logic;


    constant clk_period : time := 1 ns;
begin
    uut: Lavarropas
    port map(
        perilla          => perilla,          
        inicio           => inicio,           
        clk              => clk,              
        led_tapa         => led_tapa,         
        led_lavado       => led_lavado,       
        led_centrifugado => led_centrifugado, 
        led_enjuague     => led_enjuague     
    );

    clk_process :process
        variable contadorTB : integer range 0 to 200 := 0;
        begin
        contadorTB := contadorTB + 1;
        if contadorTB < 199 then 
            clk <= '0';
            wait for clk_period/2;  --for 0.5 ns signal is '0'.
            clk <= '1';
            wait for clk_period/2;  --for next 0.5 ns signal is '1'.
        else
        wait;
        end if;
   end process;

   tb_process :process
        variable contador : integer := 0;
        begin
        inicio <= '1';
        perilla <= "000";
        perilla <= "111";
        wait for 0.5 ns;
        wait;
    end process;
        
end architecture;