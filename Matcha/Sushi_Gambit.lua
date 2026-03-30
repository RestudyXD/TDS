local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local GameData = ReplicatedStorage:WaitForChild("GameData")
local PlayerStats = LocalPlayer:WaitForChild("PlayerStats")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


function get_offsets()
    local url = "https://imtheo.lol/Offsets/OffsetsHex.json"
    local response = game:HttpGet(url)
    return HttpService:JSONDecode(response)
end

local ScreenGuiEnabled = get_offsets()["Offsets"]["GuiObject"]["ScreenGui_Enabled"]
local HoldDuration = get_offsets()["Offsets"]["ProximityPrompt"]["HoldDuration"]

UI.AddTab("Sushi Gambit", function(tab)
    local MainSec = tab:Section("Main", "Left")

    MainSec:Toggle('auto_cooking', 'Auto Cooking', function(value)
        notify("Auto Cooking: " .. tostring(value), "", 3)
    end)

    MainSec:Toggle('auto_washing', 'Auto DishWashing', function(value)
        notify("Auto DishWashing: " .. tostring(value), "", 3)
    end)

    MainSec:Toggle('auto_chloroform_spys', 'Auto Chloroform Spys', function(value)
        notify("Auto Chloroform Spys: " .. tostring(value), "", 3)
    end)


    MainSec:Spacing()
    MainSec:Text("Player")
    MainSec:Spacing()

    MainSec:Toggle('inf_stamina', 'Infinite Stamina', function(value)
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

    MainSec:SliderInt('player_walkspeed', 'Walk Speed', 12, 20, 1, function(value)
        PlayerStats.WalkSpeed.Value = value
    end)

    MainSec:Spacing()
    MainSec:Text("Accessories")
    MainSec:Tip("Spoofing accessories. It will not showing until you own it. But you will get the boost")
    MainSec:Spacing()

    local Hat = {
        "BCHardHat",
        "Pager",
        "ChefHat",
        "RobloxVisor",
        "Pencil",
        "HeadLeaves"
    }

    MainSec:Combo("acc_slot1", "Slot1", Hat, 0, function(idx, text)
        LocalPlayer.Accessories.HatSlots["1"].Value = text
        notify("Accessory slot 1 changed to: " .. text, "", 3)
    end)

    MainSec:Combo("acc_slot2", "Slot2", Hat, 0, function(idx, text)
        LocalPlayer.Accessories.HatSlots["2"].Value = text
        notify("Accessory slot 2 changed to: " .. text, "", 3)
    end)

    MainSec:Combo("acc_slot3", "Slot3", Hat, 0, function(idx, text)
        LocalPlayer.Accessories.HatSlots["3"].Value = text
        notify("Accessory slot 3 changed to: " .. text, "", 3)
    end)

    MainSec:Combo("acc_slot4", "Slot4", Hat, 0, function(idx, text)
        LocalPlayer.Accessories.HatSlots["4"].Value = text
        notify("Accessory slot 4 changed to: " .. text, "", 3)
    end)


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

    CookingSec:Toggle('instant_seatcustomer', 'Seat Customer', function(value)
        notify("Instant Seat Customer: " .. tostring(value), "", 3)
    end)
    CookingSec:Spacing()

    CookingSec:Button('Computer', function(value)
        local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
        memory_write("float", computer + HoldDuration, 0)
    end)

    CookingSec:Button('Freezer', function(value)
        local freezer = game.Workspace.RestaurantArea.restaurant.FreezerDoor.PromptHitbox.ProximityPrompt.Address
        memory_write("float", freezer + HoldDuration, 0)
    end)

    CookingSec:Button('Toolbin', function(value)
        local toolbin = game.Workspace.Toolbin.PromptHitbox.ProximityPrompt.Address
        memory_write("float", toolbin + HoldDuration, 0)
    end)

    CookingSec:Spacing()
    CookingSec:Text("Version: 1.0.1\nDiscord: patreon\nchangelog:\n[+] player walkspeed\n[+] instant seat customer\n[+] some instant proximityprompt\n[+] spoof accessories\n[+] Hat limit set to 4")
end)

spawn(function()
    PlayerStats.HatLimit.Value = 4
    while true do
        if not isrbxactive() then return end

        if UI.GetValue("auto_cooking") then
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

        if UI.GetValue("auto_washing") then
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

        if UI.GetValue("auto_chloroform_spys") then
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

        if UI.GetValue("instant_seatcustomer") then
            local npcs = game.Workspace.NpcDestination.SpawnedNPCs
            for _, v in ipairs(npcs:GetChildren()) do
                if v:FindFirstChild("Torso") and v.Torso:FindFirstChild("WaitProximityPrompt") then
                    local prompt = v.Torso.WaitProximityPrompt
                    if prompt and prompt.Address then
                        print('Instant seating for NPC: ' .. v.Name)
                        memory_write("float", prompt.Address + HoldDuration, 0)
                    end
                end
            end
        end
        task.wait(.01)
    end
end)
