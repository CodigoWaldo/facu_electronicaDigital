library ieee;
use ieee.std_logic_1164.all;

-- /////////////////////////////////////////////
-- Declaración de los puertos de entrada y salida que se utilizaran.
entity Lavarropas is
port(
    perilla          : in std_logic_vector(2 downto 0) := "000";
    inicio           : in std_logic := '0';
    clk              : in std_logic := '0';
    led_tapa         : out std_logic := '0' ;
    led_lavado       : out std_logic := '0';
    led_centrifugado : out std_logic := '0';
    led_enjuague     : out std_logic := '0'
);
end entity;
-- /////////////////////////////////////////////

-- /////////////////////////////////////////////
-- Definición de la arquitectura asociada a las entidades.
-- A partir de aquí se describe la operación y organización del circuito.

architecture sens of Lavarropas is
    signal Contador : integer range 0 to 63 := 0;
    
----------- clases utilizadas
    component Motor
    port(
        med : in std_logic;
        alt : in std_logic
        );
    end component;
        
    component Bomba
    port(
        act_bomba : in std_logic
        );
    end component;

    component Valvula
    port(
        act_valvula : in std_logic
    );
    end component;

    component Sensor
    port(
        sal_sensor : out std_logic
    );
    end component;

    component Electroiman
    port(
        act_electroiman : in std_logic;
        salida_electroiman : out std_logic
    );
    end component;

---------- "cables" que indican las señales de cada entidad

    --CABLES 

    --Valvulas
    signal act_VJ : std_logic := '0';
    signal act_VS : std_logic := '0';
    signal act_VL : std_logic := '0';
    signal act_VV : std_logic := '0';

    --Motor
    signal alt : std_logic := '0';
    signal med : std_logic := '0';

    --Bomba
    signal act_bomba : std_logic := '0';

    --Electroiman
    signal act_electroiman : std_logic := '0';
    signal salida_electroiman : std_logic := '0';

    --Sensores
    signal sal_sensor0 : std_logic := '0';
    signal sal_sensor1 : std_logic := '0';
    signal sal_sensor2 : std_logic := '0';
    signal sal_sensor3 : std_logic := '0';
    signal sal_sensor4 : std_logic := '0';

    --Maquina de Estados
    signal state_reg  : std_logic_vector(4 downto 0);
    signal next_state : std_logic_vector(4 downto 0);

    --Bandera
    signal lavado_flag : std_logic_vector(1 downto 0) := "00";

    --Estados
    Constant IDLE         : std_logic_vector(4 downto 0) := "00001";
    Constant LAVADO       : std_logic_vector(4 downto 0) := "00010";
    Constant ENJUAGUE     : std_logic_vector(4 downto 0) := "00100";
    Constant CENTRIFUGADO : std_logic_vector(4 downto 0) := "01000";
    Constant DESAGOTE     : std_logic_vector(4 downto 0) := "10000";
    begin

    --Valvulas
    VS: Valvula port map(
        act_valvula => act_VS
    ); 
    VJ: Valvula port map(
        act_valvula => act_VJ
    );
    VL: Valvula port map(
        act_valvula => act_VL
    );
    VV: Valvula port map(
        act_valvula => act_VV
    );

    --Motor
    CVM: Motor port map(
        alt => alt,
        med => med
    );
    
    --Bomba
    CB: Bomba port map(
        act_bomba => act_bomba
    );

    --Electroiman
    TT: Electroiman port map(
        act_electroiman => act_electroiman,
        salida_electroiman => salida_electroiman
    );

    --Sensores
    S0: Sensor port map(
        sal_sensor => sal_sensor0
    );

    S1: Sensor port map(
        sal_sensor => sal_sensor1
    );

    S2: Sensor port map(
        sal_sensor => sal_sensor2
    );

    S3: Sensor port map(
        sal_sensor => sal_sensor3
    );

    S4: Sensor port map(
        sal_sensor => sal_sensor4
    );
