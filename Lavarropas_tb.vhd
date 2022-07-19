library ieee;
use ieee.std_logic_1164.all;

entity Lavarropas_tb is
end entity;

architecture sens of Lavarropas_tb is
    component Lavarropas
    port(
      -- Perilla
      perilla          : in std_logic_vector(2 downto 0) := "000";
      -- Boton inicio  
      inicio           : in std_logic  := '0';
      -- Clock                     
      clk              : in std_logic  := '0';
      -- Sensores                     
      sal_sensor0      : in std_logic  := '0';
      sal_sensor1      : in std_logic  := '0';                  
      sal_sensor2      : in std_logic  := '0';
      sal_sensor3      : in std_logic  := '0';
      sal_sensor4      : in std_logic  := '0';
      -- Valvulas  
      act_VL           : out std_logic  := '0';                    
      act_VS           : out std_logic  := '0';
      act_VJ           : out std_logic  := '0';
      act_VV           : out std_logic  := '0';
      -- Motor 
      med              : out std_logic  := '0';                    
      alt              : out std_logic  := '0';
      -- Bomba 
      act_bomba        : out std_logic  := '0';
      -- Electroiman                    
      act_electroiman  : out std_logic  := '0';
      -- Leds                    
      led_tapa         : out std_logic := '0';                   
      led_lavado       : out std_logic := '0';
      led_centrifugado : out std_logic := '0';
      led_enjuague     : out std_logic := '0'

    );
    end component;

    -- Perilla
    signal perilla          :  std_logic_vector(2 downto 0) := (others =>  '0');
    -- Boton inicio  
    signal inicio           :  std_logic  := '0';
    -- Clock                     
    signal clk              : std_logic  := '0';
    -- Sensores                     
    signal sal_sensor0      : std_logic  := '0';
    signal sal_sensor1      : std_logic  := '0';                  
    signal sal_sensor2      : std_logic  := '0';
    signal sal_sensor3      : std_logic  := '0';
    signal sal_sensor4      : std_logic  := '0';
    -- Valvulas  
    signal act_VL           : std_logic  := '0';                    
    signal act_VS           : std_logic  := '0';
    signal act_VJ           : std_logic  := '0';
    signal act_VV           : std_logic  := '0';
    -- Motor 
    signal med              : std_logic  := '0';                    
    signal alt              : std_logic  := '0';
    -- Bomba 
    signal act_bomba        : std_logic  := '0';
    -- Electroiman                    
    signal act_electroiman  : std_logic  := '0';
    -- Leds                    
    signal led_tapa         : std_logic := '0';                   
    signal led_lavado       : std_logic := '0';
    signal led_centrifugado : std_logic := '0';
    signal led_enjuague     : std_logic := '0';
   

    constant clk_period : time := 1 ns;
begin
    uut: Lavarropas
    port map(
        -- Perilla
        perilla          => perilla,
        -- Boton inicio
        inicio           => inicio,
        -- Clock      
        clk              => clk,
        -- Sensores    
        sal_sensor0      => sal_sensor0,       
        sal_sensor1      => sal_sensor1,       
        sal_sensor2      => sal_sensor2,       
        sal_sensor3      => sal_sensor3,       
        sal_sensor4      => sal_sensor4,       
        -- Valvulas  
        act_VL           => act_VL,            
        act_VS           => act_VS,            
        act_VJ           => act_VJ,            
        act_VV           => act_VV,            
        -- Motor 
        med              => med,               
        alt              => alt,               
        -- Bomba 
        act_bomba        => act_bomba,         
        -- Electroiman  
        act_electroiman  => act_electroiman,   
        -- Leds         
        led_tapa         => led_tapa,          
        led_lavado       => led_lavado,        
        led_centrifugado => led_centrifugado,  
        led_enjuague     => led_enjuague      
);  

    clk_process :process
        variable contadorTB : integer range 0 to 10000 := 0;
        begin
        contadorTB := contadorTB + 1;
        if contadorTB < 9999 then 
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
            --perilla <= "000"; --IDLE
            --wait for 5 ns;
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 5 ns;
    
            perilla <= "111";
            inicio <= '1';
            wait for 5 ns;
            sal_sensor2 <= '1';
            sal_sensor0 <= '1';
            inicio <= '0';
            wait for 36 ns;
            sal_sensor2 <= '0';
            sal_sensor0 <= '0';
            wait for 6 ns;
            sal_sensor2 <= '1';
            sal_sensor0 <= '1';
            wait for 36 ns;
            sal_sensor2 <= '0';
            sal_sensor0 <= '0';
            wait for 10 ns;
            sal_sensor0 <= '1';
            wait for 11 ns;
            sal_sensor0 <= '0';

    
            --perilla <= "010"; --ENJUAGUE
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 50 ns;
    
            --perilla <= "100"; --CENTRIFUGADO
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 50 ns;
    --
            --perilla <= "011"; --LAVADO Y ENJUAGUE
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 100 ns;
    --
            --perilla <= "101"; --LAVADO Y CENTRIFUGADO
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 100 ns;
    --
            --perilla <= "110"; --ENJUAGUE Y CENTRIFUGADO
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 100 ns;
    --
            --perilla <= "111"; --LAVADO ENJUAGUE Y CENTRIFUGADO
            --inicio <= '1';
            --wait for 3 ns;
            --inicio <= '0';
            --wait for 100 ns;
        wait;
    end process;
        
end architecture;