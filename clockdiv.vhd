LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity clockdiv is port(
	CLK		: IN BIT;
	div		: integer;
	DIVOUT	: buffer BIT);
end clockdiv;

architecture behavioural of clockdiv is
	begin
		PROCESS(CLK)
			variable count: integer:=0;	
		begin
				if CLK'event and CLK='1' then
	
					if(count<div) then
						count:=count+1;						
						if(DIVOUT='0') then
							DIVOUT<='0';
						elsif(DIVOUT='1') then
							DIVOUT<='1';
						end if;
					else
						if(DIVOUT='0') then
							DIVOUT<='1';
						elsif(DIVOUT='1') then
							DIVOUT<='0';
						end if;
					count:=0;
					end if;

				end if;
		end process;
end behavioural;