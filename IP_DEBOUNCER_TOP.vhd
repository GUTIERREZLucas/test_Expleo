library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IP_DEBOUNCER_TOP is
--the below generic decide the working parameters.
    generic( G_DELAY : integer range 0 to 50000 := 20; -- delay time
            G_INIT : STD_LOGIC := '0' -- Define output value at reset
            );
    port(   i_clk : in std_logic;
            i_rebond : in std_logic;
            i_rst_n : in std_logic;
            o_anti_rebond : out std_logic
        );
end IP_DEBOUNCER_TOP;

architecture arch_IP_DEBOUNCER_TOP of IP_DEBOUNCER_TOP is
signal cpt : integer := 0; -- compteur de temporisation
signal val : std_logic := G_INIT; -- Valeur de la transition
signal i_rebond_delay : std_logic := i_rebond; -- Entrée i_rebond registré

type state_type is (IDLE,WAIT_STATE); --state machine
signal state : state_type := IDLE;

begin

--Machine d'état --
process(i_clk,i_rst_n,i_rebond)
begin
    if ( i_rst_n = '0') then
        o_anti_rebond <= G_INIT;
        i_rebond_delay <= i_rebond;
        cpt <= 0;
        state <= IDLE;  
    elsif(rising_edge(i_clk)) then
        case (state) is
            when IDLE =>
                if(i_rebond /= i_rebond_delay) then -- rebond sur le signal.
                    state <= WAIT_STATE;
                    val <= i_rebond;
                else
                    state <= idle; --pas de rebond sur le signal.
                end if;
            when WAIT_STATE =>
                if (i_rebond /= i_rebond_delay) then
                    cpt <= 0;
                else
                    if(cpt = G_DELAY) then
                        cpt <= 0;
                        if(i_rebond = val) then
                            o_anti_rebond <= val;
                        end if;
                        state <= IDLE;  
                    else
                        cpt <= cpt + 1;
                    end if;
                 end if;
             end case;
     i_rebond_delay <= i_rebond;      
    end if;        
end process;                  
                                                                                
end architecture arch_IP_DEBOUNCER_TOP;