-- ZIIQ Kaitan Base UI | client-side ModuleScript
local Library = {}
function Library.new(options)
options = options or {}
local CONFIG = {Logo=tostring(options.Logo or '134013054250379'),Title=options.Title or 'ZIIQ · KAITAN',ToggleKey=options.ToggleKey or Enum.KeyCode.RightControl}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
assert(player, "Kaitan must run on the client (LocalScript)")
local playerGui = player:WaitForChild("PlayerGui")
local guiName=options.Name or "ZIIQKaitanBase"
local previous = playerGui:FindFirstChild(guiName)
if previous then previous:Destroy() end
local connections = {}
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function make(class, props, parent)
    local object = Instance.new(class)
    for key, value in pairs(props) do object[key] = value end
    object.Parent = parent
    return object
end
local function gray(value) return Color3.fromRGB(value,value,value) end
local function frame(parent, x,y,w,h,color)
    return make("Frame",{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=gray(color or 20),BorderSizePixel=0},parent)
end
local function rounded(object, radius)
    -- Square edges throughout the HUD.
    make("UIStroke",{Color=gray(46),Thickness=1},object)
end
local function text(parent, value,x,y,w,h,size,color,center)
    return make("TextLabel",{Text=tostring(value),Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=size or 14,TextColor3=gray(color or 230),TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},parent)
end
local gui = make("ScreenGui",{Name=guiName,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=20},playerGui)
local panel = frame(gui,0,0,780,536,16)
panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5)
rounded(panel,16)
local scale = make("UIScale",{},panel)
local function resize()
    local camera=workspace.CurrentCamera
    if camera then scale.Scale=math.clamp(math.min((camera.ViewportSize.X-28)/780,(camera.ViewportSize.Y-90)/536),.2,1) end
