--[[***********************************************************************************
                              IW6X SERVER SCRIPTS                               *****
***********************************************************************************
**
** - Name        : Location Callout HUD Lua Script for COD GHOSTS IW6X [REVISION 1]
** - Description : Text HUD Displays players current location callout name
** - Author      : Hosseinpourziyaie | Helpers: GEEKiDoS, DoktorSAS
** - Note        :  --------------------------------------------------
** - Started on  : 1 January 2021    | Ended on : 1 January 2020
** 
** [WARNING] consider giving credits to author if you planning to use this script
** 
** 
** 
** [NOTE] callout data for mp_swamp , mp_conflict were recorded by Hosseinpourziyaie
** 
** 
** [Copyright © Hosseinpourziyaie 2020] <hosseinpourziyaie@gmail.com>
** 
*********************************************************************************--]]

function get_coordinate_callout(origin)
  for _, data in ipairs(global_calloutpoints) do
    --print("[DEBUG]" .. data.callout .. " -> " .. data.center.x .. "," .. data.center.y .. "," .. data.center.z .. " -> " .. data.radius)
    if game:distance(data.center,origin) < data.radius then
        return data.callout
    end
  end
  return ""
end

function refresh_pos(text_hud, bg_hud, player)
  if game:isalive( player ) then
    local player_location = get_coordinate_callout( player.origin )
    text_hud:settext( player_location );
    if string.len( player_location ) > 0 then bg_hud.alpha = 0.6; else bg_hud.alpha = 0.0; end
  else
    text_hud:settext(""); bg_hud.alpha = 0.0;
  end
end

function setup_callout_hud(player)
    local bg_hud = game:newclienthudelem(player);
    bg_hud.alpha = 0.0;
    bg_hud.alignx = "left";
    bg_hud.aligny = "top";
    bg_hud.horzalign = "left";
    bg_hud.vertalign = "top";
    bg_hud.x = -36;
    bg_hud.y = 82;
    bg_hud.hidewheninmenu = true;
    --hud.archived = 1;
    bg_hud:setshader("black", 183, 12); // back in v1.1.0 was --> setmaterial


    local callouthud = game:newclienthudelem(player);
    callouthud.alpha = 1.0;
    callouthud.font = "objective";
    callouthud.fontscale = 1.0;
    callouthud.alignx = "left";
    callouthud.aligny = "top";
    callouthud.horzalign = "left";
    callouthud.vertalign = "top";
    callouthud.x = -34;
    callouthud.y = 82;
    --[[callouthud.x = 148;
    callouthud.y = -18;--]]
    callouthud.hidewheninmenu = true;
    callouthud:settext("");

    local refresh_interval = game:oninterval(function() refresh_pos(callouthud, bg_hud, player) end, 200) 

    function disconnect_callback()
        refresh_interval:clear()
        callouthud:delete()
    end

    player:onnotifyonce("disconnect", disconnect_callback)
end

function player_connected(player)
    if tablelength(global_calloutpoints) > 0 then setup_callout_hud(player) end
end

