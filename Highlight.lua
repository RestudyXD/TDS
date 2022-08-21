local highlightLib = {
	Enabled = false,
	FillColor = Color3.fromRGB(200, 90, 255),
	OutlineColor = Color3.fromRGB(255, 119, 215),
	FillTransparency = 0.65,
	OutlineTransparency = 0,
	DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
}

local highlightsFolder = Instance.new("Folder")
highlightsFolder.Name = "Rendered Highlights"
local folderLocation
if hookfunction then
	folderLocation = game:GetService("CoreGui")
else
	folderLocation = workspace
end
local alreadyLoaded = folderLocation:FindFirstChild("Rendered Highlights")
if alreadyLoaded then
    alreadyLoaded:Destroy()
end

highlightsFolder.Parent = folderLocation
local renderedTargets = {}

function highlightLib:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for i,v in pairs(self.Objects) do
            if v.Type == "Box" then --fov circle etc
                if v.Temporary then
                    v:Remove()
                else
                    for i,v in pairs(v.Components) do
                        v.Visible = false
                    end
                end
            end
        end
    end
end

function highlightLib:addEsp(targetModel:Model)
	if table.find(renderedTargets,targetModel) then--preventing duplicates, this is a way to fix my psx script lol 
	    return
    end
	local highlightSettings = self.Settings--literally the only time I have used self
	local newHighlight = Instance.new("Highlight")
	newHighlight.Adornee = targetModel
	for i,v in next, highlightSettings do
		newHighlight[i] = v
	end
	newHighlight.Parent = highlightsFolder
	table.insert(renderedTargets,targetModel)
	
	local currentConnections = {}
	currentConnections[#currentConnections+1] = targetModel.AncestryChanged:Connect(function()
		if not targetModel or targetModel.Parent == nil then
			newHighlight:Destroy()
			for i,v in ipairs(currentConnections) do
				v:Disconnect()
			end
			currentConnections = nil
			newHighlight:Destroy()
			table.remove(renderedTargets,table.find(renderedTargets,targetModel))
		end
	end)
end
function highlightLib:loadSettings(Settings)
	self.Settings = Settings
	for i,Highlight in ipairs(highlightsFolder:GetChildren()) do
		for Name,Value in next, self.Settings do
			Highlight[Name] = Value
		end
	end
end

return highlightLib
