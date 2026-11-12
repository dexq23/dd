-- Place KaitanBase.lua in ReplicatedStorage as a ModuleScript named KaitanBase.
-- Place this example in StarterPlayerScripts as a LocalScript.
local Players = game:GetService("Players")
local Base = require(game:GetService("ReplicatedStorage"):WaitForChild("KaitanBase"))
local ui = Base.new({
    Title = "ZIIQ · KAITAN",
    Logo = "134013054250379",
})
ui:AddStat("Level", "LEVEL", "—")
ui:AddStat("Money", "BALANCE", "—")
ui:AddDetail("Status", "STATUS", "Running")
ui:AddDetail("Players", "PLAYERS", #Players:GetPlayers())
-- Read your own game's data here. The base library never invents game stats.
local player = Players.LocalPlayer
local moneyConnection
local function bindMoney(value)
    if moneyConnection then moneyConnection:Disconnect();moneyConnection=nil end
    if value and (value:IsA("NumberValue") or value:IsA("IntValue") or value:IsA("StringValue")) then
        ui:Update("Money", value.Value)
        moneyConnection=value:GetPropertyChangedSignal("Value"):Connect(function() ui:Update("Money",value.Value) end)
    else ui:Update("Money", "—") end
end
local stats=player:FindFirstChild("leaderstats")
local added,removed
if stats then
    bindMoney(stats:FindFirstChild("Money"))
    added=stats.ChildAdded:Connect(function(v) if v.Name=="Money" then bindMoney(v) end end)
    removed=stats.ChildRemoved:Connect(function(v) if v.Name=="Money" then bindMoney(nil) end end)
end
ui.Gui.Destroying:Connect(function()
    if moneyConnection then moneyConnection:Disconnect() end
    if added then added:Disconnect() end
    if removed then removed:Disconnect() end
end)
-- Other calls:
-- ui:AddStat("Gems", "GEMS", 250)
-- ui:Update("Gems", 500)
-- ui:Remove("Gems")
-- ui:Clear()
-- ui:SetUsername("Your name")
-- ui:SetVisible(false)
-- ui:Toggle()
-- ui:Destroy()
