local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local GameData = ReplicatedStorage:WaitForChild("GameData")
local PlayerStats = LocalPlayer:WaitForChild("PlayerStats")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    Auto = {
        Cooking = {
            Enabled = false,
            delay = 0
        },
        Washing = {
            Enabled = false,
            delay = 0
        },
        ChloroformSpys = {
            Enabled = false,
            delay = 0
        }
    },

    Cheat = {
        Spoof = {
            Greenbar = {
                Enabled = false
            },
            SpongeEffectiveness = {
                Enabled = false
            },
        },

        Instant = {
            CleanDish = {
                Enabled = false
            },
            SeatCustomer = {
                Enabled = true
            }
        }
    },

    Notify = {
        DineAndDash = {
            Enabled = false
        },
        AdminJoin = {
            Enabled = false
        }
    },

    Npcs = {

    }
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
    },
    Critic = {
        Enabled = false,
        Color = Color3.new(255, 252, 0)
    },
    HealthInspector = {
        Enabled = false,
        Color = Color3.new(1, 0, 0)
    },
    Windows = {
        Enabled = false
    },
    Labels = {
        day = false,
        waitinginline = false,
        companymoney = false,
        electricitybill = false,
        vegstock = false,
        fishstock = false,
        humanfleshstock = false,
        ricestock = false,
    }
}

local Lib = {}
Lib.__index = Lib

function Lib.new(titleText, width, height, cornerRadius)
    local self = setmetatable({}, Lib)

    local radius = cornerRadius or 10
    local w = width or 650
    local h = height or 400
    local startX = 100
    local startY = 100
    local bgColor = Color3.fromRGB(15, 15, 15)

    self.Elements = {}
    self.Labels = {}
    self.Radius = radius
    self.Size = Vector2.new(w, h)
    self.Position = Vector2.new(startX, startY)
    self.InitialSize = Vector2.new(w, h)

    local function createCircle(pos)
        local c = Drawing.new("Circle")
        c.Position = pos
        c.Radius = radius
        c.Color = bgColor
        c.Filled = true
        c.Visible = false
        c.NumSides = 64
        c.Thickness = 0
        table.insert(self.Elements, c)
        return c
    end

    local function createRect(pos, size)
        local r = Drawing.new("Square")
        r.Position = pos
        r.Size = size
        r.Color = bgColor
        r.Filled = true
        r.Visible = false
        r.Thickness = 0
        table.insert(self.Elements, r)
        return r
    end

    self.TopLeft = createCircle(Vector2.new(startX + radius, startY + radius))
    self.TopRight = createCircle(Vector2.new(startX + w - radius, startY + radius))
    self.BottomLeft = createCircle(Vector2.new(startX + radius, startY + h - radius))
    self.BottomRight = createCircle(Vector2.new(startX + w - radius, startY + h - radius))

    self.VerticalFill = createRect(Vector2.new(startX + radius, startY), Vector2.new(w - 2 * radius, h))
    self.HorizontalFill = createRect(Vector2.new(startX, startY + radius), Vector2.new(w, h - 2 * radius))

    local title = Drawing.new("Text")
    title.Text = titleText
    title.Size = 12
    title.Position = Vector2.new(startX + 12, startY + 15)
    title.Color = Color3.fromRGB(255, 0, 0)
    title.Visible = false
    title.Center = false
    title.Outline = true
    self.Title = title
    table.insert(self.Elements, title)

    local mouse = Players.LocalPlayer:GetMouse()
    local dragging = false
    local dragOffset = Vector2.new(0, 0)

    RunService.RenderStepped:Connect(function()
        local mx, my = mouse.X, mouse.Y
        local px, py = self.Position.X, self.Position.Y
        local sw, sh = self.Size.X, self.Size.Y

        if ismouse1pressed() then
            if not dragging then
                if mx >= px and mx <= px + sw and my >= py and my <= py + sh then
                    dragging = true
                    dragOffset = Vector2.new(mx - px, my - py)
                end
            end
        else
            dragging = false
        end

        if dragging then
            self:Edit(Vector2.new(mx - dragOffset.X, my - dragOffset.Y))
        end
    end)

    return self
end

