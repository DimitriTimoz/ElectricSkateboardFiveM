local RCCar = {}
local player = GetPlayerPed(-1)

Attached = false

RegisterCommand("longboard", function()
	RCCar.Start()
end)


AddEventHandler('longboard:clear', function()
	DeleteEntity(RCCar.Skate)
	DeleteVehicle(RCCar.Entity)
	DeleteEntity(RCCar.Driver)
    RCCar.UnloadModels()
    Attached = false
end)

AddEventHandler('longboard:spawn', function()
    RCCar.Start()
end)

RCCar.Start = function()
	player = GetPlayerPed(-1)
	if DoesEntityExist(RCCar.Entity) then return end

	RCCar.Spawn()

	while DoesEntityExist(RCCar.Entity) and DoesEntityExist(RCCar.Driver) do
		Citizen.Wait(5)

		local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(RCCar.Entity), true)

		RCCar.DrawInstructions(distanceCheck)
		RCCar.HandleKeys(distanceCheck)

		if distanceCheck <= Config.LoseConnectionDistance then
			if not NetworkHasControlOfEntity(RCCar.Driver) then
				NetworkRequestControlOfEntity(RCCar.Driver)
			elseif not NetworkHasControlOfEntity(RCCar.Entity) then
				NetworkRequestControlOfEntity(RCCar.Entity)
			end
		else
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 6, 2500)
		end
	end
end

RCCar.HandleKeys = function(distanceCheck)
	if distanceCheck <= 1.5 then
		if IsControlJustPressed(0, 38) then
			RCCar.Attach("pick")
		end

		if IsControlJustReleased(0, 47) then
			if Attached then
				RCCar.AttachPlayer(false)
			else
				RCCar.AttachPlayer(true)
			end
		end
	end
	
	if distanceCheck < Config.LoseConnectionDistance then
		if IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 9, 1)
		end

		if IsControlPressed(0, 22) and Attached then
			local vel = GetEntityVelocity(RCCar.Entity)
			if not IsEntityInAir(RCCar.Entity) then
				SetEntityVelocity(RCCar.Entity, vel.x, vel.y, vel.z + 5.0)
				Citizen.Wait(20)
			end
			
		end
		
		if IsControlJustReleased(0, 172) or IsControlJustReleased(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 6, 2500)
		end

		if IsControlPressed(0, 173) and not IsControlPressed(0, 172) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 22, 1)
		end

		if IsControlPressed(0, 174) and IsControlPressed(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 13, 1)
		end

		if IsControlPressed(0, 175) and IsControlPressed(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 14, 1)
		end

		if IsControlPressed(0, 172) and IsControlPressed(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 30, 100)
		end

		if IsControlPressed(0, 174) and IsControlPressed(0, 172) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 7, 1)
		end

		if IsControlPressed(0, 175) and IsControlPressed(0, 172) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 8, 1)
		end

		if IsControlPressed(0, 174) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 4, 1)
		end

		if IsControlPressed(0, 175) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
			TaskVehicleTempAction(RCCar.Driver, RCCar.Entity, 5, 1)
		end

		
	end
end


RCCar.DrawInstructions = function(distanceCheck)
	local steeringButtons = {
		{
			["label"] = "Right",
			["button"] = "~INPUT_CELLPHONE_RIGHT~"
		},
		{
			["label"] = "Foward",
			["button"] = "~INPUT_CELLPHONE_UP~"
		},
		{
			["label"] = "Back",
			["button"] = "~INPUT_CELLPHONE_DOWN~"
		},
		{
			["label"] = "Left",
			["button"] = "~INPUT_CELLPHONE_LEFT~"
		},
		{
			["label"] = "Jump",
			["button"] = "~INPUT_JUMP~"
		}
	}

	local pickupButton = {
		["label"] = "Pick Up",
		["button"] = "~INPUT_CONTEXT~"
	}

	local buttonsToDraw = {
		{
			["label"] = "Get in/Get off",
			["button"] = "~INPUT_DETONATE~"
		}
	}

	if distanceCheck <= Config.LoseConnectionDistance then
		for buttonIndex = 1, #steeringButtons do
			local steeringButton = steeringButtons[buttonIndex]

			table.insert(buttonsToDraw, steeringButton)
		end

		if distanceCheck <= 1.5 then
			table.insert(buttonsToDraw, pickupButton)
			if not Attached then
				DrawText3Ds(GetEntityCoords(RCCar.Entity).x, GetEntityCoords(RCCar.Entity).y, GetEntityCoords(RCCar.Entity).z + 0.5, "[E] Pick Up")
			end
		end
	end


    Citizen.CreateThread(function()
    	Citizen.Wait(0)
        local instructionScaleform = RequestScaleformMovie("instructional_buttons")

        while not HasScaleformMovieLoaded(instructionScaleform) do
            Wait(0)
        end

        PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL")
        PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS")
        PushScaleformMovieFunctionParameterBool(0)
        PopScaleformMovieFunctionVoid()

        for buttonIndex, buttonValues in ipairs(buttonsToDraw) do
            PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(buttonIndex - 1)

            PushScaleformMovieMethodParameterButtonName(buttonValues["button"])
            PushScaleformMovieFunctionParameterString(buttonValues["label"])
            PopScaleformMovieFunctionVoid()
        end

        PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
        PushScaleformMovieFunctionParameterInt(-1)
        PopScaleformMovieFunctionVoid()
        DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255)       
        if Attached then
	        local x = GetEntityRotation(RCCar.Entity).x
	        local y = GetEntityRotation(RCCar.Entity).y

	        if (-40.0 < x and x > 40.0) or (-40.0 < y and y > 40.0) or (HasEntityCollidedWithAnything(RCCar.Entity) and GetEntitySpeed(RCCar.Entity) > 2.6) then
	        	RCCar.AttachPlayer(false)
	        	SetPedToRagdoll(player, 4000, 4000, 0, true, true, false)
			end	
	    end           
    end)
