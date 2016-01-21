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
moneyscript.playersHudTxts = {};

----------------------------------------------------------------------
-- StartRound Hook Implementation                                   --
--                                                                  --
-- @param mode start/end mode id                                    --
----------------------------------------------------------------------
addhook("startround", "moneyscript.onStartRound");
function moneyscript.onStartRound(mode)
	--[[ 
		For each player alive, the script resets the players arrays
		then the script displays the other players money if
		they are in the same team starting from the center of the 
		screen. Finally, all texts will be removed at the end of the
		freeze time.
	]]--

	if(tonumber(game("mp_freezetime")) > 0) then
		local winX, winY = 320, 240;

		addhook("ms100", "moneyscript.ms100");
		addhook("leave", "moneyscript.onLeave");
		addhook("team", "moneyscript.onTeam");

		--> Forced restart, changing teams during freezetime
		freetimer("moneyscript.freezeTimeEnd");

		for _, id in pairs(player(0, "tableliving")) do
			moneyscript.clearPlayerTxt(id);
			moneyscript.playersHudTxts[id] = {};
			for __, iid in pairs(player(0, "tableliving")) do
				if(player(id, "team") == player(iid, "team")) then
					winX = 320;
					winY = 240;
					winX = winX - math.floor(player(id, "x") - player(iid, "x"));
					winY = winY - math.floor(player(id, "y") - player(iid, "y"));
					moneyscript.playersHudTxts[id][iid] =
						moneyscript.hudtxt2(id, iid, player(iid, "money").."$",winX, winY - 32);
				end
			end
		end

		timer((tonumber(game("mp_freezetime"))) * 1000, "moneyscript.freezeTimeEnd", 
			"", 1);
	end
end

----------------------------------------------------------------------
-- When freeze time ends                                            --
----------------------------------------------------------------------
function moneyscript.freezeTimeEnd()
	freehook("ms100", "moneyscript.ms100");
	freehook("leave", "moneyscript.onLeave");
	freehook("team", "moneyscript.onTeam");
	moneyscript.clearAllTxts();
end

----------------------------------------------------------------------
-- ms100 function                                                   --
----------------------------------------------------------------------
function moneyscript.ms100()
	--[[
		Using this way, instead of buy hook which leaded to some 
		problems
	]]--

	for _, pid in pairs(player(0, "tableliving")) do
		for __, id in pairs(player(0, "tableliving")) do
			if(player(pid, "team") == player(id, "team")) then
				moneyscript.updatehudtxt2(pid, id, player(id, "money").."$");
			end
		end
	end
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
	--[[
		Fixing alignment, sets the color depending on the player 
		money and finally displays the text
	]]--

	if(not align) then align = 1; end
	local color = moneyscript.YELLOW;
	local money;

	if(tostring(text):match("%d+")) then
		money = tonumber(tostring(text):match("(%d+)"));
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
-- Removes the specified hud txt of a player                        --
--                                                                  --
-- @param pid id of a player                                        --
-- @param id internal text id                                       --
----------------------------------------------------------------------
function moneyscript.clearhudtxt2(pid, id)
	parse('hudtxt2 '..pid..' '..id);
end

----------------------------------------------------------------------
-- Updates the specified hud txt of a player                        --
--                                                                  --
-- @param pid id of a player                                        --
-- @param id internal text id                                       --
----------------------------------------------------------------------
function moneyscript.updatehudtxt2(pid, id, text)
	if(moneyscript.playersHudTxts[pid]) then
		if(moneyscript.playersHudTxts[pid][id]) then
			local winX, winY = 320, 240;
			winX = winX - math.floor(player(pid, "x") - player(id, "x"));
			winY = winY - math.floor(player(pid, "y") - player(id, "y"));
			moneyscript.playersHudTxts[pid][id] = 
				moneyscript.hudtxt2(pid, id, text, winX, winY - 32);
		end
	end
end

----------------------------------------------------------------------
-- Removes all player hud txts                                      --
----------------------------------------------------------------------
function moneyscript.clearAllTxts()
	for _, id in pairs(player(0, "tableliving")) do 
		moneyscript.clearPlayerTxt(id);
	end
end

----------------------------------------------------------------------
-- Removes all hud texts of the specified player                    --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
function moneyscript.clearPlayerTxt(id)
	--[[
		If there is a text on the player screen, we iterate over all of
		them, then we clear them.
	]]--
	
	if(moneyscript.playersHudTxts[id]) then
		for _, tid in pairs(moneyscript.playersHudTxts[id]) do
			moneyscript.clearhudtxt2(id, tid);
		end
		moneyscript.playersHudTxts[id] = nil;
	end
end

----------------------------------------------------------------------
-- Removes the specified hudtxt from others players including       --
-- himself                                                          --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
function moneyscript.clearPlayerFromOthers(id)
	for _, pid in pairs(player(0, "tableliving")) do
		if(player(id, "team") == player(pid, "team")) then
			if(moneyscript.playersHudTxts[pid]) then
				if(moneyscript.playersHudTxts[pid][id]) then
					moneyscript.clearhudtxt2(pid, id);
					moneyscript.playersHudTxts[pid][id] = nil;
				end
			end
		end
	end
end

----------------------------------------------------------------------
-- Leave Hook Implementation                                        --
--                                                                  --
-- @param id player id                                              --
----------------------------------------------------------------------
function moneyscript.onLeave(id)
	--[[
		If a player leaves the server then the script removes his
		txt from him and from other players
	]]--

	moneyscript.clearPlayerFromOthers(id);
	moneyscript.playersHudTxts[id] = nil;
end

----------------------------------------------------------------------
-- Team Hook Implementation                                         --
--                                                                  --
-- @param id player id                                              --
-- @param team 0,1,2                                                --
-- @param look id 0,1,2, 3                                          --
----------------------------------------------------------------------
function moneyscript.onTeam(id, team, look)
	moneyscript.clearPlayerFromOthers(id);
	return 0;
end