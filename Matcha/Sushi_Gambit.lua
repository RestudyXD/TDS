local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local GameData = ReplicatedStorage:WaitForChild("GameData")
local PlayerStats = LocalPlayer:WaitForChild("PlayerStats")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


local Settings = {
    AutoCooking = false,
    AutoWashing = false,
    AutoChloroformSpys = false,
    InstantSeatCustomer = false,
    NotifyDineAndDash = false,
    SpoofGreenbar = false,
    InstantCleanDish = false,
    SpoofSpongeEffectiveness = false,
    NotifyAdminJoin = false,
}

local ESP_SETTINGS = {
    Dasher = {
        Enabled = false,
        Color = Color3.new(1, 0, 0)
    },
    Armed = {
        Enabled = false,
        Color = Color3.new(1, 0, 0)
    },
    Police = {
        Enabled = false,
        Color = Color3.new(0, 0, 1)
    }
}

function get_offsets()
    local url = "https://imtheo.lol/Offsets/OffsetsHex.json"
    local response = game:HttpGet(url)
    return HttpService:JSONDecode(response)
end

local ScreenGuiEnabled = get_offsets()["Offsets"]["GuiObject"]["ScreenGui_Enabled"]
local HoldDuration = get_offsets()["Offsets"]["ProximityPrompt"]["HoldDuration"]
local PromptEnabled = get_offsets()["Offsets"]["ProximityPrompt"]["Enabled"]

