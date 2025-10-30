-- BringItems3.lua (Servidor) 
-- Pegar en ServerScriptService
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Crear RemoteEvent si no existe
local bringEvent = ReplicatedStorage:FindFirstChild("BringEvent")
if not bringEvent then
    bringEvent = Instance.new("RemoteEvent")
    bringEvent.Name = "BringEvent"
    bringEvent.Parent = ReplicatedStorage
    print("[BringItems3] ✅ RemoteEvent 'BringEvent' creado en ReplicatedStorage")
else
    print("[BringItems3] ✅ RemoteEvent 'BringEvent' ya existe")
end

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

-- Manejar evento de cliente
bringEvent.OnServerEvent:Connect(function(player, data)
    if not data or not data.items or not data.spawn then
        warn("[BringItems3] ❌ Datos inválidos recibidos de", player.Name)
        return
    end

    local spawnPos
    if type(spawnLocations[data.spawn]) == "function" then
        spawnPos = spawnLocations[data.spawn](player)
    else
        spawnPos = spawnLocations[data.spawn]
    end

    print("[BringItems3] ▶ Solicitud recibida de:", player.Name)
    print("        Spawn:", data.spawn, "Cantidad:", data.amount or 1, "Items:", table.concat(data.items, ", "))

    local itemsFolder = Workspace:FindFirstChild("Items")
    if not itemsFolder then
        warn("[BringItems3] ❌ No existe Workspace.Items")
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
                    clone.Handle.CFrame = CFrame.new(spawnPos + Vector3.new(0, found*2,0))
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
                        clone:SetPrimaryPartCFrame(CFrame.new(spawnPos + Vector3.new(0, found*2,0)))
                        success = true
                    end
                end

                if success then
                    print("[BringItems3] ✅ Tepeado:", clone.Name, "en", spawnPos)
                else
                    print("[BringItems3] ❌ No se pudo tepear:", itemName, "(falta PrimaryPart o Handle?)")
                end
                found += 1
            end
        end
        if found == 0 then
            print("[BringItems3] ⚠️ No se encontró el item:", itemName)
        elseif found < (data.amount or 1) then
            print("[BringItems3] ⚠️ Solo se encontraron", found, "de", data.amount or 1, "del item:", itemName)
        end
    end
end)

print("[BringItems3] Script cargado y listo para recibir solicitudes de BringTools3 LocalScript")
