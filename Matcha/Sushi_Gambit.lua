local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local GameData = ReplicatedStorage:WaitForChild("GameData")
local PlayerStats = LocalPlayer:WaitForChild("PlayerStats")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local npc_list = {}
local dasher_found_list = {}
local dasher_list = {}
local dasher_instances = {}

local Settings = {
    AutoCooking = false,
    AutoWashing = false,
    AutoChloroformSpys = false,
    InstantSeatCustomer = false,
    ShowDasher = false,
    NotifyDineAndDash = false,
    SpoofGreenbar = false,
    InstantCleanDish = false,
    SpoofSpongeEffectiveness = false,
    NotifyAdminJoin = false
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
    local MainSec = tab:Section("Main", "Left", { "Auto", "Npcs", "Cheat" } )

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
        MainSec:Toggle('instant_seatcustomer', 'Instant Seat Customer', function(value)
            notify("Instant Seat Customer: " .. tostring(value), "", 3)
            Settings.InstantSeatCustomer = value
        end)

        MainSec:Toggle('show_dasher', 'Show Dasher', function(value)
            if not Settings.InstantSeatCustomer then
                UI.SetValue('instant_seatcustomer', true)
            end
            notify("Show Dasher: " .. tostring(value), "", 3)
            Settings.ShowDasher = value
        end)
        MainSec:Tip('turn on Instant Seat Customer to make it work!')
    elseif MainSec.page == 2 then
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
        'JustInForTheMoney',
        'JustInForTheExperience',
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

        -- PlayerTab:Combo('background', 'Career Background', background, 0, function(idx, text)
        --     LocalPlayer.CareerBackground.EquippedCareerBackground.Value = text
        --     notify("Career Background change to: " .. tostring(text), "", 3)
        -- end)

    elseif PlayerTab.page == 1 then
        PlayerTab:Toggle('notify_admin_join', 'Admin Join', function(value)
            notify("Notify Admin Join: " .. tostring(value), "", 3)
            Settings.NotifyAdminJoin = value
        end)
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

    CookingSec:Spacing()
    CookingSec:Text("Instant ProximityPrompt")
    CookingSec:Spacing()


    CookingSec:Spacing()

    CookingSec:Toggle('always_computer', 'Use computer during blackout', function(value)
        spawn(function()
            while true do
                local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
                memory_write("byte", computer + PromptEnabled, 1)
                task.wait(.1)
            end
        end)
    end)

    CookingSec:Button('Computer', function(value)
        spawn(function()
            while true do
                local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
                memory_write("float", computer + HoldDuration, 0)
                task.wait(.1)
            end
        end)
    end)

    CookingSec:Button('Conveyor', function(value)
        local conveyor_keypad = game.Workspace.RestaurantArea.restaurant.mainStuff.conveyors.keypad.PromptPart.ProximityPrompt.Address
        memory_write("float", conveyor_keypad + HoldDuration, 0)
    end)

    CookingSec:Button('Freezer', function(value)
        local freezer = game.Workspace.RestaurantArea.restaurant.FreezerDoor.PromptHitbox.ProximityPrompt.Address
        memory_write("float", freezer + HoldDuration, 0)
    end)

    CookingSec:Button('Toolbin', function(value)
        local toolbin = game.Workspace.Toolbin.PromptHitbox.ProximityPrompt.Address
        memory_write("float", toolbin + HoldDuration, 0)
    end)

    CookingSec:Button('SeatingStation', function(value)
        local SeatingStation = game.Workspace.RestaurantArea.restaurant["the waiter stand thingy"].Stations.SeatingStation.TriggerPart.SeatCustomersPrompt.Address
        memory_write("float", SeatingStation + HoldDuration, 0)
    end)

    CookingSec:Spacing()
    CookingSec:Text(
    "Version: 1.0.5\n" ..
    "Discord: patreon\n" ..
    "changelog:\n" ..
    "[+] Admin join notify\n" 
    -- "[+] Spoof Career Background"
    )
end)