function Lib:Show(isVisible)
    for _, element in ipairs(self.Elements) do
        element.Visible = isVisible
    end
    for _, entry in ipairs(self.Labels) do
        entry.drawing.Visible = isVisible
    end
end

function Lib:Edit(newPosition, newSize)
    local pos = newPosition or self.Position
    local size = newSize or self.Size
    self.Position = pos
    self.Size = size

    local x, y = pos.X, pos.Y
    local w, h = size.X, size.Y
    local r = self.Radius

    self.TopLeft.Position = Vector2.new(x + r, y + r)
    self.TopRight.Position = Vector2.new(x + w - r, y + r)
    self.BottomLeft.Position = Vector2.new(x + r, y + h - r)
    self.BottomRight.Position = Vector2.new(x + w - r, y + h - r)

    self.VerticalFill.Position = Vector2.new(x + r, y)
    self.VerticalFill.Size = Vector2.new(w - 2 * r, h)

    self.HorizontalFill.Position = Vector2.new(x, y + r)
    self.HorizontalFill.Size = Vector2.new(w, h - 2 * r)

    self.Title.Position = Vector2.new(x + 12, y + 15)

    for _, entry in ipairs(self.Labels) do
        entry.drawing.Position = pos + entry.relPos
    end
end

function Lib:Delete()
    for _, element in ipairs(self.Elements) do
        element:Remove()
    end
    for _, entry in ipairs(self.Labels) do
        entry.drawing:Remove()
    end
end

local LABEL_SIZE = 12
local LABEL_X = 12
local LABEL_START_Y = 32
local LABEL_STEP = 18
local LABEL_BOTTOM_PAD = 15

function Lib:_refreshLabelPositions()
    for i, entry in ipairs(self.Labels) do
        local relPos = Vector2.new(LABEL_X, LABEL_START_Y + (i - 1) * LABEL_STEP)
        entry.relPos = relPos
        entry.drawing.Position = self.Position + relPos
    end

    local count = #self.Labels
    local neededH = LABEL_START_Y + count * LABEL_STEP + LABEL_BOTTOM_PAD
    local finalH = math.max(neededH, self.InitialSize.Y)
    self:Edit(self.Position, Vector2.new(self.Size.X, finalH))
end

function Lib:AddLabel(text, color)
    local lib = self

    local d = Drawing.new("Text")
    d.Text = text or ""
    d.Size = LABEL_SIZE
    d.Color = color or Color3.fromRGB(255, 255, 255)
    d.Visible = true
    d.Center = false
    d.Outline = true

    local entry = { drawing = d, relPos = Vector2.new(0, 0)}
    table.insert(lib.Labels, entry)
    lib:_refreshLabelPositions()

    local handle = {}

    function handle:SetText(newText)
        d.Text = newText
    end

    function handle:Edit(newColor)
        if newColor then d.Color = newColor end
    end

    function handle:Delete()
        d:Remove()
        for i, e in ipairs(lib.Labels) do
            if e == entry then
                table.remove(lib.Labels, i)
                break
            end
        end
        lib:_refreshLabelPositions()
    end

    return handle
end

local dayLabel = nil
local waitinginline = nil
local companyMoneyLabel = nil
local electricityBillLabel = nil
local vegLabel = nil
local fishLabel = nil
local HumanFlesh = nil
local Rice = nil

local Windows = Lib.new("Sushi Gambit", 150, 55)
Windows:Show(false)

function get_offsets()
    local url = "https://imtheo.lol/Offsets/OffsetsHex.json"
    local response = game:HttpGet(url)
    return HttpService:JSONDecode(response)
end

local ScreenGuiEnabled = get_offsets()["Offsets"]["GuiObject"]["ScreenGui_Enabled"]
local HoldDuration = get_offsets()["Offsets"]["ProximityPrompt"]["HoldDuration"]
local PromptEnabled = get_offsets()["Offsets"]["ProximityPrompt"]["Enabled"]

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

