-- BringTools2.lua
-- Script completo que hace todo: RemoteEvent, GUI, Bring, prints
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
    print("[BringTools2] ✅ RemoteEvent creado")
end

-- Items por categoría
local categories = {
    WorkBenchFire = {"Washing Machine","Oil Barrel","Geom of the Forest Fragment","Cultist Prototype","Cultist Experiment","Cultis Gem","Tyre","Sheet Metal","Broken Fan","Fuel Canister","Old Radio","Coal","Wood","Sapling","Chair","Bolt","Broken Microwave","Old Car Engine"},
    Tools = {"Thorn Body Armor","Riot Shield","Tactical Shotgun","Morningstar","Kunai","Strong Axe","Strong Flashlight","MedKit","Chainsaw","Giant Sack","Good Sack","Snowball","Ice Axe","Bandage","Rifle Ammo","Rifle","Revolver","Good Axe","Halloween Candle","Revolver Ammo","Old Taming Flute","Old Flashlight","Spear"},
    Food = {"Stew","Cooked Ribs","Ribs","Cooked Morsel","Cooked Steak","Pumpkin","Morsel","Carrot","Berry","Steak"},
    Extra = {"Defense Blueprint","Mamooth Tuck","Artic Fox Pelt","Bear Pelt","Coin Stack","Kraken Kid","Item Chest3","Seed Box","Leather Body","Cultist","Wolf Pelt","Bunny Foot","Polar Bear Pelt","Alpha Wolf Pelt"}
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

-- Función para manejar Bring
bringEvent.OnServerEvent:Connect(function(player, data)
    print("[BringTools2] Datos recibidos de:", player.Name)
    print("[BringTools2] Enviando datos al servidor:", data)

    local spawnPos
    if type(spawnLocations[data.spawn]) == "function" then
        spawnPos = spawnLocations[data.spawn](player)
    else
        spawnPos = spawnLocations[data.spawn]
    end

    local itemsFolder = Workspace:FindFirstChild("Items")
    if not itemsFolder then
        warn("[BringTools2] No existe Workspace.Items")
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
                    print("[BringTools2] Tepeado:", clone.Name, "en", spawnPos)
                else
                    print("[BringTools2] No se pudo tepear:", itemName)
                end
                found += 1
            end
        end
    end
end)

-- GUI para Xeno (LocalScript estilo CouRoblox)
Players.PlayerAdded:Connect(function(player)
    local function openBringToolsGUI()
        if player.PlayerGui:FindFirstChild("BringToolsGUI") then
            player.PlayerGui.BringToolsGUI:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BringToolsGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player:WaitForChild("PlayerGui")

        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0,450,0,550)
        mainFrame.Position = UDim2.new(0.5,-225,0.5,-275)
        mainFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        mainFrame.Parent = screenGui

        local title = Instance.new("TextLabel")
        title.Text = "⚒️ BRING TOOLS"
        title.Size = UDim2.new(1,0,0,40)
        title.BackgroundColor3 = Color3.fromRGB(30,30,30)
        title.TextColor3 = Color3.fromRGB(255,255,255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 24
        title.Parent = mainFrame

        local closeButton = Instance.new("TextButton")
        closeButton.Text = "X"
        closeButton.Size = UDim2.new(0,40,0,40)
        closeButton.Position = UDim2.new(1,-40,0,0)
        closeButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
        closeButton.TextColor3 = Color3.fromRGB(255,255,255)
        closeButton.Font = Enum.Font.SourceSansBold
        closeButton.TextSize = 24
        closeButton.Parent = mainFrame
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)

        -- Categorías
        local categoryFrame = Instance.new("Frame")
        categoryFrame.Size = UDim2.new(1,0,0,40)
        categoryFrame.Position = UDim2.new(0,0,0,40)
        categoryFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)
        categoryFrame.Parent = mainFrame

        local categoryButtons = {}
        for i,catName in ipairs({"WorkBenchFire","Tools","Food","Extra"}) do
            local btn = Instance.new("TextButton")
            btn.Name = catName.."Button"
            btn.Text = catName
            btn.Size = UDim2.new(0,100,1,0)
            btn.Position = UDim2.new(0,(i-1)*110,0,0)
            btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 18
            btn.Parent = categoryFrame
            categoryButtons[catName] = btn
        end

        local itemsScroll = Instance.new("ScrollingFrame")
        itemsScroll.Size = UDim2.new(1,0,0,250)
        itemsScroll.Position = UDim2.new(0,0,0,80)
        itemsScroll.BackgroundColor3 = Color3.fromRGB(60,60,60)
        itemsScroll.BorderSizePixel = 0
        itemsScroll.CanvasSize = UDim2.new(0,0,0,0)
        itemsScroll.ScrollBarThickness = 10
        itemsScroll.Parent = mainFrame

        local itemsLayout = Instance.new("UIListLayout")
        itemsLayout.Parent = itemsScroll
        itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        itemsLayout.Padding = UDim.new(0,5)

        -- Spawn
        local spawnFrame = Instance.new("Frame")
        spawnFrame.Size = UDim2.new(1,0,0,40)
        spawnFrame.Position = UDim2.new(0,0,0,340)
        spawnFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)
        spawnFrame.Parent = mainFrame

        local spawnButtons = {}
        for i,name in ipairs({"Fire","WorkBench","Player"}) do
            local btn = Instance.new("TextButton")
            btn.Name = name.."Button"
            btn.Text = name
            btn.Size = UDim2.new(0,130,1,0)
            btn.Position = UDim2.new(0,(i-1)*140,0,0)
            btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 18
            btn.Parent = spawnFrame
            spawnButtons[name] = btn
        end

        local quantityBox = Instance.new("TextBox")
        quantityBox.PlaceholderText = "Cantidad"
        quantityBox.Size = UDim2.new(0,80,0,40)
        quantityBox.Position = UDim2.new(0,10,0,400)
        quantityBox.BackgroundColor3 = Color3.fromRGB(100,100,100)
        quantityBox.TextColor3 = Color3.fromRGB(255,255,255)
        quantityBox.Font = Enum.Font.SourceSansBold
        quantityBox.TextSize = 18
        quantityBox.Parent = mainFrame

        local bringButton = Instance.new("TextButton")
        bringButton.Text = "Bring!"
        bringButton.Size = UDim2.new(0,100,0,40)
        bringButton.Position = UDim2.new(0,120,0,400)
        bringButton.BackgroundColor3 = Color3.fromRGB(50,150,50)
        bringButton.TextColor3 = Color3.fromRGB(255,255,255)
        bringButton.Font = Enum.Font.SourceSansBold
        bringButton.TextSize = 18
        bringButton.Parent = mainFrame

        local selectedCategory = nil
        local selectedItems = {}
        local selectedSpawn = nil

        local function populateItems(categoryName)
            for _,child in pairs(itemsScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            selectedItems = {}
            for _,itemName in ipairs(categories[categoryName] or {}) do
                local btn = Instance.new("TextButton")
                btn.Text = itemName
                btn.Size = UDim2.new(1,-10,0,30)
                btn.BackgroundColor3 = Color3.fromRGB(120,120,120)
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.Font = Enum.Font.SourceSans
                btn.TextSize = 16
                btn.Parent = itemsScroll
                btn.MouseButton1Click:Connect(function()
                    if selectedItems[itemName] then
                        selectedItems[itemName] = nil
                        btn.BackgroundColor3 = Color3.fromRGB(120,120,120)
                    else
                        selectedItems[itemName] = true
                        btn.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    end
                end)
            end
            itemsScroll.CanvasSize = UDim2.new(0,0,0,itemsLayout.AbsoluteContentSize.Y)
        end

        for catName,btn in pairs(categoryButtons) do
            btn.MouseButton1Click:Connect(function()
                selectedCategory = catName
                populateItems(catName)
            end)
        end

        for name,btn in pairs(spawnButtons) do
            btn.MouseButton1Click:Connect(function()
                selectedSpawn = name
                for _,b in pairs(spawnButtons) do b.BackgroundColor3 = Color3.fromRGB(100,100,100) end
                btn.BackgroundColor3 = Color3.fromRGB(0,255,0)
            end)
        end

        bringButton.MouseButton1Click:Connect(function()
            if not selectedCategory then return end
            if not next(selectedItems) then return end
            if not selectedSpawn then return end
            local amount = tonumber(quantityBox.Text) or 1
            local itemList = {}
            for k,_ in pairs(selectedItems) do table.insert(itemList,k) end

            print("[BringTools2 GUI] Enviando datos al servidor:", itemList, "Spawn:", selectedSpawn, "Cantidad:", amount)
            bringEvent:FireServer({
                category = selectedCategory,
                items = itemList,
                spawn = selectedSpawn,
                amount = amount
            })
        end)

        print("[BringTools2 GUI] GUI cargada correctamente ✅")
    end

    openBringToolsGUI()
end)