Settings = {
    AutoCooking = UI.GetValue("auto_cooking"),
    AutoWashing = UI.GetValue("auto_washing"),
    AutoChloroformSpys = UI.GetValue("auto_chloroform_spys"),
    InstantSeatCustomer = UI.GetValue("instant_seatcustomer"),
    NotifyDineAndDash = UI.GetValue("notify_dineanddash"),
    SpoofGreenbar = UI.GetValue("spoof_greenbar"),
    InstantCleanDish = UI.GetValue("instant_clean_dish"),
    SpoofSpongeEffectiveness = UI.GetValue("spoof_sponge_effectiveness"),
    ShowDasher = UI.GetValue("show_dasher"),
    NotifyAdminJoin = UI.GetValue("notify_admin_join")
}

local Admin = {
    ["UserIds"] = { 105479622, 65095440, 1425697210, 126961971, 127528152, 319065798, 2754844524, 125440222, 1783725423 }
}

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
        if Settings.AutoWashing then
            if not PlayerGui:FindFirstChild("DishWashingGui") then return end
            local addr = PlayerGui.DishWashingGui.Address
            local Visible = memory_read("byte", addr + ScreenGuiEnabled)
            if Visible == 1 and game.Workspace.Kitchen.TheSink.DirtyDishAmount.Value > 0 then
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

RunService.Heartbeat:Connect(function()
    local folder = game.Workspace.NpcDestination.SpawnedNPCs

    for _, v in pairs(folder:GetChildren()) do
        if Settings.InstantSeatCustomer then
            if v:GetAttribute("CurrentState") == "WaitingInLine" then
                if not npc_list[v.Address] then
                    local torso = v:FindFirstChild("Torso")
                    local prompt = torso and torso:FindFirstChild("WaitProximityPrompt")

                    if prompt and prompt.Address then
                        memory_write("float", prompt.Address + HoldDuration, 0)
                        npc_list[v.Address] = true
                    end
                end
            end
        end

        if Settings.ShowDasher then
            if npc_list[v.Address] and not dasher_found_list[v.Address] then
                local torso = v:FindFirstChild("Torso")
                local prompt = torso and torso:FindFirstChild("CatchDasherPrompt")
                if prompt then
                    print("Find dasher npc: " .. v.Address)
                    memory_write("float", prompt.Address + HoldDuration, 0)
                    dasher_found_list[v.Address] = true

                    npc_list[v.Address] = nil

                    local Text = Drawing.new("Text")
                    Text.Text = "Dasher"
                    Text.Color = Color3.new(1, 0, 0)
                    Text.Center = true
                    Text.Outline = true
                    Text.Visible = false

                    dasher_list[v.Address] = Text
                    dasher_instances[v.Address] = v
                end
            end
        end
    end

    if Settings.ShowDasher then
        for address, textObj in pairs(dasher_list) do
            local npc = dasher_instances[address]
            local is_alive = false
            local head = nil

            if npc and npc.Parent then
                local torso = npc:FindFirstChild("Torso")
                if torso then
                    local prompt = torso:FindFirstChild("CatchDasherPrompt")
                    if prompt then
                        is_alive = true
                        head = npc:FindFirstChild("Head")
                    end
                end
            end

            if is_alive == false then
                textObj:Remove()
                dasher_list[address] = nil
                dasher_found_list[address] = nil
                dasher_instances[address] = nil
            else
                if head then
                    local pos, onScreen = WorldToScreen(head.Position + Vector3.new(0, 1.5, 0))
                    if onScreen then
                        textObj.Position = pos
                        textObj.Visible = true
                    else
                        textObj.Visible = false
                    end
                end
            end
        end
    else
        for address, textObj in pairs(dasher_list) do
            textObj:Remove()
        end
        dasher_list = {}
        dasher_found_list = {}
        dasher_instances = {}
    end
end)

Players.PlayerAdded:Connect(function(player)
    if table.find(Admin.UserIds, player.UserId) and Settings.NotifyAdminJoin then
        notify("Admin Joined: " .. player.Name, 8)
    end
end)
