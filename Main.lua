-- Steal an Egg: Rare Egg Finder with Main Menu GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Egg Finder Hub | Steal an Egg",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "by Delta Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- الخدمات
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local MinValue = 1000000000 -- 1 Billion
local AutoHopEnabled = false
local AutoTeleportEnabled = true

-- القائمة المستهدفة
local TargetPets = {
    -- 🔴 Secret
    "King Snake", "Yeti", "Cerberus", "Kraken", "T-Rex", "Tralaledon", 
    "Cosmic Dragon", "Stag", "Pure Jellyfish", "Centaur", "Gargoyle", "RazorFang",
    -- 🟣 Eternal
    "Ice Dragon", "Phoenix", "Lava Dragon", "El Maja", "Mosasaurus", 
    "Eternal Lunar Dragon", "Oni Tiger", "Gorilla King", "Pegasus", "Skeleton Horse",
    -- 🟡 Divine
    "Unicorn", "Kitsune", "Nightflame", "ArchAngel", "World Burner"
}

-- دالة تحويل القيم
local function ParseValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local num = tonumber(val:match("[%d%.]+")) or 0
    if val:find("B") or val:find("b") then return num * 1000000000
    elseif val:find("M") or val:find("m") then return num * 1000000
    elseif val:find("K") or val:find("k") then return num * 1000 end
    return num
end

-- التحقق من الهدف
local function CheckTarget(name)
    for _, target in pairs(TargetPets) do
        if name:lower():find(target:lower()) then return true, target end
    end
    return false, nil
end

local function GetObjectValue(obj)
    local valObj = obj:FindFirstChild("Value") or obj:FindFirstChild("Income") or obj:FindFirstChild("Cash") or obj:FindFirstChild("Generation")
    if valObj then return ParseValue(valObj.Value) end
    local attrVal = obj:GetAttribute("Value") or obj:GetAttribute("Income")
    if attrVal then return ParseValue(attrVal) end
    return 0
end

-- التنقل بين السيرفرات
local function ServerHop()
    Rayfield:Notify({Title = "Server Hop", Content = "جاري البحث عن سيرفر جديد...", Duration = 3})
    local PlaceId = game.PlaceId
    local Servers = {}
    local success, raw = pcall(function()
        return game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceId .. '/servers/0?sortOrder=Asc&limit=100')
    end)
    
    if success and raw then
        local Parsed = HttpService:JSONDecode(raw)
        if Parsed and Parsed.data then
            for _, v in pairs(Parsed.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(Servers, v.id)
                end
            end
        end
    end
    
    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, Servers[math.random(1, #Servers)], LocalPlayer)
    else
        task.wait(2)
        ServerHop()
    end
end

-- عند العثور على هدف
local function OnTargetFound(obj, matchedName, isNewSpawn)
    local titleText = isNewSpawn and "🚨 سيرفر جديد قوي! (ترسبن جديد)" or "🎉 تم العثور على هدف!"
    
    Rayfield:Notify({
        Title = titleText,
        Content = "الاسم: " .. matchedName .. " (+1B)",
        Duration = 10,
        Image = 4483362458,
    })
    
    -- صوت التنبيه
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://459766365"
    sound.Parent = SoundService
    sound:Play()
    
    -- الانتقال الفوري
    if AutoTeleportEnabled then
        if obj:IsA("BasePart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
        elseif obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame end
        end
    end
end

-- فحص السيرفر
local function ScanServer()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local isTarget, matchedName = CheckTarget(obj.Name)
        if isTarget then
            local val = GetObjectValue(obj)
            if val >= MinValue or val == 0 then
                OnTargetFound(obj, matchedName, false)
                return true
            end
        end
    end
    return false
end

-- إنشاء تبويبات القائمة (UI Tabs)
local MainTab = Window:CreateTab("الرئيسية 🏠", 4483362458)

MainTab:CreateButton({
   Name = "فحص السيرفر الآن 🔍",
   Callback = function()
       local found = ScanServer()
       if not found then
           Rayfield:Notify({Title = "نتيجة الفحص", Content = "لم يتم العثور على أهداف مطابقة +1B في هذا السيرفر.", Duration = 4})
       end
   end,
})

MainTab:CreateToggle({
   Name = "انتقال تلقائي للسيرفرات (Auto Server Hop)",
   CurrentValue = AutoHopEnabled,
   Flag = "AutoHop",
   Callback = function(Value)
       AutoHopEnabled = Value
       if AutoHopEnabled then
           local found = ScanServer()
           if not found then ServerHop() end
       end
   end,
})

MainTab:CreateToggle({
   Name = "انتقال تلقائي للبيضة فور العثور عليها",
   CurrentValue = AutoTeleportEnabled,
   Flag = "AutoTP",
   Callback = function(Value)
       AutoTeleportEnabled = Value
   end,
})

MainTab:CreateButton({
   Name = "انتقال لسيرفر آخر يدويًا (Server Hop)",
   Callback = function()
       ServerHop()
   end,
})

local ListTab = Window:CreateTab("قائمة الهدف 📋", 4483362458)
ListTab:CreateSection("الندرات المفعلة: Secret, Eternal, Divine (+1B)")
for _, name in pairs(TargetPets) do
    ListTab:CreateButton({
        Name = "• " .. name,
        Callback = function() end
    })
end

-- مراقبة الترسبن التلقائي في الخلفية
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    local isTarget, matchedName = CheckTarget(obj.Name)
    if isTarget then
        local val = GetObjectValue(obj)
        if val >= MinValue or val == 0 then
            OnTargetFound(obj, matchedName, true)
        end
    end
end)

