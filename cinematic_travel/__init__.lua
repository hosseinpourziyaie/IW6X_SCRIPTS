--[[*********************************************************************************************************
                                          IW6X SERVER SCRIPTS                                         *****
*********************************************************************************************************
**
** - TITLE   : CINEMATIC FLIGHT TRAVEL [REVISION 2]
** - DESC    : practical tool to catch cinematic auto-piloted footage from videogame
** - AUTHOR  : Hosseinpourziyaie - Thanks to DoktorSAS, GEEKiDoS, quaK for LUA sample refrence
** - TIME    : INITIAL REVISION on 5 January 2021  | LATEST REVISION on 10 September 2020
** - HOW?    : Spawn camera; then link player view to that; then fly it in pathez already defined
**
**
** [NOTE] As of this version Bezier Flight not available. Its just simple Linear fly
**         Its possible tho to have camera rotate with start_ang, finish_ang parameters 
** 
** [NOTE] travel pathz for mp_conflict, mp_shipment_ns, mp_swamp, mp_ca_rumble, mp_dig,
**                                       mp_dart and mp_favela_iw6 were recorded by Hosseinpourziyaie
** 
** [WARNING] You are not Allowed using this script in commercial purposes without Author's permission 
** 
** [Copyright © Hosseinpourziyaie 2020] <hosseinpourziyaie@gmail.com>
** 
*******************************************************************************************************--]]

--------------------------------------------------------------------------------------------
---------------           CORE TRAVEL WITH LOCKED ON CAMERA LOGIC            ---------------
--------------------------------------------------------------------------------------------
function player_angles_lock_to_camera(target, source)
	--target:setplayerangles(source.angles) -- wow!
	--target.angles = source.angles
	target:setplayerangles(source.angles) -- back in iw6x-v1.1.0 was setangles
end

function camera_movement(camera, s_origin, f_origin, s_angles, f_angles, length)	
	camera.origin = s_origin
	camera.angles = s_angles
		
	if s_origin ~= f_origin then -- fixed position
	    camera:moveto( f_origin, length )
	end
	
	if s_angles ~= f_angles then -- fixed angles
        camera:rotateto( f_angles, length, 0, 0 )
    end	
end

function travel_start(player)
	if tablelength(global_travel_paths) == 0 then return end -- wait what?
	
	local camera = game:spawn("script_model", player.origin)
	camera:setmodel("tag_origin")
	--camera:enablelinkto()  -- seems quite un-necessary :|
	
	local AnglesLockInterval = game:oninterval(function() player_angles_lock_to_camera(player, camera) end, 20)

	--player:linkto(camera)  -- I dont remember but I think linktodelta worked-out way smoother?
	player:playerlinktodelta(camera, "tag_origin")
	player:freezecontrols( true )

	local total_length = 0;
	for _, data in ipairs(global_travel_paths) do	
	  if data.start_ang and data.finish_ang then     -- rotated linear flight
	    local setup_moveto = game:ontimeout(function() camera_movement(camera, data.start_pos, data.finish_pos, data.start_ang, data.finish_ang, data.fly_length) end, total_length * 1000)
      elseif data.start_pos and data.finish_pos then -- fixed linear flight
	    local setup_moveto = game:ontimeout(function() camera_movement(camera, data.start_pos, data.finish_pos, data.cam_angles, data.cam_angles, data.fly_length) end, total_length * 1000)
	  else                                           -- fixed scene camera view
	    local setup_moveto = game:ontimeout(function() camera_movement(camera, data.cam_fixpos, data.cam_fixpos, data.cam_angles, data.cam_angles, data.fly_length) end, total_length * 1000)
	  end
  	  
	  total_length = total_length + data.fly_length
	end

	local travel_dispose = game:ontimeout(function () player:unlink(); camera:delete(); AnglesLockInterval:clear(); travel_dispose(player); end, total_length * 1000);
end

flying_corpses_array = {} -- might be shitty work-around but it does the job i guess
for i = 0, 18, 1 do
    flying_corpses_array[i] = 0
end

function travel_dispose(player)
	--player:setclientdvar("cg_draw2d",1) -- cut out in newer iw6x versions
	
	flying_corpses_array[player:getentitynumber()] = 0 -- reset player state to not flying
	player:suicide() -- maybe I should have figured out better way of landing!
	
	--player:setclientdvar("ui_hud_hardcore",0)
	--player:visionsetnaked( game:getdvar("mapname"), 3.0 );
	
	--player:giveweapon("iw6_knifeonly_mp")
	--game:ontimeout(function () player:switchtoweapon("iw6_knifeonly_mp") end, 10);
	
	--travel_start(player) -- repeat same routes forever :)
