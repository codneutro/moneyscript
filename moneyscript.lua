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

		addhook("buy", "moneyscript.onBuy");
		for _, id in pairs(player(0, "tableliving")) do
			moneyscript.playersHudTxts[id] = {};
			for __, iid in pairs(player(0, "tableliving")) do
				if(player(id, "team") == player(iid, "team") and
					id ~= iid) then
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
	freehook("buy", "moneyscript.onBuy");
	moneyscript.clearAllTxts();
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
	local team = player(id, "team");
	local players;

	if(team == 1) then
		players = player(0, "team1living");
	else
		players = player(0, "team2living");
	end

	for _, pid in pairs(players) do
		if(pid ~= id) then
			moneyscript.updatehudtxt2(pid, id, player(id, "money").."$");
		end
	end

	return 0;
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
-- Removes the specied hud txt of a player                          --
--                                                                  --
-- @param pid id of a player                                        --
-- @param id internal text id                                       --
----------------------------------------------------------------------
function moneyscript.clearhudtxt2(pid, id)
	parse('hudtxt2 '..pid..' '..id);
end

----------------------------------------------------------------------
-- Updates the specied hud txt of a player                          --
--                                                                  --
-- @param pid id of a player                                        --
-- @param id internal text id                                       --
----------------------------------------------------------------------
function moneyscript.updatehudtxt2(pid, id, text)
	if(moneyscript.playersHudTxts[pid][id]) then
		local winX, winY = 320, 240;
		winX = winX - math.floor(player(pid, "x") - player(id, "x"));
		winY = winY - math.floor(player(pid, "y") - player(id, "y"));
		moneyscript.playersHudTxts[pid][id] = 
			moneyscript.hudtxt2(pid, id, text, winX, winY - 32);
	end
end

----------------------------------------------------------------------
-- Removes all player hud txts                                      --
----------------------------------------------------------------------
function moneyscript.clearAllTxts()
	for _, id in pairs(player(0, "tableliving")) do 
		if(moneyscript.playersHudTxts[id]) then
			for __, tid in pairs(moneyscript.playersHudTxts[id]) do
				if(moneyscript.playersHudTxts[id][tid]) then
					moneyscript.clearhudtxt2(id, tid);
				end
			end
		end
	end
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

----------------------------------------------------------------------
-- Returns the distance between 2 objects                           --
--                                                                  --
-- @param x1 object one x position                                  --
-- @param y1 object one y position                                  --
-- @param x2 object two x position                                  --
-- @param y2 object two y position                                  --
-- @return the distance betwenn the 2 objects                       --
----------------------------------------------------------------------
function moneyscript.getDist(x1, y1, x2, y2)
	return math.sqrt((y2 - y1) ^ 2 + (x2 - x1) ^ 2);
end


