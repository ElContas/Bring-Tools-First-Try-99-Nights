--// BringTools4.lua - Versión final
--// Autor: ElContas
--// Mueve Tools y Models reales desde Workspace.Items sin duplicar
--// Incluye prints detallados para depurar

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear RemoteEvent si no existe
local bringEvent = ReplicatedStorage:FindFirstChild("BringEvent")
if not bringEvent then
	bringEvent = Instance.new("RemoteEvent")
	bringEvent.Name = "BringEvent"
	bringEvent.Parent = ReplicatedStorage
	print("[BringTools4] RemoteEvent creado correctamente.")
else
	print("[BringTools4] RemoteEvent ya existente.")
end

-- Posiciones de destino
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

-- Evento del cliente
bringEvent.OnServerEvent:Connect(function(player, data)
	if not data or not data.items or not data.spawn then
		warn("[BringTools4] Datos inválidos recibidos.")
		return
	end

	local spawnPos
	if type(spawnLocations[data.spawn]) == "function" then
		spawnPos = spawnLocations[data.spawn](player)
	else
		spawnPos = spawnLocations[data.spawn]
	end

	local itemsFolder = Workspace:FindFirstChild("Items")
	if not itemsFolder then
		warn("[BringTools4] No existe Workspace.Items")
		return
	end

	print("[BringTools4] Bring solicitado por:", player.Name)
	print("[BringTools4] Objetos:", table.concat(data.items, ", "))
	print("[BringTools4] Destino:", data.spawn)
	print("[BringTools4] Cantidad:", data.amount or 1)

	for _, itemName in pairs(data.items) do
		local moved = 0
		for _, obj in pairs(itemsFolder:GetChildren()) do
			if obj.Name == itemName and moved < (data.amount or 1) then
				if obj:IsA("Tool") then
					obj.Parent = Workspace
					if obj:FindFirstChild("Handle") then
						obj.Handle.CFrame = CFrame.new(spawnPos + Vector3.new(0, moved * 2, 0))
						print("[BringTools4] Movido Tool:", obj.Name)
					else
						warn("[BringTools4] Tool sin Handle:", obj.Name)
					end
					moved += 1
				elseif obj:IsA("Model") then
					if not obj.PrimaryPart then
						for _, part in ipairs(obj:GetDescendants()) do
							if part:IsA("BasePart") then
								obj.PrimaryPart = part
								break
							end
						end
					end

					if obj.PrimaryPart then
						obj:SetPrimaryPartCFrame(CFrame.new(spawnPos + Vector3.new(0, moved * 2, 0)))
						obj.Parent = Workspace
						print("[BringTools4] Movido Model:", obj.Name)
						moved += 1
					else
						warn("[BringTools4] Model sin PrimaryPart:", obj.Name)
					end
				else
					warn("[BringTools4] Objeto no reconocido:", obj.Name)
				end
			end
		end

		if moved == 0 then
			warn("[BringTools4] No se encontró el objeto:", itemName)
		end
	end

	print("[BringTools4] Bring completado para:", player.Name)
end)
