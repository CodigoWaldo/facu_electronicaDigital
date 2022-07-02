library ieee;
use ieee.std_logic_1164.all;

entity Electroiman is
port(
    act_electroiman : in std_logic;
    salida_electroiman : out std_logic
);
end entity;

architecture sens of Electroiman is
begin
    salida_electroiman <= act_electroiman;
end architecture;