UI.AddTab("Sushi Gambit", function(tab)
    local MainSec = tab:Section("Main", "Left", { "Auto", "Cheat" } )

    if MainSec.page == 0 then
        MainSec:Toggle('auto_cooking', 'Auto Cooking', function(value)
            notify("Auto Cooking: " .. tostring(value), "", 3)
            Settings.AutoCooking = value
        end)

        MainSec:Toggle('auto_washing', 'Auto DishWashing', function(value)
            notify("Auto DishWashing: " .. tostring(value), "", 3)
            Settings.AutoWashing = value
        end)

        MainSec:Toggle('auto_chloroform_spys', 'Auto Chloroform Spys', function(value)
            notify("Auto Chloroform Spys: " .. tostring(value), "", 3)
            Settings.AutoChloroformSpys = value
        end)
    elseif MainSec.page == 1 then
        MainSec:Toggle('spoof_greenbar', 'Spoof Greenbar', function(value)
            notify("Spoof Greenbar: " .. tostring(value), "", 3)
            Settings.SpoofGreenbar = value
        end)

        MainSec:Toggle('instant_clean_dish', 'Fast Clean Dish', function(value)
            notify("Fast Clean Dish: " .. tostring(value), "", 3)
            Settings.InstantCleanDish = value
        end)

        MainSec:Toggle('spoof_sponge_effectiveness', 'Instant Sponge Effect', function(value)
            notify("Spoof Sponge Effectiveness: " .. tostring(value), "", 3)
            Settings.SpoofSpongeEffectiveness = value
        end)
    end


    local PlayerTab = tab:Section("Player", "Left", { "Player", "Notify" } )

    local Hat = {
        "",
        "BunnyEars",
        "BunnyTail",
        "TallyTopper",
        "OBCHardHat",
        "Pager",
        "ChefHat",
        "RobloxVisor",
        "Pencil",
        "HeadLeaves"
    }

    local background = {
        'Intern',
        'SofaSurfer',
        'LineCook',
        -- 'JustInForTheMoney',
        -- 'JustInForTheExperience',
        'TechEnthusiast',
        'Amish',
        'Butcher',
        'CoffeeFanatic',
        'UsedCarSalesman',
        'Philanthropist',
        'SelfAbsorbed'
    }

    if PlayerTab.page == 0 then
        PlayerTab:Toggle('inf_stamina', 'Infinite Stamina', function(value)
            notify("Infinite Stamina: " .. tostring(value), "", 3)
            if value then
                PlayerStats.StaminaUsageMultiplier.Value = -1
                PlayerStats.StaminaGainMultiplier.Value = 100
                PlayerStats.StaminaUsageMultiplierNonHarvestRelated.Value = 0
            else
                PlayerStats.StaminaUsageMultiplier.Value = 1
                PlayerStats.StaminaUsageMultiplierNonHarvestRelated.Value = 1
            end
        end)

        PlayerTab:Tip('Does not work with hatchet or knife for harvesting meat.')

        PlayerTab:SliderInt('player_walkspeed', 'Walk Speed', 12, 20, 12, function(value)
            PlayerStats.WalkSpeed.Value = value
        end)

        PlayerTab:Combo('background', 'Career Background', background, 0, function(idx, text)
            LocalPlayer.CareerBackground.EquippedCareerBackground.Value = text
            notify("Career Background change to: " .. text, "", 3)
        end)

        PlayerTab:Tip('No "ForTheMoney" and "ForTheExperience", bc it will make game crash.')

    elseif PlayerTab.page == 1 then
        PlayerTab:Toggle('notify_admin_join', 'Admin Alert', function(value)
            notify("Admin Alert: " .. tostring(value), "", 3)
            Settings.NotifyAdminJoin = value
        end)
    end

    local NpcTab = tab:Section("Npc", "Left", { "Npc" } )

    if NpcTab.page == 0 then
        NpcTab:Toggle('instant_seatcustomer', 'Instant Seat Customer', function(value)
            notify("Instant Seat Customer: " .. tostring(value), "", 3)
            Settings.InstantSeatCustomer = value
        end)

        NpcTab:Spacing()
        NpcTab:Text("Visuals")
        NpcTab:Spacing()

        NpcTab:Toggle('show_dasher', 'Dasher', function(value)
            if not Settings.InstantSeatCustomer then
                UI.SetValue('instant_seatcustomer', true)
                Settings.InstantSeatCustomer = value
            end
            notify("Show Dasher: " .. tostring(value), "", 3)
            ESP_SETTINGS.Dasher.Enabled = value
        end)

        NpcTab:ColorPicker("dasher_color", 1, 0, 0, 1, function(color, alpha)
            ESP_SETTINGS.Dasher.Color = Color3.new(color.R, color.G, color.B)
        end)

        NpcTab:Tip('Turn on Instant Seat Customer to make it work!')

        NpcTab:Toggle('show_armed', 'Armed npc', function(value)
            notify("Show Armed NPC: " .. tostring(value), "", 3)
            ESP_SETTINGS.Armed.Enabled = value
        end)

        NpcTab:ColorPicker("armed_color", 1, 0, 0, 1, function(color, alpha)
            ESP_SETTINGS.Armed.Color = Color3.new(color.R, color.G, color.B)
        end)

        NpcTab:Toggle('show_police', 'Police npc', function(value)
            notify("Show Police NPC: " .. tostring(value), "", 3)
            ESP_SETTINGS.Police.Enabled = value
        end)

        NpcTab:ColorPicker("police_color", 0, 0, 1, 1, function(color, alpha)
            ESP_SETTINGS.Police.Color = Color3.new(color.R, color.G, color.B)
        end)

    elseif NpcTab.page == 1 then
    end


    local CookingSec = tab:Section("Cooking", "Right")

    CookingSec:SliderFloat('cooking_speed', 'Cooking Speed', 1.0, 5.0, 1.0, '%.1f', function(value)
        PlayerStats.CookingSpeedMultiplier.Value = value
    end)

    CookingSec:SliderInt('dupe_sushi_chance', 'Dupe Sushi Chance (%)', 0, 100, 0, function(value)
        PlayerStats.SushiDuplicationChance.Value = value
    end)

    CookingSec:SliderInt('conveyor_speed', 'Conveyor Speed', 1, 10, 1, function(value)
        GameData.ConveyorSpeedValue.Value = value
    end)

    local PromptSec = tab:Section("Prompt", "Right")

    PromptSec:Toggle('always_computer', 'Use computer during blackout', function(value)
        spawn(function()
            while true do
                local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
                memory_write("byte", computer + PromptEnabled, 1)
                task.wait(.1)
            end
        end)
    end)

    local promptc = PromptSec:Combo('prompt_type', 'Prompt Type', { 'ALL', 'Computer', 'Conveyor', 'Freezer', 'Toolbin', 'SeatingStation' }, 0, function(idx, text)
        notify("Click button to set instant prompt: " .. text, "", 3)
    end)

    PromptSec:Button('Set instant prompt', function()
        local text = promptc:GetText()
        if text == 'ALL' then
            spawn(function()
                while true do
                    local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
                    memory_write("float", computer + HoldDuration, 0)
                    task.wait(.1)
                end
            end)
            local conveyor_keypad = game.Workspace.RestaurantArea.restaurant.mainStuff.conveyors.keypad.PromptPart.ProximityPrompt.Address
            memory_write("float", conveyor_keypad + HoldDuration, 0)
            local freezer = game.Workspace.RestaurantArea.restaurant.FreezerDoor.PromptHitbox.ProximityPrompt.Address
            memory_write("float", freezer + HoldDuration, 0)
            local toolbin = game.Workspace.Toolbin.PromptHitbox.ProximityPrompt.Address
            memory_write("float", toolbin + HoldDuration, 0)
            local SeatingStation = game.Workspace.RestaurantArea.restaurant["the waiter stand thingy"].Stations.SeatingStation.TriggerPart.SeatCustomersPrompt.Address
            memory_write("float", SeatingStation + HoldDuration, 0)
        elseif text == 'Computer' then
            spawn(function()
                while true do
                    local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
                    memory_write("float", computer + HoldDuration, 0)
                    task.wait(.1)
                end
            end)
        elseif text == 'Conveyor' then
            local conveyor_keypad = game.Workspace.RestaurantArea.restaurant.mainStuff.conveyors.keypad.PromptPart.ProximityPrompt.Address
            memory_write("float", conveyor_keypad + HoldDuration, 0)
        elseif text == 'Freezer' then
            local freezer = game.Workspace.RestaurantArea.restaurant.FreezerDoor.PromptHitbox.ProximityPrompt.Address
            memory_write("float", freezer + HoldDuration, 0)
        elseif text == 'Toolbin' then
            local toolbin = game.Workspace.Toolbin.PromptHitbox.ProximityPrompt.Address
            memory_write("float", toolbin + HoldDuration, 0)
        elseif text == 'SeatingStation' then
            local SeatingStation = game.Workspace.RestaurantArea.restaurant["the waiter stand thingy"].Stations.SeatingStation.TriggerPart.SeatCustomersPrompt.Address
            memory_write("float", SeatingStation + HoldDuration, 0)
        end
    end)

    PromptSec:Text(
    "Version: 1.0.6\n" ..
    "Discord: patreon\n" ..
    "changelog:\n" ..
    "[+] Spoof Career Background\n" ..
    "[+] Armed NPC ESP\n" ..
    "[+] Police NPC ESP\n" ..
    "[+] Remove showing dasher when caught\n"..
    "[~] Better ESP logic\n" ..
    "[~] Beautify UI and add more settings\n"..
    "[~] Fixed DishWashing Error"
    )
end)