UI.AddTab("Sushi Gambit", function(tab)
    local MainSec = tab:Section("Main", "Left", { "Auto", "Cheat", "Prompt" } )

    if MainSec.page == 0 then
        MainSec:Toggle('auto_cooking', 'Auto Cooking', function(value)
            notify("Auto Cooking: " .. tostring(value), "", 3)
            SETTINGS.Auto.Cooking.Enabled = value
        end)

        MainSec:Toggle('auto_washing', 'Auto DishWashing', function(value)
            notify("Auto DishWashing: " .. tostring(value), "", 3)
            SETTINGS.Auto.Washing.Enabled = value
        end)
        MainSec:Tip("Don't Afk in the sink too long!!!")

        MainSec:Toggle('auto_chloroform_spys', 'Auto Chloroform Spys', function(value)
            notify("Auto Chloroform Spys: " .. tostring(value), "", 3)
            SETTINGS.Auto.ChloroformSpys.Enabled = value
        end)
    elseif MainSec.page == 1 then
        MainSec:Toggle('spoof_greenbar', 'Spoof Greenbar', function(value)
            notify("Spoof Greenbar: " .. tostring(value), "", 3)
            SETTINGS.Cheat.Spoof.Greenbar.Enabled = value
        end)

        MainSec:Toggle('instant_clean_dish', 'Fast Clean Dish', function(value)
            notify("Fast Clean Dish: " .. tostring(value), "", 3)
            SETTINGS.Cheat.Instant.CleanDish.Enabled = value
        end)

        MainSec:Toggle('spoof_sponge_effectiveness', 'Instant Sponge Effect', function(value)
            notify("Spoof Sponge Effectiveness: " .. tostring(value), "", 3)
            SETTINGS.Cheat.Spoof.SpongeEffectiveness = value
        end)
    elseif MainSec.page == 2 then

        MainSec:Toggle('always_computer', 'Use computer during blackout', function(value)
            spawn(function()
                while true do
                    local computer = game.Workspace.RestaurantArea.restaurant.Table.computer.ProximityPrompt.Address
                    memory_write("byte", computer + PromptEnabled, 1)
                    task.wait(.1)
                end
            end)
        end)

        local promptc = MainSec:Combo('prompt_type', 'Prompt Type', { 'ALL', 'Computer', 'Conveyor', 'Freezer', 'Toolbin', 'SeatingStation' }, 0, function(idx, text)
            notify("Click button to set instant prompt: " .. text, "", 3)
        end)

        MainSec:Button('Set instant prompt', function()
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
    end

    local PlayerTab = tab:Section("Player", "Left", { "Player", "Notify" } )

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
            SETTINGS.NotifyAdminJoin = value
        end)
    end

    local NpcTab = tab:Section("Npc", "Left", { "Npc", "" } )

    if NpcTab.page == 0 then
        NpcTab:Toggle('instant_seatcustomer', 'Instant Seat Customer', function(value)
            notify("Instant Seat Customer: " .. tostring(value), "", 3)
            SETTINGS.Cheat.Instant.SeatCustomer.Enabled = value
        end)

        UI.SetValue('instant_seatcustomer', SETTINGS.Cheat.Instant.SeatCustomer.Enabled)

        NpcTab:Spacing()
        NpcTab:Text("Visuals")
        NpcTab:Spacing()

        NpcTab:Toggle('show_dasher', 'Dasher', function(value)
            if not SETTINGS.Cheat.Instant.SeatCustomer.Enabled then
                UI.SetValue('instant_seatcustomer', true)
                SETTINGS.Cheat.Instant.SeatCustomer.Enabled = value
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

        NpcTab:Toggle('show_critic', 'Critic', function(value)
            notify("Show Critic: " .. tostring(value), "", 3)
            ESP_SETTINGS.Critic.Enabled = value
        end)

        NpcTab:ColorPicker("critic_color", 255, 252, 0, 1, function(color, alpha)
            ESP_SETTINGS.Critic.Color = Color3.new(color.R, color.G, color.B)
        end)

        NpcTab:Toggle('show_health_inspector', 'Health Inspector', function(value)
            notify("Show Health Inspector: " .. tostring(value), "", 3)
            ESP_SETTINGS.HealthInspector.Enabled = value
        end)

        NpcTab:ColorPicker("health_inspector_color", 1, 0, 0, 1, function(color, alpha)
            ESP_SETTINGS.HealthInspector.Color = Color3.new(color.R, color.G, color.B)
        end)

    elseif NpcTab.page == 1 then
    end

    local CookingSec = tab:Section("Cooking", "Right", { "Cooking", "" } )

    if CookingSec.page == 0 then
        CookingSec:SliderFloat('cooking_speed', 'Cooking Speed', 1.0, 5.0, 1.0, '%.1f', function(value)
            PlayerStats.CookingSpeedMultiplier.Value = value
        end)

        CookingSec:SliderInt('dupe_sushi_chance', 'Dupe Sushi Chance (%)', 0, 100, 0, function(value)
            PlayerStats.SushiDuplicationChance.Value = value
        end)

        CookingSec:SliderInt('conveyor_speed', 'Conveyor Speed', 1, 10, 1, function(value)
            GameData.ConveyorSpeedValue.Value = value
        end)
    end

    local WindowSec = tab:Section("Window", "Right")

    WindowSec:Toggle("show_statuswindow", "Enabled", function(value)
        ESP_SETTINGS.Windows.Enabled = value
        if ESP_SETTINGS.Windows.Enabled then
            Windows:Show(true)
        else
            Windows:Show(false)
        end
    end)

    WindowSec:Toggle("show_daycounter", "Day Counter", function(value)
        ESP_SETTINGS.Labels.day = value
        if value then
            dayLabel = Windows:AddLabel("Day: " .. tostring(GameData.CurrentDay.Value))
        else
            dayLabel:Delete()
        end
    end)

    WindowSec:Toggle("show_waitinginline", "WaitingInLine Amount", function(value)
        ESP_SETTINGS.Labels.waitinginline = value
        if UI.GetValue("instant_seatcustomer") == false then
            UI.SetValue("instant_seatcustomer", true)
            SETTINGS.Cheat.Instant.SeatCustomer.Enabled = true
        end
        if value then
            waitinginline = Windows:AddLabel("WaitingInLine: 0")
        else
            waitinginline:Delete()
        end
    end)

    WindowSec:Toggle("show_company_money", "Company Money", function(value)
        ESP_SETTINGS.Labels.companymoney = value
        if value then
            companyMoneyLabel = Windows:AddLabel("Company Money: " .. string.format("%.2f", GameData.CompanyMoney.Value))
        else
            companyMoneyLabel:Delete()
        end
    end)

    WindowSec:Toggle("show_vegstock", "Vegetables Stock", function(value)
        ESP_SETTINGS.Labels.vegstock = value
        if value then
            vegLabel = Windows:AddLabel("Vegetables: " .. tostring(GameData.Ingredients.IngredientsStorage.Vegetables.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.Vegetables.MaxStock.Value))
        else
            vegLabel:Delete()
        end
    end)

    WindowSec:Toggle("show_fishstock", "Fish Stock", function(value)
        ESP_SETTINGS.Labels.fishstock = value
        if value then
            fishLabel = Windows:AddLabel("Fish: " .. tostring(GameData.Ingredients.IngredientsStorage.AssortedFish.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.AssortedFish.MaxStock.Value))
        else
            fishLabel:Delete()
        end
    end)

    WindowSec:Toggle("show_humanfleshstock", "Human Flesh Stock", function(value)
        ESP_SETTINGS.Labels.humanfleshstock = value
        if value then
            HumanFlesh = Windows:AddLabel("Human Flesh: " .. tostring(GameData.Ingredients.IngredientsStorage.HumanFlesh.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.HumanFlesh.MaxStock.Value))
        else
            HumanFlesh:Delete()
        end
    end)

    WindowSec:Toggle("show_ricestock", "Rice Stock", function(value)
        ESP_SETTINGS.Labels.ricestock = value
        if value then
            Rice = Windows:AddLabel("Rice: " .. tostring(GameData.Ingredients.IngredientsStorage.Rice.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.Rice.MaxStock.Value))
        else
            Rice:Delete()
        end

    end)

    local InfoSec = tab:Section("Info", "Right")

    InfoSec:Text(
    "Version: 1.0.8\n" ..
    "Discord: patreon\n" ..
    "changelog:\n" ..
    "[+] Show Critic\n" ..
    "[+] Show Health Inspector\n" ..
    "[~] Fixed Auto Dishwashing not working\n"
    )
end)

SETTINGS.Auto.Cooking.Enabled = UI.GetValue("auto_cooking")
SETTINGS.Auto.Washing.Enabled = UI.GetValue("auto_washing")
SETTINGS.Auto.ChloroformSpys.Enabled = UI.GetValue("auto_chloroform_spys")

SETTINGS.Cheat.Instant.SeatCustomer.Enabled = UI.GetValue("instant_seatcustomer")
SETTINGS.Cheat.Instant.CleanDish.Enabled = UI.GetValue("instant_clean_dish")

SETTINGS.Cheat.Spoof.Greenbar.Enabled = UI.GetValue("spoof_greenbar")
SETTINGS.Cheat.Spoof.SpongeEffectiveness.Enabled = UI.GetValue("spoof_sponge_effectiveness")

SETTINGS.Notify.DineAndDash.Enabled = UI.GetValue("notify_dineanddash")
SETTINGS.Notify.AdminJoin.Enabled = UI.GetValue("notify_admin_join")

ESP_SETTINGS.Dasher.Enabled = UI.GetValue("show_dasher")
ESP_SETTINGS.Armed.Enabled = UI.GetValue("show_armed")
ESP_SETTINGS.Police.Enabled = UI.GetValue("show_police")
ESP_SETTINGS.Critic.Enabled = UI.GetValue("show_critic")
ESP_SETTINGS.HealthInspector.Enabled = UI.GetValue("show_health_inspector")

ESP_SETTINGS.Windows.Enabled = UI.GetValue("show_statuswindow")
ESP_SETTINGS.Labels.day = UI.GetValue("show_daycounter")
ESP_SETTINGS.Labels.waitinginline = UI.GetValue("show_waitinginline")
ESP_SETTINGS.Labels.companymoney = UI.GetValue("show_company_money")
ESP_SETTINGS.Labels.vegstock = UI.GetValue("show_vegstock")
ESP_SETTINGS.Labels.fishstock = UI.GetValue("show_fishstock")
ESP_SETTINGS.Labels.humanfleshstock = UI.GetValue("show_humanfleshstock")
ESP_SETTINGS.Labels.ricestock = UI.GetValue("show_ricestock")

if ESP_SETTINGS.Windows.Enabled then
    Windows:Show(true)
end

if ESP_SETTINGS.Labels.day then dayLabel = Windows:AddLabel("Day: " .. tostring(GameData.CurrentDay.Value)) end
if ESP_SETTINGS.Labels.waitinginline then waitinginline = Windows:AddLabel("WaitingInLine: 0") end
if ESP_SETTINGS.Labels.companymoney then companyMoneyLabel = Windows:AddLabel("Company Money: " .. string.format("%.2f", GameData.CompanyMoney.Value)) end
if ESP_SETTINGS.Labels.vegstock then vegLabel = Windows:AddLabel("Vegetables: " .. tostring(GameData.Ingredients.IngredientsStorage.Vegetables.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.Vegetables.MaxStock.Value)) end
if ESP_SETTINGS.Labels.fishstock then fishLabel = Windows:AddLabel("Fish: " .. tostring(GameData.Ingredients.IngredientsStorage.AssortedFish.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.AssortedFish.MaxStock.Value)) end
if ESP_SETTINGS.Labels.humanfleshstock then HumanFlesh = Windows:AddLabel("Human Flesh: " .. tostring(GameData.Ingredients.IngredientsStorage.HumanFlesh.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.HumanFlesh.MaxStock.Value)) end
if ESP_SETTINGS.Labels.ricestock then Rice = Windows:AddLabel("Rice: " .. tostring(GameData.Ingredients.IngredientsStorage.Rice.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.Rice.MaxStock.Value)) end

local Admin = {
    ["UserIds"] = { 105479622, 65095440, 1425697210, 126961971, 127528152, 319065798, 2754844524, 125440222, 1783725423 }
}


Players.PlayerAdded:Connect(function(player)
    if table.find(Admin.UserIds, player.UserId) and SETTINGS.Notify.AdminJoin.Enabled then
        notify("Admin Joined: " .. player.Name, "ADMIN ALERT", 8)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.Auto.Cooking.Enabled then
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
    while SETTINGS.Auto.Washing.Enabled do
        if not PlayerGui:FindFirstChild("DishWashingGui") then return end
        if not SETTINGS.Auto.Washing.Enabled then return end
        local dirty = game.Workspace.Kitchen.TheSink.DirtyDishAmount.Value
        if dirty and dirty > 0 then
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
        task.wait(.1)
    end
end)

task.spawn(function()
    while true do
        if SETTINGS.Auto.ChloroformSpys.Enabled then
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
        if SETTINGS.Cheat.Spoof.Greenbar.Enabled then
            PlayerStats.EffectiveCookingLevel.Value = 1000
            PlayerStats.NoIngredientUseChance.Value = 1
        end

        if SETTINGS.Cheat.Instant.CleanDish.Enabled then
            PlayerStats.EffectiveCleaningLevel.Value = 9999
        end

        if SETTINGS.Cheat.Spoof.SpongeEffectiveness.Enabled then
            PlayerStats.SpongeEffectiveness.Value = 9999
        end

        task.wait(.1)
    end
end)

task.spawn(function()
    while true do
        if ESP_SETTINGS.Labels.waitinginline then
            local i = 0
            for _, npc in next, game.Workspace.NpcDestination.SpawnedNPCs:GetChildren() do
                if npc:IsA("Model") and npc:GetAttribute("CurrentState") == "WaitingInLine" then
                    i = i + 1
                end
            end
            waitinginline:SetText("WaitingInLine: " .. i)
        end
        if ESP_SETTINGS.Labels.day then
            dayLabel:SetText("Day: " .. tostring(GameData.CurrentDay.Value))
        end

        if ESP_SETTINGS.Labels.companymoney then
            companyMoneyLabel:SetText("Company Money: " .. string.format("%.2f", GameData.CompanyMoney.Value))
        end

        if ESP_SETTINGS.Labels.vegstock then
            vegLabel:SetText("Vegetables: " .. tostring(GameData.Ingredients.IngredientsStorage.Vegetables.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.Vegetables.MaxStock.Value))
        end

        if ESP_SETTINGS.Labels.fishstock then
            fishLabel:SetText("Fish: " .. tostring(GameData.Ingredients.IngredientsStorage.AssortedFish.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.AssortedFish.MaxStock.Value))
        end

        if ESP_SETTINGS.Labels.humanfleshstock then
            HumanFlesh:SetText("Human Flesh: " .. tostring(GameData.Ingredients.IngredientsStorage.HumanFlesh.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.HumanFlesh.MaxStock.Value))
        end

        if ESP_SETTINGS.Labels.ricestock then
            Rice:SetText("Rice: " .. tostring(GameData.Ingredients.IngredientsStorage.Rice.Stock.Value) .. "/" .. tostring(GameData.Ingredients.IngredientsStorage.Rice.MaxStock.Value))
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
            if SETTINGS.Cheat.Instant.SeatCustomer and npc:GetAttribute("CurrentState") == "WaitingInLine" then
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

            if ESP_SETTINGS.Critic.Enabled and npc:GetAttribute("Critic") == true then

                if not Manager.Entities[npc.Address] then
                    Manager:Add(
                    npc.Address,
                    Entity.new(npc, Drawing.new("Text"), "Critic")
                    )
                else
                    Manager.Entities[npc.Address].Instance = npc
                end
            else
                if Manager.Entities[npc.Address] and Manager.Entities[npc.Address].Type == "Critic" then
                    Manager:Remove(npc.Address)
                end
            end

            if ESP_SETTINGS.HealthInspector.Enabled and npc:GetAttribute("Behavior") == "Inspector" then

                if not Manager.Entities[npc.Address] then
                    Manager:Add(
                    npc.Address,
                    Entity.new(npc, Drawing.new("Text"), "Health Inspector")
                    )
                else
                    Manager.Entities[npc.Address].Instance = npc
                end
            else
                if Manager.Entities[npc.Address] and Manager.Entities[npc.Address].Type == "Health Inspector" then
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

notify('Sushi Gambit loaded!', "", 3)
