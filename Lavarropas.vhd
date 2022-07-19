library ieee;
use ieee.std_logic_1164.all;

entity Lavarropas is
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
end entity;
          
architecture sens of Lavarropas is
    --Contador
    signal cont : integer range 0 to 63 := 0;

    --Registro de estado
    signal state_reg  : std_logic_vector(5 downto 0);

    --Bandera
    signal camino : std_logic_vector(1 downto 0) := "00";

    --Estados
    Constant IDLE         : std_logic_vector(5 downto 0) := "000001";
    Constant LAVADO       : std_logic_vector(5 downto 0) := "000010";
    Constant ENJUAGUE     : std_logic_vector(5 downto 0) := "000100";
    Constant CENTRIFUGADO : std_logic_vector(5 downto 0) := "001000";
    Constant LLENADO      : std_logic_vector(5 downto 0) := "010000";
    Constant DESAGOTE     : std_logic_vector(5 downto 0) := "100000";
    
    begin
    process(clk)
    begin
        if rising_edge(clk) then
            cont <= cont + 1 ;
            case state_reg is
--------------------------------------------------- SELECTOR DEL PROGRAMA
                when IDLE=>
                    act_electroiman <= '0';
                    led_tapa <= '0';
                    if inicio = '1' then
                        if perilla = "001" or  perilla = "011" or  perilla = "101" or  perilla = "111" then
                            camino <= "00";
                            cont <= 0;
                            state_reg <= LLENADO;
                        elsif perilla = "010" or perilla = "110" then
                            camino <= "01";
                            cont <= 0;
                            state_reg <= LLENADO;
                        elsif perilla = "100" then
                            cont <= 0;
                            camino <= "11";
                            state_reg <= CENTRIFUGADO;
                        end if;
                    else
                        cont <= 0;
                        state_reg <= IDLE;
                    end if;
--------------------------------------------------- PROGRAMA LAVADO
                when LAVADO =>
                    act_electroiman <= '1';
                    led_tapa <= '1';
                    if cont = 1 then
                        led_lavado <= '1';
                        med <= '1';
                    elsif cont = 30 then --tiempo de lavado, 30 minutos
                        led_lavado <= '0';
                        med <= '0';
                        cont <= 0;
                        if perilla = "001" then
                            camino <= "11";
                        elsif perilla = "101" then
                            camino <= "10";
                        elsif perilla = "011" or perilla = "111" then
                            camino <= "01"; 
                        end if;
                        led_lavado <= '0';
                        cont <= 0;
                        state_reg <= DESAGOTE;
                    end if;
--------------------------------------------------- PROGRAMA ENJUAGUE
                when ENJUAGUE =>
                    act_electroiman <= '1';
                    led_tapa <= '1';
                    if cont = 1 then
                        led_enjuague <= '1';
                        med <= '1';
                    elsif cont = 30 then --tiempo de enjuague, 30 minutos
                        med <= '0';
                        cont <= 0;
                        led_enjuague <= '0';
                        if perilla = "010" or perilla = "011" then
                            camino <= "11";
                        elsif perilla = "110" or perilla = "111" then
                            camino <= "10";
                        end if;
                        led_enjuague <= '0';
                        state_reg <= DESAGOTE;
                    end if;
--------------------------------------------------- PROGRAMA CENTRIFUGADO
                when CENTRIFUGADO =>
                    act_electroiman <= '1';
                    led_tapa <= '1';
                    if cont = 1 then
                        led_centrifugado <= '1';
                        if sal_sensor0 = '1' then
                            led_centrifugado <= '0';
                            camino <= "10";
                            cont <= 0;
                            alt <= '0';
                            state_reg <= DESAGOTE;
                        else
                            alt <= '1';
                        end if;
                    elsif cont = 15 then --tiempo de centrifugado, 15 minutos
                        alt <= '0';
                        camino <= "00";
                        cont <= 0;
                        led_centrifugado <= '0';
                        state_reg <= DESAGOTE;
                    else 

                    end if;
--------------------------------------------------- PROGRAMA LLENADO
                when LLENADO =>
                    act_electroiman <= '1';
                    led_tapa <= '1';
                    if sal_sensor4 = '0' then
                        if cont = 1 and sal_sensor2 = '0' then
                            if camino = "00" then 
                                act_VL <= '1';
                                act_VJ <= '1';
                            elsif camino = "01" then
                                act_VL <= '1';
                                act_VS <= '1';
                            end if;
                        elsif sal_sensor2 = '1' and cont < 5 then --CASO DE ERROR CORTE DE AGUA
                            act_VL <= '0';
                            act_VS <= '0';
                            act_VJ <= '0';
                            if camino = "00" then
                                cont <= 0;
                                state_reg <= LAVADO;
                            else
                                cont <= 0;
                                state_reg <= ENJUAGUE;
                            end if;
                        elsif cont = 5 then
                            act_VL <= '0';
                            act_VS <= '0';
                            act_VJ <= '0'; 
                            camino <= "11";
                            cont <= 0;
                            state_reg <= DESAGOTE;
                        end if;
                    else --CASO DE ERROR SOBRELLENADO
                        act_VL <= '0';
                        act_VS <= '0';
                        act_VJ <= '0'; 
                        camino <= "11";
                        cont <= 0;
                        state_reg <= DESAGOTE;
                    end if;
--------------------------------------------------- PROGRAMA DESAGOTE
                when DESAGOTE =>
                    act_electroiman <= '1';
                    led_tapa <= '1';
                    if cont = 1 and sal_sensor0 = '1' then
                        act_bomba <= '1';
                        act_VV <= '1';
                    elsif cont > 1 and sal_sensor0 = '0' then
                        act_bomba <= '0';
                        act_VV <= '0';
                        if camino = "01" then
                            cont <= 0;
                            state_reg <= LLENADO;
                        elsif camino = "10" then
                            cont <= 0;
                            state_reg <= CENTRIFUGADO;
                        else
                            cont <= 0;
                            state_reg <= IDLE;
                        end if;
                    elsif cont = 5 and sal_sensor0 = '1' then --CASO DE ERROR NO ESTA VACIANDO (FLUJO OBSTRUIDO)
                        act_bomba <= '0';
                        cont <= 0;
                        state_reg <= IDLE;
                    elsif cont = 1 and sal_sensor0 = '0' then
                        act_bomba <= '0';
                        cont <= 0;
                        state_reg <= IDLE;
                    end if;
--------------------------------------------------- En caso de falla de memoria (estado inexistente)
                when others =>
                cont <= 0;
                state_reg <= IDLE;
            end case;
        end if;   
    end process;
end architecture;