Settings.AutoCooking = UI.GetValue("auto_cooking")
Settings.AutoWashing = UI.GetValue("auto_washing")
Settings.AutoChloroformSpys = UI.GetValue("auto_chloroform_spys")
Settings.InstantSeatCustomer = UI.GetValue("instant_seatcustomer")
Settings.NotifyDineAndDash = UI.GetValue("notify_dineanddash")
Settings.SpoofGreenbar = UI.GetValue("spoof_greenbar")
Settings.InstantCleanDish = UI.GetValue("instant_clean_dish")
Settings.SpoofSpongeEffectiveness = UI.GetValue("spoof_sponge_effectiveness")
Settings.NotifyAdminJoin = UI.GetValue("notify_admin_join")

ESP_SETTINGS.Dasher.Enabled = UI.GetValue("show_dasher")
ESP_SETTINGS.Dasher.Color = Color3.new(1, 0, 0)

ESP_SETTINGS.Armed.Enabled = UI.GetValue("show_armed")
ESP_SETTINGS.Armed.Color =  Color3.new(1, 0, 0)

ESP_SETTINGS.Police.Enabled = UI.GetValue("show_police")
ESP_SETTINGS.Police.Color = Color3.new(0, 0, 1)

local Admin = {
    ["UserIds"] = { 105479622, 65095440, 1425697210, 126961971, 127528152, 319065798, 2754844524, 125440222, 1783725423 }
}