end
-- The small toggle remains accessible on touch devices when the panel is hidden.
local toggle=make("TextButton",{Name="ToggleKaitan",Text="K / HUD",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=gray(220),BackgroundColor3=gray(24),Size=UDim2.fromOffset(82,30),Position=UDim2.new(1,-96,0,12),BorderSizePixel=0},gui)
rounded(toggle,7)
toggle.Visible=options.ShowToggle ~= false
connect(toggle.Activated,function() panel.Visible=not panel.Visible end)
connect(UIS.InputBegan,function(input,processed)
    if not processed and input.KeyCode==CONFIG.ToggleKey then panel.Visible=not panel.Visible end
end)
local logo=make("ImageLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(338,33),Size=UDim2.fromOffset(104,104),ScaleType=Enum.ScaleType.Fit},panel)
if CONFIG.Logo~="" then
    logo.Image=CONFIG.Logo:match("^%d+$") and "rbxthumb://type=Asset&id="..CONFIG.Logo.."&w=420&h=420" or CONFIG.Logo
else
    text(panel,"Z / X",300,48,180,70,42,240,true)
end
text(panel,CONFIG.Title,240,139,300,20,13,210,true)
local displayName=text(panel,options.Username or player.DisplayName,130,163,520,36,28,245,true)
local timer=text(panel,"SESSION TIME   00:00:00",200,207,380,22,14,205,true)
local TweenService=game:GetService("TweenService")
-- Fixed viewport: fit every card into the available space without scrolling.
local scroll=make("Frame",{Name="Information",Position=UDim2.fromOffset(25,248),Size=UDim2.fromOffset(730,264),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true},panel)
local content=make("Frame",{Name="Cards",Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(724,258),BackgroundTransparency=1,BorderSizePixel=0},scroll)
local fitScale=make("UIScale",{Scale=1},content)
local headings={Stat=text(content,options.StatHeading or "OVERVIEW",0,0,700,22,12,190),Detail=text(content,options.DetailHeading or "SESSION DETAILS",0,0,700,22,12,190)}
local UI={Items={},Order={},Destroyed=false}
local tweens={}
local scaleTween
local function layout()
    if UI.Destroyed then return end
    local groups={Stat={},Detail={}}
    for _,id in ipairs(UI.Order) do
        local item=UI.Items[id]
        if item then table.insert(groups[item.Kind],item) end
    end
    -- Add columns as the item count grows; uniformly scale the complete grid
    -- only when required. This preserves left alignment and readable proportions.
    local function heightFor(columns)
        local h=0
        for _,kind in ipairs({"Stat","Detail"}) do
            local count=#groups[kind]
            if count>0 then
                local cols=kind=="Stat" and columns or math.max(2,math.floor(columns/2))
                h=h+26+math.ceil(count/cols)*((kind=="Stat" and 76 or 52)+8)+8
            end
        end
        return math.max(1,h-8)
    end
    local columns=4
    local baseWidth=724
    local best=math.min(1,258/heightFor(columns))
    for candidate=5,math.max(4,math.ceil(math.sqrt(#UI.Order*2))+4) do
        local width=candidate*176+(candidate-1)*8
        local score=math.min(1,724/width,258/heightFor(candidate))
        if score>best then best=score;columns=candidate;baseWidth=width end
    end
    local y=0
    for _,kind in ipairs({"Stat","Detail"}) do
        local list=groups[kind]
        headings[kind].Visible=#list>0
        if #list>0 then
            headings[kind].Position=UDim2.fromOffset(0,y)
            headings[kind].Size=UDim2.fromOffset(baseWidth,20)
            y=y+26
            local cols=kind=="Stat" and columns or math.max(2,math.floor(columns/2))
            local width=(baseWidth-8*(cols-1))/cols
            local height=kind=="Stat" and 76 or 52
            for index,item in ipairs(list) do
                if tweens[item.Frame] then tweens[item.Frame]:Cancel() end
                local position=UDim2.fromOffset(((index-1)%cols)*(width+8),y+math.floor((index-1)/cols)*(height+8))
                local animation=TweenService:Create(item.Frame,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=position,Size=UDim2.fromOffset(width,height)})
                tweens[item.Frame]=animation
                animation:Play()
            end
            y=y+math.ceil(#list/cols)*(height+8)+8
        end
    end
    content.Size=UDim2.fromOffset(baseWidth,math.max(1,y-8))
    if scaleTween then scaleTween:Cancel() end
    scaleTween=TweenService:Create(fitScale,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=best})
    scaleTween:Play()
end
function UI:Add(id,title,value,kind)
    assert(not self.Destroyed,"HUD was destroyed")
    assert(type(id)=="string" and id~="","Use a non-empty string ID")
    kind=kind=="Detail" and "Detail" or "Stat"
    local existing=self.Items[id]
    if existing then
        if existing.Kind==kind then existing.Title.Text=tostring(title);self:Update(id,value);return existing end
        self:Remove(id)
    end
    local card=frame(content,0,0,170,kind=="Stat" and 82 or 58,kind=="Stat" and 24 or 20)
    card.Name=id
    card.ClipsDescendants=true
    rounded(card)
    local caption=text(card,title,14,9,140,18,12,185)
    caption.Size=UDim2.new(1,-28,0,18)
    local label=text(card,value==nil and "—" or value,14,kind=="Stat" and 32 or 26,140,kind=="Stat" and 32 or 22,kind=="Stat" and 26 or 15,240)
    label.Size=UDim2.new(1,-28,0,kind=="Stat" and 32 or 22)
    local item={Frame=card,Title=caption,Value=label,Kind=kind}
    self.Items[id]=item
    table.insert(self.Order,id)
    layout()
    return item
end
function UI:AddStat(id,title,value) return self:Add(id,title,value,"Stat") end
function UI:AddDetail(id,title,value) return self:Add(id,title,value,"Detail") end
function UI:Update(id,value)
    if self.Destroyed then return end
    local item=self.Items[id]
    if item then item.Value.Text=tostring(value==nil and "—" or value) end
end
function UI:Remove(id)
    if self.Destroyed then return end
    local item=self.Items[id]
    if not item then return end
    if tweens[item.Frame] then tweens[item.Frame]:Cancel();tweens[item.Frame]=nil end
    item.Frame:Destroy()
    self.Items[id]=nil
    local index=table.find(self.Order,id)
    if index then table.remove(self.Order,index) end
    layout()
end
function UI:Clear()
    for _,id in ipairs(table.clone(self.Order)) do self:Remove(id) end
end
function UI:Destroy() if not self.Destroyed then self.Destroyed=true;gui:Destroy() end end
local started=os.clock()
local elapsed=0
connect(RunService.Heartbeat,function(dt)
    elapsed=elapsed+dt
    if elapsed<.5 then return end
    elapsed=0
    resize()
    local seconds=math.floor(os.clock()-started)
    timer.Text=string.format("SESSION TIME   %02d:%02d:%02d",math.floor(seconds/3600),math.floor(seconds/60)%60,seconds%60)


end)
connect(player:GetPropertyChangedSignal("DisplayName"),function() if not options.Username then displayName.Text=player.DisplayName end end)
-- Drag from the header; coordinates are screen pixels so scaling stays correct.
local dragInput,dragStart,panelStart
local function clampPosition()
    if not panel.Visible then return end
    local camera=workspace.CurrentCamera
    if not camera then return end
    local view=camera.ViewportSize
    local half=panel.AbsoluteSize/2
    local center=panel.AbsolutePosition+half
    local x=math.clamp(center.X,math.min(half.X,view.X/2),math.max(view.X-half.X,view.X/2))
    local y=math.clamp(center.Y,math.min(half.Y,view.Y/2),math.max(view.Y-half.Y,view.Y/2))
    panel.Position=panel.Position+UDim2.fromOffset(x-center.X,y-center.Y)
end
connect(panel.InputBegan,function(input)
    if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) and input.Position.Y<panel.AbsolutePosition.Y+260*scale.Scale then
        dragInput=input;dragStart=input.Position;panelStart=panel.Position
    end
end)
connect(UIS.InputChanged,function(input)
    if dragInput and (input==dragInput or input.UserInputType==Enum.UserInputType.MouseMovement) then
        local delta=input.Position-dragStart
        panel.Position=UDim2.new(panelStart.X.Scale,panelStart.X.Offset+delta.X,panelStart.Y.Scale,panelStart.Y.Offset+delta.Y)
    end
end)
connect(UIS.InputEnded,function(input) if input==dragInput then dragInput=nil;clampPosition() end end)
connect(gui.Destroying,function()
    UI.Destroyed=true
    if scaleTween then scaleTween:Cancel() end
    for _,animation in pairs(tweens) do animation:Cancel() end
    table.clear(tweens)

    for _,connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
end)
function UI:SetVisible(visible) if not self.Destroyed then panel.Visible=not not visible end end
function UI:Toggle() if not self.Destroyed then panel.Visible=not panel.Visible end end
function UI:SetUsername(name) if not self.Destroyed then options.Username=tostring(name);displayName.Text=options.Username end end
UI.Gui=gui
resize()
return UI
end
return Library



