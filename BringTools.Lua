-- ServerScriptService: BringToolsServer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear RemoteEvent si no existe
local bringEvent = ReplicatedStorage:FindFirstChild("BringEvent")
if not bringEvent then
	bringEvent = Instance.new("RemoteEvent")
	bringEvent.Name = "BringEvent"
	bringEvent.Parent = ReplicatedStorage
end

-- Items por categoría
local categories = {
	WorkBenchFire = {
		"Washing Machine","Oil Barrel","Geom of the Forest Fragment","Cultist Prototype",
		"Cultist Experiment","Cultis Gem","Tyre","Sheet Metal","Broken Fan",
		"Fuel Canister","Old Radio","Coal","Wood","Sapling","Chair","Bolt",
		"Broken Microwave","Old Car Engine"
	},
	Tools = {
		"Thorn Body Armor","Riot Shield","Tactical Shotgun","Morningstar","Kunai",
		"Strong Axe","Strong Flashlight","MedKit","Chainsaw","Giant Sack","Good Sack",
		"Snowball","Ice Axe","Bandage","Rifle Ammo","Rifle","Revolver","Good Axe",
		"Halloween Candle","Revolver Ammo","Old Taming Flute","Old Flashlight","Spear"
	},
	Food = {
		"Stew","Cooked Ribs","Ribs","Cooked Morsel","Cooked Steak","Pumpkin","Morsel",
		"Carrot","Berry","Steak"
	},
	Extra = {
		"Defense Blueprint","Mamooth Tuck","Artic Fox Pelt","Bear Pelt","Coin Stack",
		"Kraken Kid","Item Chest3","Seed Box","Leather Body","Cultist","Wolf Pelt",
		"Bunny Foot","Polar Bear Pelt","Alpha Wolf Pelt"
	}
}

-- Spawn locations
local spawnLocations = {
	Fire = Vector3.new(0,22,0),
	WorkBench = Vector3.new(20,24,-6),
	Player = function(player)
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			return player.Character.HumanoidRootPart.Position
		else
			return Vector3.new(0,5,0)
		end
	end
}

-- Manejar el evento del cliente
bringEvent.OnServerEvent:Connect(function(player, data)
	-- data = {category = "Tools", items = {"Rifle","Revolver"}, spawn = "Fire", amount = 1}
	if not data or not data.items or not data.spawn then return end

	local spawnPos
	if type(spawnLocations[data.spawn]) == "function" then
		spawnPos = spawnLocations[data.spawn](player)
	else
		spawnPos = spawnLocations[data.spawn]
	end

	local itemsFolder = Workspace:FindFirstChild("Items")
	if not itemsFolder then
		warn("[BringTools] No existe Workspace.Items")
		return
	end

	for _,itemName in pairs(data.items) do
		local found = 0
		for _,obj in pairs(itemsFolder:GetChildren()) do
			if obj.Name == itemName then
				if found >= (data.amount or 1) then break end
				local clone = obj:Clone()
				local success = false

				if clone:IsA("Tool") and clone:FindFirstChild("Handle") then
					clone.Parent = Workspace
					clone.Handle.CFrame = CFrame.new(spawnPos + Vector3.new(0,found*2,0))
					success = true
				elseif clone:IsA("Model") then
					if not clone.PrimaryPart then
						for _,part in pairs(clone:GetDescendants()) do
							if part:IsA("BasePart") then
								clone.PrimaryPart = part
								break
							end
						end
					end
					if clone.PrimaryPart then
						clone.Parent = Workspace
						clone:SetPrimaryPartCFrame(CFrame.new(spawnPos + Vector3.new(0,found*2,0)))
						success = true
					end
				end

				if success then
					print("[BringTools] Tepeado:", clone.Name, "en", spawnPos)
				else
					print("[BringTools] No se pudo tepear:", itemName)
				end
				found += 1
			end
		end
	end
end)
