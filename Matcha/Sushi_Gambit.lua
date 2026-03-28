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

UI.AddTab("Sushi Gambit", function(tab)
    local MainSec = tab:Section("Main", "Left")

    MainSec:Toggle('auto_cooking', 'Auto Cooking', function(value)
        notify("Auto Cooking: " .. tostring(value), "", 3)
    end)

    MainSec:Toggle('auto_washing', 'Auto Washing', function(value)
        notify("Auto Washing: " .. tostring(value), "", 3)
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
end)

spawn(function()
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
                    print('hit!')
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

        task.wait(.01)
    end
end)
