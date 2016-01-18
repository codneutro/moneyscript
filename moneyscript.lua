----------------------------------------------------------------------
-- Project: moneyscript                                             --
-- Author: x[N]ir                                                   --
-- Date: 18.01.2016                                                 --
-- File: moneyscript.lua                                            --
-- Description: displays players money during the freeze time       --
----------------------------------------------------------------------

-----------------------
--     CONSTANTS     -- 
-----------------------
if moneyscript == nil then moneyscript = {}; end
moneyscript.YELLOW = string.char(169).."255255000";
moneyscript.RED = string.char(169).."255000000";
moneyscript.GREEN = string.char(169).."000255000";

-----------------------
--     VARIABLES     -- 
-----------------------
moneyscript.playersHudtxts = {};

----------------------------------------------------------------------
-- StartRound Hook Implementation                                   --
--                                                                  --
-- @param mode start/end mode id                                    --
----------------------------------------------------------------------
function moneyscript.onStartRound(mode)
	--[[ 
		For each player alive, the script clears the previous hudtxt
		if possible, and then displays the current player money
	]]--


end

----------------------------------------------------------------------
-- Buy Hook Implementation                                          --
--                                                                  --
-- @param id player id                                              --
-- @param weapon type id of requested weapon                        --
----------------------------------------------------------------------
function moneyscript.onBuy(id, weapon)
	--[[ 
		If a player buys a weapon, his hudtxt is updated
	]]--
end

----------------------------------------------------------------------
-- hudtxt2 wrapper                                                  --
--                                                                  --
-- @param pid id of a player                                        --
-- @param id internal text id                                       --
-- @param text the text you want to display                         --
-- @param x x position                                              --
-- @param y y position                                              --
-- @param align txt alignment (centered by default)                 --
-- @return the text id                                              --
----------------------------------------------------------------------
function moneyscript.hudtxt2(pid, id, text, x, y, align)
	if(not align) then align = 1; end
	local color = moneyscript.YELLOW;
	local money;

	if(text:match("%d+")) then
		money = tonumber(text:match("(%d+)"));
		if(player(id, "team") == 1) then
			if(money < 1000) then
				color = moneyscript.RED;
			elseif(money < 3150) then
				color = moneyscript.YELLOW;
			else
				color = moneyscript.GREEN;
			end
		elseif(player(id, "team") == 2) then
			if(money < 1000) then
				color = moneyscript.RED;
			elseif(money < 3750) then
				color = moneyscript.YELLOW;
			else
				color = moneyscript.GREEN;
			end
		end
	end

	parse('hudtxt2 '..pid..' '..id..' "'..color..text..'" '..x..' '..y..
		' '..align);
	return id;
end

----------------------------------------------------------------------
-- Removes the specied hud txt of a player                          --
--                                                                  --
-- @param pid id of a player                                        --
-- @param id internal text id                                       --
-- @param text the text you want to display                         --
----------------------------------------------------------------------
function moneyscript.clearhudtxt2(pid, id)
	parse('hudtxt2 '..pid..' '..id);
end

----------------------------------------------------------------------
-- Join Hook Implementation                                         --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
function moneyscript.onJoin(id)
	--[[
		If a new player arrives on the server, the script initialize
		his txt value
	]]--
end

----------------------------------------------------------------------
-- Leave Hook Implementation                                        --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
function moneyscript.onLeave(id)
	--[[
		If a player leaves the server then the script sets to nil
		his txt value
	]]--
	moneyscript.playersHudTxts[id] = nil;
end