end

RCCar.Spawn = function()
	RCCar.LoadModels({ GetHashKey("rcbandito"), 68070371, GetHashKey("p_defilied_ragdoll_01_s"), "pickup_object", "move_strafe@stealth"})

	local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())

	RCCar.Entity = CreateVehicle(GetHashKey("rcbandito"), spawnCoords, spawnHeading, true)
	RCCar.Skate = CreateObject(GetHashKey("p_defilied_ragdoll_01_s"), 0.0, 0.0, 0.0, true, true, true)
	
	while not DoesEntityExist(RCCar.Entity) do
		Citizen.Wait(5)
	end

	while not DoesEntityExist(RCCar.Skate) do
		Citizen.Wait(5)
	end

	SetVehicleHandlingFloat( RCCar.Entity, "CHandlingData", "fSuspensionForce", 1.5)
	SetVehicleEngineTorqueMultiplier(RCCar.Entity, 0.1)
	SetEntityNoCollisionEntity(RCCar.Entity, player, false)
	SetEntityVisible(RCCar.Entity, false)
	SetAllVehiclesSpawn(RCCar.Entity, true, true, true, true)
	AttachEntityToEntity(RCCar.Skate, RCCar.Entity, GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, -0.15, 0.0, 0.0, 90.0, true, true, true, true, 1, true)	
	SetEntityCollision(RCCar.Skate, true, true)

	RCCar.Driver = CreatePed(5, 68070371, spawnCoords, spawnHeading, true)
	SetEntityInvincible(RCCar.Driver, true)
	SetEntityVisible(RCCar.Driver, false)
	FreezeEntityPosition(RCCar.Driver, true)
	SetPedAlertness(RCCar.Driver, 0.0)

	TaskWarpPedIntoVehicle(RCCar.Driver, RCCar.Entity, -1)

	while not IsPedInVehicle(RCCar.Driver, RCCar.Entity) do
		Citizen.Wait(0)
	end

	RCCar.Attach("place")
end

RCCar.Attach = function(param)
	if not DoesEntityExist(RCCar.Entity) then
		return
	end
	

	if param == "place" then
		AttachEntityToEntity(RCCar.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)

		TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)

		Citizen.Wait(800)

		DetachEntity(RCCar.Entity, false, true)

		PlaceObjectOnGroundProperly(RCCar.Entity)
	elseif param == "pick" then
		Citizen.Wait(100)

		TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)

		Citizen.Wait(600)
	
		AttachEntityToEntity(RCCar.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)

		Citizen.Wait(900)
	
		DetachEntity(RCCar.Entity)

		DeleteEntity(RCCar.Skate)
		DeleteVehicle(RCCar.Entity)
		DeleteEntity(RCCar.Driver)

		RCCar.UnloadModels()
	end

end


RCCar.LoadModels = function(models)
	for modelIndex = 1, #models do
		local model = models[modelIndex]

		if not RCCar.CachedModels then
			RCCar.CachedModels = {}
		end

		table.insert(RCCar.CachedModels, model)

		if IsModelValid(model) then
			while not HasModelLoaded(model) do
				RequestModel(model)	
				Citizen.Wait(10)
			end
		else
			while not HasAnimDictLoaded(model) do
				RequestAnimDict(model)
				Citizen.Wait(10)
			end    
		end
	end
end

RCCar.UnloadModels = function()
	for modelIndex = 1, #RCCar.CachedModels do
		local model = RCCar.CachedModels[modelIndex]

		if IsModelValid(model) then
			SetModelAsNoLongerNeeded(model)
		else
			RemoveAnimDict(model)   
		end
	end
end

RCCar.AttachPlayer = function(toggle)
	if toggle then
		TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 8.0, -1, 1, 1.0, false, false, false)
		AttachEntityToEntity(player, RCCar.Entity , 20, 0.0, 0.0, 0.98, 0.0, 0.0, -15.0, true, true, true, true, true, true)
		SetEntityCollision(player, true, false)
		Attached = true		
	elseif not toggle then
		DetachEntity(player, false, false)
		Attached = false
		StopAnimTask(player, "move_strafe@stealth", "idle", 1.0)	
	end	
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function ShowSubtitle(text, ms)  
    BeginTextCommandPrint("STRING") 
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandPrint(ms, 1)
end