Players.PlayerAdded:Connect(function(player)
    if table.find(Admin.UserIds, player.UserId) and Settings.NotifyAdminJoin then
        notify("Admin Joined: " .. player.Name, "ADMIN ALERT", 8)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoCooking then
            if not PlayerGui:FindFirstChild("MakeSushiMinigame") then return end
            local addr = PlayerGui.MakeSushiMinigame.Address
            local Visible = memory_read("byte", addr + ScreenGuiEnabled)
            if Visible == 1 then
                local CuttingBarFrame = PlayerGui.MakeSushiMinigame.MainFrame:FindFirstChild("CuttingBarFrame")
                local SliderPos = CuttingBarFrame.CutBar.Slider.AbsolutePosition
                local GreenBarPos = CuttingBarFrame.CutBar.GreenBar.AbsolutePosition

                if SliderPos.X >= GreenBarPos.X and SliderPos.X <= GreenBarPos.X +
                    CuttingBarFrame.CutBar.GreenBar.AbsoluteSize.X then
                    keypress(0x43)
                    keyrelease(0x43)
                end
            end
        end
        task.wait(.05)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoWashing  and game.Workspace.Kitchen.TheSink.DirtyDishAmount.Value > 0 then
            if not PlayerGui:FindFirstChild("DishWashingGui") then return end
            local addr = PlayerGui.DishWashingGui.Address
            local Visible = memory_read("byte", addr + ScreenGuiEnabled)
            if Visible == 1 then
                for i, v in pairs(PlayerGui.DishWashingGui.MainFrame.QueueBarFrame.Queue.KeysHolder:GetChildren()) do
                    if v:IsA("Frame") and v.Name == "KeyTemplate" then
                        local key = v:GetAttribute("Key")

                        if key == "Q" then
                            keypress(0x51)
                            keyrelease(0x51)
                        elseif key == "E" then
                            keypress(0x45)
                            keyrelease(0x45)
                        elseif key == "R" then
                            keypress(0x52)
                            keyrelease(0x52)
                        elseif key == "F" then
                            keypress(0x46)
                            keyrelease(0x46)
                        end
                    end
                end
            end
        end

        if UI.GetValue("instant_washing") then
            PlayerStats.CleaningExpMultiplier.Value = 9999
        end
        task.wait(.01)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoChloroformSpys then
            local Tool = Character:FindFirstChild("Chloroform Spray")

            if Tool then
                local HitTextLabel = Tool.ChloroformChallenge.ButtonToHitFrame.Container:FindFirstChild("TextLabel")

                if HitTextLabel then
                    local key = HitTextLabel.Text

                    if key == "Q" then
                        keypress(0x51)
                        keyrelease(0x51)
                    elseif key == "E" then
                        keypress(0x45)
                        keyrelease(0x45)
                    end
                end
            end
        end
        task.wait(.01)
    end
end)

task.spawn(function()
    while true do
        if UI.GetValue('spoof_greenbar') then
            PlayerStats.EffectiveCookingLevel.Value = 1000
            PlayerStats.NoIngredientUseChance.Value = 1
        end

        if UI.GetValue('instant_clean_dish') then
            PlayerStats.EffectiveCleaningLevel.Value = 9999
        end

        if UI.GetValue('spoof_sponge_effectiveness') then
            PlayerStats.SpongeEffectiveness.Value = 9999
        end

        task.wait(.1)
    end
end)

local STATE = {
    ACTIVE = 1,
    DESTROYED = 2
}

local Entity = {}
Entity.__index = Entity

function Entity.new(instance, text, typeName)
    return setmetatable({
        Instance = instance,
        Text = text,
        Type = typeName,
        State = STATE.ACTIVE
    }, Entity)
end

function Entity:Update(pos, onScreen, enabled)
    if self.State == STATE.DESTROYED then return end
    if not enabled then
        self:Destroy()
        return
    end

    if not onScreen then
        self.Text.Visible = false
        return
    end

    self.Text.Text = self.Type
    self.Text.Position = pos
    self.Text.Visible = true
end

function Entity:Destroy()
    if self.State == STATE.DESTROYED then return end
    self.State = STATE.DESTROYED

    pcall(function()
        self.Text:Remove()
    end)