--------SIGUIENTE ESTADO
    process(next_state)
    begin                            
        if next_state'event then
            state_reg <= next_state;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            Contador <= Contador + 1;
            led_tapa <= salida_electroiman;
            case state_reg is
--------IDLE Y ELECTROIMAN--------------------------------------------------------------------------------------------
                when IDLE=>
                    act_electroiman <= '0';
                    if inicio = '1' then
                        if perilla = "001" or perilla = "011" or perilla = "101" or perilla = "111" then
                            Contador <= 0;
                            next_state <= LAVADO;
                        end if;
                        if perilla = "110" or perilla = "010" then
                            Contador <= 0;
                            next_state <= ENJUAGUE;
                        end if;
                        if perilla = "100" then
                            Contador <= 0;
                            next_state <= CENTRIFUGADO;
                        end if;
                    else
                        Contador <= 0;
                        next_state <= IDLE;
                    end if;

--------LAVADO--------------------------------------------------------------------------------------------
                when LAVADO =>
                    
                    if Contador = 1 then 
                        act_electroiman <= '1';
                        led_lavado <= '1';
                        act_VJ <= '1';
                        act_VL <= '1';
                    elsif Contador = 6 then 
                        act_VJ <= '0';
                        act_VL <= '0';
                        if sal_sensor2 = '0' or sal_sensor4 = '1' then
                            Contador <= 0;
                            led_lavado <= '0';
                            lavado_flag <= "10";
                            next_state <= DESAGOTE;
                            else
                            med <= '1';
                        end if;
                    elsif Contador = 36 then
                            lavado_flag <= "01";
                            med <= '0';
                            Contador <= 0;
                            led_lavado <= '0';
                            next_state <= DESAGOTE;
                    end if;
                
--------ENJUAGUE--------------------------------------------------------------------------------------------
                when ENJUAGUE =>
                    if Contador = 1 then 
                        act_electroiman <= '1';
                        led_enjuague <= '1';
                        act_VS <= '1';
                        act_VL <= '1';
                    elsif Contador = 6 then 
                        act_VS <= '0';
                        act_VL <= '0';
                        if sal_sensor2 = '0' or sal_sensor4 = '1' then
                            Contador <= 0;
                            led_enjuague <= '0';
                            next_state <= DESAGOTE;
                            else
                            med <= '1';
                        end if;
                    elsif Contador = 36 then
                            med <= '0';
                            Contador <= 0;
                            led_enjuague <= '0';
                            next_state <= DESAGOTE;
                    end if;
                
--------CENTRIFUGADO--------------------------------------------------------------------------------------------
                when CENTRIFUGADO =>
                    if Contador = 1 then
                        led_centrifugado <= '1';
                        act_electroiman <= '1';
                        alt <= '1';
                    elsif Contador = 16 then
                        alt <= '0'; 
                        Contador <= 0;
                        led_centrifugado <= '0';
                        next_state <= IDLE;
                    end if;
--------DESAGOTE--------------------------------------------------------------------------------------------
                when DESAGOTE =>
                    if Contador = 1 then
                        act_VV <= '1';
                        act_bomba <= '1';
                    elsif Contador = 5 then
                        if perilla = "001" or perilla = "010" or lavado_flag = "10" then
                            Contador <= 0;
                            next_state <= IDLE;
                        elsif perilla = "101" or perilla = "110" then
                            Contador <= 0;
                            next_state <= CENTRIFUGADO;
                        elsif perilla = "111" or perilla = "011" then
                            if lavado_flag = "00" then
                                Contador <= 0;
                                next_state <= ENJUAGUE;
                            else 
                                lavado_flag <= "00";
                                if perilla = "111" then
                                    Contador <= 0;
                                    next_state <= CENTRIFUGADO;
                                else
                                    Contador <= 0;
                                    next_state <= IDLE;
                                end if;
                            end if;
                        end if;
                        act_bomba <= '0';
                        act_VV <= '0';
                    end if;
                when others =>
                Contador <= 0;
                next_state <= IDLE;
            end case;
        end if;   
    end process;

end architecture;
-- /////////////////////////////////////////////