end

function travel_initialize(player) 
	if flying_corpses_array[player:getentitynumber()] == 1 then
		player:iprintlnbold("^1You are Already Flying with another plane^7!")
	elseif tablelength(global_travel_paths) == 0 then	
		player:iprintlnbold("^1There is no Airline to fly with in this map^7!")
	else
		player:takeallweapons()
		--player:setclientdvar("cg_draw2d",0) -- cut out in newer iw6x versions
	
		--player:setclientdvar("ui_hud_hardcore",1)
		--player:visionsetnaked( "mpOutro", 2.0 );
	
		travel_start(player)
		flying_corpses_array[player:getentitynumber()] = 1		
	end
end

--------------------------------------------------------------------------------------------
---------------                USER-HANDLED START BUTTON LOGIC               ---------------
--------------------------------------------------------------------------------------------
function resetHoldProgress(keydown_ms, progressbar_bg, progressbar_sl)
	progressbar_bg.alpha = 0.0
	progressbar_sl.alpha = 0.0
	keydown_ms = 0
	progressbar_sl:scaleovertime(0.01, 0, 8)
end
function checkuseButtonHoldDownState(player, keydown_ms, progressbar_bg, progressbar_sl)
	if player:usebuttonpressed() == 1 then
		if keydown_ms > 130 then
			resetHoldProgress(keydown_ms, progressbar_bg, progressbar_sl)
			travel_initialize(player)
		else
			keydown_ms = keydown_ms + 10			
			progressbar_sl:scaleovertime(0.1, keydown_ms, 8);
			
			game:ontimeout(function() checkuseButtonHoldDownState(player, keydown_ms, progressbar_bg, progressbar_sl) end, 100)
			
			--game:iprintlnbold(keydown_ms) -- this looked cool through debugging stages :D
		end
	else 
		resetHoldProgress(keydown_ms, progressbar_bg, progressbar_sl)
    end
end
--------------------------------------------------------------------------------------------
---------------                HINT MESSAGE SMOOTH SHIFT LOGIC               ---------------
--------------------------------------------------------------------------------------------
function player_shift_hint_msg(hud_hint_msg)
    hud_hint_msg:fadeovertime( 2 ) hud_hint_msg.alpha = 1.0
	
	game:ontimeout(function () hud_hint_msg:fadeovertime( 2 ) hud_hint_msg.alpha = 0.0 end, 6000)
	game:ontimeout(function () hud_hint_msg:settext(global_hint_message) end, 8000)
end

function starting_sequence_initialize(player)
	local progressbar_sl = game:newclienthudelem(player)
    progressbar_sl.alpha = 0.0
    progressbar_sl.x = 1 - ( 140 / 2 ) 
    progressbar_sl.y = -40 - 1
	progressbar_sl.alignx = "left";
    progressbar_sl.aligny = "bottom";
    progressbar_sl.horzalign = "center";
    progressbar_sl.vertalign = "bottom";	
    progressbar_sl.hidewheninmenu = true
    progressbar_sl:setshader("white", 0, 8);
	progressbar_sl.sort = 3	
	
	local progressbar_bg = game:newclienthudelem(player)
    progressbar_bg.alpha = 0.0
    progressbar_bg.x = 0
    progressbar_bg.y = -40
	progressbar_bg.alignx = "center";
    progressbar_bg.aligny = "bottom";
    progressbar_bg.horzalign = "center";
    progressbar_bg.vertalign = "bottom";
    progressbar_bg.hidewheninmenu = true
    progressbar_bg:setshader("black", 140, 10);
	progressbar_bg.sort = 2
	
	local use_keydown_ms = 0 -- couldnt pass type through iterator --> *** Script execution error *** *** attempt to compare number with sol.scripting::entity ***
	
	player:notifyonplayercommand("activate_holddown", "+activate")
	player:onnotify("activate_holddown", function() progressbar_bg.alpha = 0.8 progressbar_sl.alpha = 0.8 game:ontimeout(function() checkuseButtonHoldDownState(player, use_keydown_ms, progressbar_bg, progressbar_sl) end, 100) end)
	
	--if tablelength(global_hint_messages) == 0 then return end -- no hint messages to show
	
	local hud_hint_msg = game:newclienthudelem(player)
    hud_hint_msg.alpha = 0.0
    hud_hint_msg.font = "default"
    hud_hint_msg.fontscale = 1.0
    hud_hint_msg.alignx = "center"
    hud_hint_msg.aligny = "bottom"
    hud_hint_msg.horzalign = "center"
    hud_hint_msg.vertalign = "bottom"
    hud_hint_msg.x = 0
    hud_hint_msg.y = -20
    hud_hint_msg.hidewheninmenu = true
    hud_hint_msg:settext(global_hint_message)

	--local hint_msg_index = 0 -- minus 1 of first index because we have increment before first hint set
	
	local hint_shift_interval = game:oninterval(function() player_shift_hint_msg(hud_hint_msg) end, 8000)
	
	player:notifyonplayercommand("ignore_hint", "+melee_zoom")
	player:onnotifyonce("ignore_hint", function() hud_hint_msg:destroy() hint_shift_interval:clear() end)
	
	--player:onnotifyonce("disconnect", function() hint_msg:delete() hint_shift_interval:clear() end) -- should add checks later