end

function Entity:Hide()
    if self.Text then
        self.Text.Visible = false
    end
end

function Entity:SetColor(color)
    if self.Text then
        self.Text.Color = color
    end
end

local Manager = {
    Entities = {}
}

function Manager:Add(id, entity)
    self.Entities[id] = entity
end

function Manager:Remove(id)
    if self.Entities[id] then
        self.Entities[id]:Destroy()
        self.Entities[id] = nil
    end
end

local folder = game.Workspace.NpcDestination.SpawnedNPCs
local npcs_list = {}
local customer_list = {}
local dasher_list = {}

RunService.Heartbeat:Connect(function()
    for id, entity in pairs(Manager.Entities) do
        
        local inst = entity.Instance
        if not inst or not inst.Parent then
            Manager:Remove(id)
            continue
        end

        if entity.Type == "Dasher" then
            local Caught = inst:GetAttribute("Caught")

            if not Caught then
                Manager:Remove(id)
                continue
            end
        end

        local head = inst:FindFirstChild("Head")
        if not head then
            entity:Hide()
            continue
        end

        local pos, onScreen = WorldToScreen(head.Position + Vector3.new(0, 1.5, 0))

        local cfg = ESP_SETTINGS[entity.Type]
        if not cfg then
            Manager:Remove(id)
            continue
        end

        local enabled = cfg.Enabled
        local color = cfg.Color

        entity:SetColor(color)
        entity:Update(pos, onScreen, enabled)
    end
end)

task.spawn(function()
    while true do
        if not isrbxactive() then return end

        for _, npc in pairs(folder:GetChildren()) do

            if Settings.InstantSeatCustomer and npc:GetAttribute("CurrentState") == "WaitingInLine" then
                if not customer_list[npc.Address] then
                    local torso = npc:FindFirstChild("Torso")
                    local prompt = torso and torso:FindFirstChild("WaitProximityPrompt")

                    if prompt and prompt.Address then
                        memory_write("float", prompt.Address + HoldDuration, 0)
                        customer_list[npc.Address] = true
                    end
                end
            end

            if ESP_SETTINGS.Dasher.Enabled then

                if customer_list[npc.Address] then
                    local torso = npc:FindFirstChild("Torso")
                    local prompt = torso and torso:FindFirstChild("CatchDasherPrompt")

                    if prompt then
                        memory_write("float", prompt.Address + HoldDuration, 0)

                        if not Manager.Entities[npc.Address] then

                            customer_list[npc.Address] = nil

                            Manager:Add(
                            npc.Address,
                            Entity.new(npc, Drawing.new("Text"), "Dasher")
                            )
                        else
                            Manager.Entities[npc.Address].Instance = npc
                        end
                    end
                end

            else
                if Manager.Entities[npc.Address] and Manager.Entities[npc.Address].Type == "Dasher" then
                    Manager:Remove(npc.Address)
                end
            end

            if ESP_SETTINGS.Police.Enabled and npc:GetAttribute("Cop") == true then

                if not Manager.Entities[npc.Address] then
                    Manager:Add(
                    npc.Address,
                    Entity.new(npc, Drawing.new("Text"), "Police")
                    )
                else
                    Manager.Entities[npc.Address].Instance = npc
                end
            else
                if Manager.Entities[npc.Address] and Manager.Entities[npc.Address].Type == "Police" then
                    Manager:Remove(npc.Address)
                end
            end


            if ESP_SETTINGS.Armed.Enabled and npc:GetAttribute("WeaponOfChoice") == "Knife" then

                if not Manager.Entities[npc.Address] then
                    Manager:Add(
                    npc.Address,
                    Entity.new(npc, Drawing.new("Text"), "Armed")
                    )
                else
                    Manager.Entities[npc.Address].Instance = npc
                end
            else
                if Manager.Entities[npc.Address] and Manager.Entities[npc.Address].Type == "Armed" then
                    Manager:Remove(npc.Address)
                end
            end

        end

        if PlayerGui.clockGui.clockFrame.clockLabel.Text == "08:00" then
            customer_list = {}
        end

        task.wait(0.1)
    end
end)