function setup_callout_points(map)

    ---------------        MAP FOG : I love horror movies. this is my kinda map!        ---------------
    if map == "mp_swamp" then
	global_calloutpoints[1] = {}
	global_calloutpoints[1]["callout"] = "TV CABIN" 
	global_calloutpoints[1]["center"] = vector:new(-60.90, -1875.30, 56.80)
	global_calloutpoints[1]["radius"] = 180.00

	global_calloutpoints[2] = {}
	global_calloutpoints[2]["callout"] = "CAMP"
	global_calloutpoints[2]["center"] = vector:new(930.60, 1790.00, 47.30)
	global_calloutpoints[2]["radius"] = 341.10
	
	global_calloutpoints[3] = {}
	global_calloutpoints[3]["callout"] = "SHED"
	global_calloutpoints[3]["center"] = vector:new(-187.70, 1994.90, 83.30)
	global_calloutpoints[3]["radius"] = 132.40
		
	global_calloutpoints[4] = {}
	global_calloutpoints[4]["callout"] = "SHRINE"
	global_calloutpoints[4]["center"] = vector:new(507.80, 511.60, 150.00)
	global_calloutpoints[4]["radius"] = 110.00
	
	global_calloutpoints[5] = {}
	global_calloutpoints[5]["callout"] = "PIT"
	global_calloutpoints[5]["center"] = vector:new(750.20, 134.20, 142.50)
	global_calloutpoints[5]["radius"] = 240.00
	
	global_calloutpoints[6] = {}
	global_calloutpoints[6]["callout"] = "CAVE"
	global_calloutpoints[6]["center"] = vector:new(763.40, 306.30, 194.00)
	global_calloutpoints[6]["radius"] = 797.00

	global_calloutpoints[7] = {}
	global_calloutpoints[7]["callout"] = "UNDERGROUND"
	global_calloutpoints[7]["center"] = vector:new(-375.80, 666.00, -180.90)
	global_calloutpoints[7]["radius"] = 296.00

	global_calloutpoints[8] = {}
	global_calloutpoints[8]["callout"] = "COURTYARD"
	global_calloutpoints[8]["center"] = vector:new(-808.80, 1693.00, 93.00)
	global_calloutpoints[8]["radius"] = 400.00
	
	global_calloutpoints[9] = {}
	global_calloutpoints[9]["callout"] = "HOUSE"
	global_calloutpoints[9]["center"] = vector:new(-616.20, 1065.80, 165.60)
	global_calloutpoints[9]["radius"] = 660.00
	
	global_calloutpoints[10] = {}
	global_calloutpoints[10]["callout"] = "PUMPKIN"
	global_calloutpoints[10]["center"] = vector:new(603.60, -2080.50, -2.20)
	global_calloutpoints[10]["radius"] = 172.00
	
	global_calloutpoints[11] = {}
	global_calloutpoints[11]["callout"] = "MARINA"
	global_calloutpoints[11]["center"] = vector:new(665.00, -1400.00, 41.40)
	global_calloutpoints[11]["radius"] = 315.20
	
	global_calloutpoints[12] = {} -- This should be re-coordinated as 2 seprate sphere for accurate location
	global_calloutpoints[12]["callout"] = "BACKDOOR CAVE"
	global_calloutpoints[12]["center"] = vector:new(-456.00, -30.30, -422.30)
	global_calloutpoints[12]["radius"] = 570.00
	
	---------------        MAP DYNASTY : boiii I love chineese villages Architecture!        ---------------
	elseif map == "mp_conflict" then 	
	global_calloutpoints[1] = {} 
	global_calloutpoints[1]["callout"] = "VILLAGE GATE"
	global_calloutpoints[1]["center"] = vector:new(-1982.60, 2805.60, 693.00)
	global_calloutpoints[1]["radius"] = 360.00

	global_calloutpoints[2] = {} 
	global_calloutpoints[2]["callout"] = "TUNNEL"
	global_calloutpoints[2]["center"] = vector:new(-930.20, 748.00, 392.80)
	global_calloutpoints[2]["radius"] = 188.00
	
	global_calloutpoints[3] = {} 
	global_calloutpoints[3]["callout"] = "TUNNEL"
	global_calloutpoints[3]["center"] = vector:new(-928.10, 903.20, 398.00)
	global_calloutpoints[3]["radius"] = 192.00
	
	global_calloutpoints[4] = {} 
	global_calloutpoints[4]["callout"] = "STORM"
	global_calloutpoints[4]["center"] = vector:new(-908.00, 1218.00, 344.00)
	global_calloutpoints[4]["radius"] = 280.00
	
	global_calloutpoints[5] = {} 
	global_calloutpoints[5]["callout"] = "BAR"
	global_calloutpoints[5]["center"] = vector:new(-1058.00, 790.00, 730.00)
	global_calloutpoints[5]["radius"] = 302.00
	
	global_calloutpoints[6] = {} 
	global_calloutpoints[6]["callout"] = "FOUNTAIN"
	global_calloutpoints[6]["center"] = vector:new(-600.00, 534.00, 549.20)
	global_calloutpoints[6]["radius"] = 282.00

	global_calloutpoints[7] = {} 
	global_calloutpoints[7]["callout"] = "NETS"
	global_calloutpoints[7]["center"] = vector:new(1350.00, 604.00, 498.00)
	global_calloutpoints[7]["radius"] = 756.00

	global_calloutpoints[8] = {} 
	global_calloutpoints[8]["callout"] = "POT SHOP"
	global_calloutpoints[8]["center"] = vector:new(-1463.40, 412.00, 659.80)
	global_calloutpoints[8]["radius"] = 286.00
	
	global_calloutpoints[9] = {} 
	global_calloutpoints[9]["callout"] = "CAFE"
	global_calloutpoints[9]["center"] = vector:new(-1942.60, 1016.40, 774.80)
	global_calloutpoints[9]["radius"] = 240.00

	global_calloutpoints[10] = {} 
	global_calloutpoints[10]["callout"] = "DUMPSTER"
	global_calloutpoints[10]["center"] = vector:new(-2488.00, 1348.60, 653.40)
	global_calloutpoints[10]["radius"] = 194.00

	---------------        MAP FAVELA : the football stadium boiii!                          ---------------
    elseif map == "mp_favela_iw6" then
	global_calloutpoints[1] = {}
	global_calloutpoints[1]["callout"] = "GRAVEYARD"
	global_calloutpoints[1]["center"] = vector:new(-900.60, -979.80, 4.20)
	global_calloutpoints[1]["radius"] = 448.00
	
	global_calloutpoints[2] = {}
	global_calloutpoints[2]["callout"] = "BARBER SHOP"
	global_calloutpoints[2]["center"] = vector:new(-834.90, -331.90, 98.40)
	global_calloutpoints[2]["radius"] = 282.00
	
	global_calloutpoints[3] = {}
	global_calloutpoints[3]["callout"] = "BUS STOP"
	global_calloutpoints[3]["center"] = vector:new(-1376.60, -212.00, -7.40)
	global_calloutpoints[3]["radius"] = 186.00

    else
      print("[ WARNING ] no callout data for map " .. map .. " found. skipping Callout HUD plugin load")
    end
