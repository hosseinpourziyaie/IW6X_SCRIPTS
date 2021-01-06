--[[***********************************************************************************
                              IW6X SERVER SCRIPTS                               *****
***********************************************************************************
**
** - Name        : CINEMATIC FLIGHT TRAVEL [REVISION 1]
** - Description : spawn camera; then link player view to that; then fly it around 
** - Author      : Hosseinpourziyaie                                and then have fun :)
** - Note        :  --------------------------------------------------
** - Started on  : 5 January 2021    | Ended on : 5 January 2020
** 
** [WARNING] consider giving credits to author if you planning to use this script
** 
** [NOTE] As of this version Bezier Flight not available. Its just simple Linear fly
**         Its possible tho to have camera rotate with start_ang, finish_ang parameters 
** 
** [NOTE] travel pathz for mp_conflict, mp_shipment_ns and mp_swamp  
**                                               were recorded by Hosseinpourziyaie
** 
** 
** [Copyright © Hosseinpourziyaie 2020] <hosseinpourziyaie@gmail.com>
** 
*********************************************************************************--]]

function player_angles_lock_to_camera(target, source)
	--target:setplayerangles( source.angles )	
	--target.angles = source.angles
	target:setangles(source.angles)
end

function camera_movement(camera, s_origin, f_origin, s_angles, f_angles, length)	
	camera.origin = s_origin
	camera.angles = s_angles
		
	camera:moveto( f_origin, length )
	
	if s_angles ~= f_angles then
        camera:rotateto( f_angles, length, 0, 0 )
    end	
end

function travel_start(player)
	if tablelength(global_travel_paths) == 0 then return end
	
	local camera = game:spawn("script_model", player.origin)
	camera:setmodel("tag_origin")
	--camera:enablelinkto()
	
	local AnglesLockInterval = game:oninterval(function() player_angles_lock_to_camera(player, camera) end, 20)

	--player:linkto(camera)
	player:playerlinktodelta(camera, "tag_origin")
	player:freezecontrols( true )

	local total_length = 0;
	for _, data in ipairs(global_travel_paths) do	
	  if data.start_ang and data.finish_ang then
	    local setup_moveto = game:ontimeout(function() camera_movement(camera, data.start_pos, data.finish_pos, data.start_ang, data.finish_ang, data.fly_length) end, total_length * 1000)
      else
	    local setup_moveto = game:ontimeout(function() camera_movement(camera, data.start_pos, data.finish_pos, data.cam_angles, data.cam_angles, data.fly_length) end, total_length * 1000)
	  end
  	  
	  total_length = total_length + data.fly_length
	end

	local travel_dispose = game:ontimeout(function () player:unlink(); camera:delete(); AnglesLockInterval:clear(); travel_dispose(player); end, total_length * 1000);
end

function travel_dispose(player)
	--player:setclientdvar("cg_draw2d",1)
	--player:giveweapon("iw6_knifeonly_mp")
	 
	--player:setclientdvar("ui_hud_hardcore",0)
	--player:visionsetnaked( game:getdvar("mapname"), 3.0 );
	
	travel_start(player) -- repeat same routes forever :)
end

function travel_initialize(player)
	player:takeallweapons()
	player:setclientdvar("cg_draw2d",0)
	
	--player:setclientdvar("ui_hud_hardcore",1)
	--player:visionsetnaked( "mpOutro", 2.0 );
	
	travel_start(player)
end

function player_spawned(player)
    print("Player spawned: " .. player.name)
    --player:freezecontrols(false)
    --player:giveweapon("iw6_knifeonly_mp")
	--game:ontimeout(function () player:switchtoweapon("iw6_knifeonly_mp") end, 10);
	
    travel_initialize(player)
end

function player_connected(player)
    print("Player connected: " .. player.name)

    player:onnotifyonce("spawned_player", function() player_spawned(player) end)
end