end

--------------------------------------------------------------------------------------------
---------------          INVIDUAL PLAYER SYSTEM INITIALIZATION LOGIC         ---------------
--------------------------------------------------------------------------------------------
function player_spawned(player)
	--player:freezecontrols(false) -- feeling in a hurry? activate this lol!
	
	--player:giveweapon("iw6_knifeonly_mp") -- testing out our new weapon i guess!?
	--game:ontimeout(function () player:switchtoweapon("iw6_knifeonly_mp") end, 10); -- testing out our new weapon i guess!?
	
	--travel_initialize(player) -- from now on we just let players themselves start flight when they ready

	--flying_corpses_array[player:getentitynumber()] = 0 -- this should have triggered with player_disconnected for possible in-flight back-out 
	starting_sequence_initialize(player)               -- initialize user-handled flight take-off system!
end

function player_connected(player)
    player:onnotifyonce("spawned_player", function() player_spawned(player) end)
end

--------------------------------------------------------------------------------------------
---------------           TRAVEL PATHZ INITIALIZATION FUNCTION               ---------------
--------------------------------------------------------------------------------------------
function setup_travel_paths(map)
    ---------------     MAP DYNASTY : boiii I love these chineese villages Architecture!     --------------- 
    if map == "mp_conflict" then
	--[[global_travel_paths[1] = {} -- not bad but we got better scenes already!
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

	---------------     MAP SHOWTIME : firt ever multiplayer game I played was cod4's mp     ---------------
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

	---------------           MAP FOG : I love horror movies. this is my kinda map!          ---------------
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

	---------------  MAP FAVELA : very nice remake. hope I could get one of those gunships!  ---------------	
	elseif map == "mp_favela_iw6" then 	
	
	global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos"] = vector:new(-468.70, 152.20, 53.50)
	global_travel_paths[1]["start_ang"] = vector:new(-0.20, -30.00, 0.0)
	global_travel_paths[1]["finish_pos"] = vector:new(614.40, 151.30, 186.70)
	global_travel_paths[1]["finish_ang"] = vector:new(3.40, -142.90, 0.00)
	global_travel_paths[1]["fly_length"] = 18
	
	global_travel_paths[2] = {}
	global_travel_paths[2]["start_pos"] = vector:new(79.10, -410.00, 74.50)
	global_travel_paths[2]["start_ang"] = vector:new(5.00, -131.90, 0.0)
	global_travel_paths[2]["finish_pos"] = vector:new(-300.70, -456.00, 55.10)
	global_travel_paths[2]["finish_ang"] = vector:new(3.60, -171.00, 0.00)
	global_travel_paths[2]["fly_length"] = 14

	global_travel_paths[3] = {}
	global_travel_paths[3]["start_pos"] = vector:new(427.20, -150.60, 222.70)
	global_travel_paths[3]["start_ang"] = vector:new(10.80, 176.70, 0.0)
	global_travel_paths[3]["finish_pos"] = vector:new(1060.60, 757.50, 442.40)
	global_travel_paths[3]["finish_ang"] = vector:new(9.20, -133.30, 0.00)
	global_travel_paths[3]["fly_length"] = 18

	global_travel_paths[4] = {}
	global_travel_paths[4]["finish_pos"] = vector:new(-675.20, -500.80, 195.00)
	global_travel_paths[4]["finish_ang"] = vector:new(8.00, 123.20, 0.0)
	global_travel_paths[4]["start_pos"] = vector:new(-934.30, -148.00, 162.80)
	global_travel_paths[4]["start_ang"] = vector:new(2.40, 108.90, 0.0)
	global_travel_paths[4]["fly_length"] = 12
	
	global_travel_paths[5] = {}
	global_travel_paths[5]["start_pos"] = vector:new(-553.20, -514.00, 183.80)
	global_travel_paths[5]["start_ang"] = vector:new(1.10, -121.20, 0.00)
	global_travel_paths[5]["finish_pos"] = vector:new(-561.00, -528.00, 0.00)
	global_travel_paths[5]["finish_ang"] = vector:new(-7.00, -122.30, 0.00)
	global_travel_paths[5]["fly_length"] = 8
	
	global_travel_paths[6] = {} -- these 2 are bonus scense :D
	global_travel_paths[6]["start_pos"] = vector:new(537.50, 2547.10, 320.20)
	global_travel_paths[6]["start_ang"] = vector:new(1.70, -39.50, 0.00)
	global_travel_paths[6]["finish_pos"] = vector:new(1053.40, 2325.80, 313.70)
	global_travel_paths[6]["finish_ang"] = vector:new(1.00, -26.50, 0.00)
	global_travel_paths[6]["fly_length"] = 10
	
	global_travel_paths[7] = {} -- these 2 are bonus scense :D
	global_travel_paths[7]["start_pos"] = vector:new(-1139.00, 3475.30, 463.60)
	global_travel_paths[7]["start_ang"] = vector:new(9.40, -70.50, 0.0)
	global_travel_paths[7]["finish_pos"] = vector:new(-991.80, 2640.10, 339.50)
	global_travel_paths[7]["finish_ang"] = vector:new(-0.90, -48.00, 0.00)
	global_travel_paths[7]["fly_length"] = 12
	
	---------------     MAP PHARAOH : reminds me of zombie map IX in bo4. wow memories!      ---------------
	elseif map == "mp_dig" then 	
	
	global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos"] = vector:new(630.60, -1797.30, 811.70)
	global_travel_paths[1]["start_ang"] = vector:new(-1.00, 128.00, 0.00)
	global_travel_paths[1]["finish_pos"] = vector:new(-529.50, -2404.50, 961.20)
	global_travel_paths[1]["finish_ang"] = vector:new(7.30, 53.00, 0.00)
	global_travel_paths[1]["fly_length"] = 12

	global_travel_paths[2] = {} -- time freeze for landscape of previous scene's end; maybe we should add feature of scene freeze in code later
	global_travel_paths[2]["start_pos"] = vector:new(-529.50, -2404.50, 961.20)
	global_travel_paths[2]["cam_fixpos"] = vector:new(-529.50, -2404.50, 961.20)
	global_travel_paths[2]["cam_angles"] = vector:new(7.30, 53.00, 0.00)
	global_travel_paths[2]["fly_length"] = 4

	global_travel_paths[3] = {}
	global_travel_paths[3]["start_pos"] = vector:new(265.50, 23.40, 785.70)
	global_travel_paths[3]["start_ang"] = vector:new(-13.50, 134.00, 0.00)
	global_travel_paths[3]["finish_pos"] = vector:new(-705.30, 621.70, 1284.00)
	global_travel_paths[3]["finish_ang"] = vector:new(14.60, -119.40, 0.00)
	global_travel_paths[3]["fly_length"] = 12

	global_travel_paths[4] = {}
	global_travel_paths[4]["start_pos"] = vector:new(-2037.70, 1358.80, 801.80)
	global_travel_paths[4]["start_ang"] = vector:new(13.70, 39.90, 0.00)
	global_travel_paths[4]["finish_pos"] = vector:new(-1423.40, 1912.30, 720.70)
	global_travel_paths[4]["finish_ang"] = vector:new(5.30, -53.00, 0.00)
	global_travel_paths[4]["fly_length"] = 12
	
	global_travel_paths[5] = {} -- not good enough; should be re-directed
	global_travel_paths[5]["start_pos"] = vector:new(-120.90, 1901.20, 700.90)
	global_travel_paths[5]["start_ang"] = vector:new(16.60, -116.70, 0.0)
	global_travel_paths[5]["finish_pos"] = vector:new(-245.00, 1641.70, 645.70)
	global_travel_paths[5]["finish_ang"] = vector:new(19.80, 159.10, 0.0)
	global_travel_paths[5]["fly_length"] = 12
	
	global_travel_paths[6] = {} -- not the best of scense but director wanted to show you gramophone of investors edition :D
	global_travel_paths[6]["start_pos"] = vector:new(-2507.20, -804.70, 797.70)
	global_travel_paths[6]["start_ang"] = vector:new(-1.40, -114.00, 0.00)
	global_travel_paths[6]["finish_pos"] = vector:new(-2472.90, -1125.00, 816.70)
	global_travel_paths[6]["finish_ang"] = vector:new(-4.80, -24.60, 0.00)
	global_travel_paths[6]["fly_length"] = 12

	---------------        MAP BAYVIEW : this map had best views amongst them all            ---------------
	elseif map == "mp_ca_rumble" then 	
		
	global_travel_paths[1] = {}
	global_travel_paths[1]["start_pos"] = vector:new(-1026.80, -931.70, -15.00)
	global_travel_paths[1]["start_ang"] = vector:new(-19.30, -64.90, 0.00)
	global_travel_paths[1]["finish_pos"] = vector:new(-1631.20, -1161.30, 17.80)
	global_travel_paths[1]["finish_ang"] = vector:new(-8.90, -19.30, 0.00)
	global_travel_paths[1]["fly_length"] = 12

	global_travel_paths[2] = {}
	global_travel_paths[2]["start_pos"] = vector:new(1635.40, 491.20, 167.90)
	global_travel_paths[2]["start_ang"] = vector:new(1.20, 134.60, 0.0)
	global_travel_paths[2]["finish_pos"] = vector:new(1472.40, 976.90, 229.30)
	global_travel_paths[2]["finish_ang"] = vector:new(1.90, 154.30, 0.0)
	global_travel_paths[2]["fly_length"] = 12
	
	global_travel_paths[3] = {}
	global_travel_paths[3]["start_pos"] = vector:new(945.20, -346.10, 131.30)
	global_travel_paths[3]["start_ang"] = vector:new(25.10, -134.40, 0.00)
	global_travel_paths[3]["finish_pos"] = vector:new(704.40, -570.70, 41.10)
	global_travel_paths[3]["finish_ang"] = vector:new(4.00, 118.80, 0.00)
	global_travel_paths[3]["fly_length"] = 12
	
	global_travel_paths[4] = {} -- these tho are couple of aquarium; spins shitty must be re-captured
	global_travel_paths[4]["start_pos"] = vector:new(-590.43267822266, 1167.9584960938, 63.349742889404)
	global_travel_paths[4]["start_ang"] = vector:new(-15.079956054688, 105.57153320312, 0.0)
	global_travel_paths[4]["finish_pos"] = vector:new(-572.3857421875, 1590.3616943359, 99.152168273926)
	global_travel_paths[4]["finish_ang"] = vector:new(-5.37353515625, 30.935914993286, 0.0)
	global_travel_paths[4]["fly_length"] = 12
	
	global_travel_paths[5] = {} -- these tho are couple of aquarium; spins shitty must be re-captured
	global_travel_paths[5]["start_pos"] = vector:new(-572.3857421875, 1590.3616943359, 99.152168273926)
	global_travel_paths[5]["start_ang"] = vector:new(-5.37353515625, 30.935914993286, 0.0)
	global_travel_paths[5]["finish_pos"] = vector:new(-382.60256958008, 1653.7755126953, 107.98793029785)
	global_travel_paths[5]["finish_ang"] = vector:new(-3.6322021484375, -41.343139648438, 0.0)
	global_travel_paths[5]["fly_length"] = 8
	
	global_travel_paths[6] = {}
	global_travel_paths[6]["start_pos"] = vector:new(1554.00, 188.80, 193.00)
	global_travel_paths[6]["start_ang"] = vector:new(5.50, 144.80, 0.00)
	global_travel_paths[6]["finish_pos"] = vector:new(1215.20, 462.20, 152.00)
	global_travel_paths[6]["finish_ang"] = vector:new(-7.40, -146.80, 0.00)
	global_travel_paths[6]["fly_length"] = 12
	
	global_travel_paths[7] = {}
	global_travel_paths[7]["start_pos"] = vector:new(-1276.90, 130.30, 178.20)
	global_travel_paths[7]["start_ang"] = vector:new(1.40, -44.60, 0.00)
	global_travel_paths[7]["finish_pos"] = vector:new(-1242.10, -633.40, 177.40)
	global_travel_paths[7]["finish_ang"] = vector:new(2.60, 45.50, 0.00)
	global_travel_paths[7]["fly_length"] = 12
	
	global_travel_paths[8] = {}
	global_travel_paths[8]["start_pos"] = vector:new(-1236.60, -542.10, 26.00)
	global_travel_paths[8]["start_ang"] = vector:new(-0.70, 38.20, 0.00)
	global_travel_paths[8]["finish_pos"] = vector:new(-626.30, -402.90, 25.10)
	global_travel_paths[8]["finish_ang"] = vector:new(2.30, -29.20, 0.00)
	global_travel_paths[8]["fly_length"] = 12
	
	global_travel_paths[9] = {}
	global_travel_paths[9]["start_pos"] = vector:new(-7.90, -2364.80, 117.60)
	global_travel_paths[9]["start_ang"] = vector:new(2.80, 109.30, 0.00)
	global_travel_paths[9]["finish_pos"] = vector:new(-1093.00, -2125.70, 963.10)
	global_travel_paths[9]["finish_ang"] = vector:new(2.00, 48.60, 0.00)
	global_travel_paths[9]["fly_length"] = 12
	
	global_travel_paths[10] = {} -- time freeze for landscape of final scene's end
	global_travel_paths[10]["cam_fixpos"] = vector:new(-1093.00, -2125.70, 963.10)
	global_travel_paths[10]["cam_angles"] = vector:new(2.00, 48.60, 0.00)
	global_travel_paths[10]["fly_length"] = 4
	
	---------------    MAP OCTANE : nothing much but we can get better view of gas station   ---------------
	elseif map == "mp_dart" then 	
	
	global_travel_paths[1] = {}
	global_travel_paths[1]["cam_fixpos"] = vector:new(238.90, 337.60, 34.50)
	global_travel_paths[1]["cam_angles"] = vector:new(-1.80, 153.30, 0.00)
	global_travel_paths[1]["fly_length"] = 2
	
	global_travel_paths[2] = {}
	global_travel_paths[2]["start_pos"] = vector:new(238.90, 337.60, 34.50)
	global_travel_paths[2]["start_ang"] = vector:new(-1.80, 153.30, 0.00)
	global_travel_paths[2]["finish_pos"] = vector:new(-197.80, 252.70, 48.10)
	global_travel_paths[2]["finish_ang"] = vector:new(-3.50, 94.40, 0.00)
	global_travel_paths[2]["fly_length"] = 12

	global_travel_paths[3] = {} -- enough stop to spot the levolution wow!
	global_travel_paths[3]["cam_fixpos"] = vector:new(-197.80, 252.70, 48.10)
	global_travel_paths[3]["cam_angles"] = vector:new(-3.50, 94.40, 0.00)
	global_travel_paths[3]["fly_length"] = 6

	global_travel_paths[4] = {}
	global_travel_paths[4]["start_pos"] = vector:new(-506.60, -1232.00, 166.70)
	global_travel_paths[4]["start_ang"] = vector:new(4.10, 139.80, 0.00)
	global_travel_paths[4]["finish_pos"] = vector:new(-1307.40, -1103.80, 181.90)
	global_travel_paths[4]["finish_ang"] = vector:new(7.40, 34.60, 0.00)	
	global_travel_paths[4]["fly_length"] = 14
	
	global_travel_paths[5] = {}
	global_travel_paths[5]["start_pos"]  = vector:new(-1340.00, 82.40, 024.80)
	global_travel_paths[5]["finish_pos"] = vector:new(-1340.00, 82.40, 375.30)
	global_travel_paths[5]["cam_angles"] = vector:new(0002.00, 019.50, 000.00)
	global_travel_paths[5]["fly_length"] = 8
	
	global_travel_paths[6] = {}
	global_travel_paths[6]["cam_fixpos"] = vector:new(-1340.00, 82.40, 375.30)
	global_travel_paths[6]["cam_angles"] = vector:new(0002.00, 019.50, 000.00)
	global_travel_paths[6]["fly_length"] = 4
	
    else
      print("[ WARNING ] no travel script for map " .. map .. " found. skipping Cinematic Travel plugin load")
    end
end

function setup_hint_messages()
    array_hint_messages = {}
    array_hint_messages[1] = "Welcome to ^4Hosseinpourziyaie^7's ^4Cinematic Travel Mod"
    array_hint_messages[2] = "Hold [^3[{+activate}]^7] To Start Cinematic Travel"
    array_hint_messages[3] = "You can ^1Dispose^7 Hint messages anytime with [^3[{+melee_zoom}]^7]"
    array_hint_messages[4] = "set your ^2cg_fov ^7to ^270 for ^5best ^7view footage ^7using console"
    array_hint_messages[5] = "Consider rating and giving SUB on project's github page"
    array_hint_messages[6] = "For ^5best ^7raw footage ^1disable ^2cg_draw2d ^7using console"
    array_hint_messages[7] = "You can use ^3Developer Tool ^7in code to record your own pathz"
    array_hint_messages[8] = "This Script Developed with Heart by ^3Hosseinpourziyaie"
	
    global_hint_message = "Loaded script 'iw6x/scripts/cinematic_travel' successfully!"
	
    function shift_hint_message()
        global_hint_message = array_hint_messages[hint_msg_current_index]
		
        if hint_msg_current_index < tablelength(array_hint_messages) then  
            hint_msg_current_index = hint_msg_current_index + 1
	else
	    hint_msg_current_index = 1
	end	
    end
	
    local hint_shift_interval = game:oninterval(shift_hint_message, 8000)
end
--------------------------------------------------------------------------------------------
---------------                        MAIN INITIALIZE                       ---------------
--------------------------------------------------------------------------------------------
level:onnotify("connected", player_connected) -- main trigger of initiating tool for the player

global_travel_paths = {}                    -- create the matrix
setup_travel_paths(game:getdvar("mapname")) -- initiate flight pathz

game:setdvar("sv_cheats",1) -- its required for setting cg_draw2d

global_hint_message = "LOCALIZATION_HINT_MESSAGE_0" -- wow
hint_msg_current_index = 1 -- wow
setup_hint_messages() -- wow

--------------------------------------------------------------------------------------------
---------------   [DEVELOPER TOOL]THIS PART IS FOR RECORDING FLIGHT PATHZ    ---------------
--------------------------------------------------------------------------------------------
-- [ NOTE ] getAngles[33583] were in iw6x-v1.1.0 been changed to getplayerangles[0x832F] in function_tables over the time
-- [ NOTE ] iclientprintlnbold[33380] were in iw6x-v1.1.0 been changed to iprintlnbold[0x8264] in function_tables over the time
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
        append_log("	global_travel_paths[i][\"start_pos\"] = vector:new(" .. player.origin.x .. ", " .. player.origin.y .. ", " .. player.origin.z .. ")\n	global_travel_paths[i][\"start_ang\"] = vector:new(" .. player:getplayerangles().x .. ", " .. player:getplayerangles().y .. ", " .. player:getplayerangles().z .. ")\n")
        player:iprintlnbold("start_pos saved -> " .. player.origin.x .. "," .. player.origin.y .. "," .. player.origin.z .. " (" .. player:getplayerangles().x .. ", " .. player:getplayerangles().y .. ", " .. player:getplayerangles().z .. ")" );
    elseif msg == "!end" then
        append_log("	global_travel_paths[i][\"finish_pos\"] = vector:new(" .. player.origin.x .. ", " .. player.origin.y .. ", " .. player.origin.z .. ")\n	global_travel_paths[i][\"finish_ang\"] = vector:new(" .. player:getplayerangles().x .. ", " .. player:getplayerangles().y .. ", " .. player:getplayerangles().z .. ")\n")
        player:iprintlnbold("finish_pos saved -> " .. player.origin.x .. "," .. player.origin.y .. "," .. player.origin.z .. " (" .. player:getplayerangles().x .. ", " .. player:getplayerangles().y .. ", " .. player:getplayerangles().z .. ")" );
	end
end

local onPlayerConnected = function (player)

    local saylistener = player:onnotify("say", function(msg) onPlayerSay(player, msg) end);
    player:onnotifyonce("disconnect", function () saylistener:clear(); end)
end	

level:onnotify("connected", onPlayerConnected);--]]

--------------------------------------------------------------------------------------------
---------------                        EXTRA UTILITIES                       ---------------
--------------------------------------------------------------------------------------------
function tablelength(T) -- https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