end

---------------                        MAIN INITIALIZE                       ---------------

level:onnotify("connected", player_connected)

global_calloutpoints = {}          -- create the matrix
setup_callout_points(game:getdvar("mapname"))


---------------  [DEVELOPER TOOL]THIS PART IS FOR RECORDING CALLOUT POINTS   ---------------

--[[function append_log(data)
   local f = io.open(("%s.log"):format(game:getdvar("mapname")), "a");
    f:write(data);
    f:flush();
    f:close();
end

local lastCenter = nil;

local onPlayerSay = function (player, msg)
    msg = string.lower(msg);

    if msg == "!start" then
	    lastCenter = player.origin;
        append_log("	global_calloutpoints[i][\"center\"] = vector:new(" .. player.origin.x .. ", " .. player.origin.y .. ", " .. player.origin.z .. ")\n")
        player:iclientprintlnbold("center saved -> " .. player.origin.x .. "," .. player.origin.y .. "," .. player.origin.z);
    elseif msg == "!end" then
	    append_log("	global_calloutpoints[i][\"radius\"] = " .. game:distance(player.origin,lastCenter) .. "\n")
        player:iclientprintlnbold("radius saved -> " .. game:distance(player.origin,lastCenter) .. " from (" .. player.origin.x .. "," .. player.origin.y .. "," .. player.origin.z .. ")");	    
	end
end


local onPlayerConnected = function (player)

    local saylistener = player:onnotify("say", function(msg) onPlayerSay(player, msg) end);
    player:onnotifyonce("disconnect", function () saylistener:clear(); end)
end	

level:onnotify("connected", onPlayerConnected);

-- game:precachematerial( "gradient_fadein" ); -- precacheShader
--]]

---------------                        EXTRA UTILITIES                       ---------------

function tablelength(T) -- https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
	