function setup_travel_paths(map)
	---------------        MAP DYNASTY : boiii I love chineese villages Architecture!        ---------------   
    if map == "mp_conflict" then
	--[[global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos"]  = vector:new(-1876.00, 3210.80, 880.60)
	global_travel_paths[1]["finish_pos"] = vector:new(-1876.00, 3210.80, 686.20)
	global_travel_paths[1]["cam_angles"] = vector:new(00000.00, -106.40, 000.00)
	global_travel_paths[1]["fly_length"] = 20--]]

	global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos" ] = vector:new(-1653.96, 3159.90, 866.87)
	global_travel_paths[1]["finish_pos"] = vector:new(-2217.00, 3163.20, 846.26)
	global_travel_paths[1]["start_ang" ] = vector:new(00008.80, -119.26, 000.00)
	global_travel_paths[1]["finish_ang"] = vector:new(00005.50, -060.50, 000.00)
	global_travel_paths[1]["fly_length"] = 20
	
	global_travel_paths[2] = {}
	global_travel_paths[2]["start_pos"]  = vector:new(-1017.80, 01326.00, 614.00)
	global_travel_paths[2]["finish_pos"] = vector:new(-0711.90, 00948.70, 604.00)
	global_travel_paths[2]["cam_angles"] = vector:new(00001.00, -0051.00, 000.00)
	global_travel_paths[2]["fly_length"] = 14

	global_travel_paths[3] = {}
	global_travel_paths[3]["start_pos"]  = vector:new(-100.90, 517.70, 0755.00)
	global_travel_paths[3]["finish_pos"] = vector:new(0761.80, 146.00, 1278.20)
	global_travel_paths[3]["cam_angles"] = vector:new(0029.00, 156.70, 0000.00)
	global_travel_paths[3]["fly_length"] = 22

	global_travel_paths[4] = {}
	global_travel_paths[4]["start_pos"]  = vector:new(160.80, 3604.70, 0908.20)
	global_travel_paths[4]["finish_pos"] = vector:new(163.00, 3643.80, 1293.40)
	global_travel_paths[4]["cam_angles"] = vector:new(004.20, -103.20, 0000.00)
	global_travel_paths[4]["fly_length"] = 14


	---------------    MAP SHOWTIME : firts ever multiplayer i played was cod4's mp     ---------------
	elseif map == "mp_shipment_ns" then
	global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos" ] = vector:new(503.80, 0696.50, 200.00)
	global_travel_paths[1]["finish_pos"] = vector:new(399.80, -276.60, 189.20)
	global_travel_paths[1]["cam_angles"] = vector:new(000.60, -096.00, 000.00)
	global_travel_paths[1]["fly_length"] = 12
	
	global_travel_paths[2] = {}
	global_travel_paths[2]["start_pos" ] = vector:new(-0434.00, 0417.00, 417.00)
	global_travel_paths[2]["finish_pos"] = vector:new(-1202.40, 1002.00, 737.20)
	global_travel_paths[2]["cam_angles"] = vector:new(00018.00, -037.00, 000.00)
	global_travel_paths[2]["fly_length"] = 12
	
	global_travel_paths[3] = {}
	global_travel_paths[3]["start_pos" ] = vector:new(066.20, -082.00, 326.40)
	global_travel_paths[3]["start_ang" ] = vector:new(-13.00, 0151.30, 000.00)
	global_travel_paths[3]["finish_pos"] = vector:new(020.00, 0015.70, 359.50)
	global_travel_paths[3]["finish_ang"] = vector:new(-02.30, -161.70, 000.00)
	global_travel_paths[3]["fly_length"] = 8
	
	global_travel_paths[4] = {}
	global_travel_paths[4]["start_pos" ] = vector:new(-000.80, 0149.00, 1124.00)
	global_travel_paths[4]["finish_pos"] = vector:new(-000.80, 0149.00, 4200.00)
	global_travel_paths[4]["cam_angles"] = vector:new(0084.00, -090.00, 0000.00)
	global_travel_paths[4]["fly_length"] = 20

	---------------        MAP FOG : I love horror movies. this is my kinda map!        ---------------
	elseif map == "mp_swamp" then 	
	global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos"]  = vector:new(-736.80, 1637.20, 103.80)
	global_travel_paths[1]["finish_pos"] = vector:new(-398.20, 2065.80, 248.30)
	global_travel_paths[1]["cam_angles"] = vector:new(0014.80, -128.30, 000.00)
	global_travel_paths[1]["fly_length"] = 8

	global_travel_paths[2] = {}
	global_travel_paths[2]["start_pos"]  = vector:new(616.00, -1632.30, -24.50)
	global_travel_paths[2]["finish_pos"] = vector:new(789.20, -1577.60, -17.70)
	global_travel_paths[2]["cam_angles"] = vector:new(-02.10, 00017.50, 000.00)
	global_travel_paths[2]["fly_length"] = 8
	
	global_travel_paths[3] = {}
	global_travel_paths[3]["start_pos"]  = vector:new(-300.30, 1924.20, 77.00)
	global_travel_paths[3]["finish_pos"] = vector:new(-163.30, 1952.00, 70.30)
	global_travel_paths[3]["cam_angles"] = vector:new(0006.00, 0062.00, 00.00)
	global_travel_paths[3]["fly_length"] = 8
	
	global_travel_paths[4] = {}
	global_travel_paths[4]["start_pos"]  = vector:new(625.50, 476.30, 145.10)
	global_travel_paths[4]["finish_pos"] = vector:new(885.30, 398.80, 154.40)
	global_travel_paths[4]["cam_angles"] = vector:new(002.00, 163.40, 000.00)
	global_travel_paths[4]["fly_length"] = 8
	
    else
      print("[ WARNING ] no travel script for map " .. map .. " found. skipping Cinematic Travel plugin load")
    end
end

---------------                        MAIN INITIALIZE                       ---------------

level:onnotify("connected", player_connected)

global_travel_paths = {}          -- create the matrix
setup_travel_paths(game:getdvar("mapname"))

game:setdvar("sv_cheats",1) -- its required for setting cg_draw2d

---------------   [DEVELOPER TOOL]THIS PART IS FOR RECORDING FLIGHT PATHZ    ---------------
--[[function append_log(data)
   local f = io.open(("travel_%s.log"):format(game:getdvar("mapname")), "a");
    f:write(data);
    f:flush();
    f:close();
end

local lastCenter = nil;

local onPlayerSay = function (player, msg)
    msg = string.lower(msg);

    if msg == "!start" then
	    lastCenter = player.origin;
        append_log("	global_travel_paths[i][\"start_pos\"] = vector:new(" .. player.origin.x .. ", " .. player.origin.y .. ", " .. player.origin.z .. ")\n	global_travel_paths[i][\"start_ang\"] = vector:new(" .. player:getangles().x .. ", " .. player:getangles().y .. ", " .. player:getangles().z .. ")\n")
        player:iclientprintlnbold("start_pos saved -> " .. player.origin.x .. "," .. player.origin.y .. "," .. player.origin.z .. " (" .. player:getangles().x .. ", " .. player:getangles().y .. ", " .. player:getangles().z .. ")" );
    elseif msg == "!end" then
        append_log("	global_travel_paths[i][\"finish_pos\"] = vector:new(" .. player.origin.x .. ", " .. player.origin.y .. ", " .. player.origin.z .. ")\n	global_travel_paths[i][\"finish_ang\"] = vector:new(" .. player:getangles().x .. ", " .. player:getangles().y .. ", " .. player:getangles().z .. ")\n")
        player:iclientprintlnbold("finish_pos saved -> " .. player.origin.x .. "," .. player.origin.y .. "," .. player.origin.z .. " (" .. player:getangles().x .. ", " .. player:getangles().y .. ", " .. player:getangles().z .. ")" );
	end
end


local onPlayerConnected = function (player)

    local saylistener = player:onnotify("say", function(msg) onPlayerSay(player, msg) end);
    player:onnotifyonce("disconnect", function () saylistener:clear(); end)
end	

level:onnotify("connected", onPlayerConnected);
--]]
---------------                        EXTRA UTILITIES                       ---------------

function tablelength(T) -- https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end