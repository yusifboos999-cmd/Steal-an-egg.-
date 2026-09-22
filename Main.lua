-- Steal an Egg: One-Click Server Hop & Auto Check
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("OneClickHopper") then
    CoreGui.OneClickHopper:Destroy()
end

-- واجهة بسيطة جداً وصغيرة زر واحد فقط
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OneClickHopper"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 90)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -45)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(1, -16, 1, -16)
HopBtn.Position = UDim2.new(0, 8, 0, 8)
HopBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
HopBtn.Text = "🌍 Server Hop (+1B)"
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Font = Enum.Font.GothamBold
HopBtn.TextSize = 13
HopBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = HopBtn

-- دالة تغيير السيرفر بضغطة زر
HopBtn.MouseButton1Click:Connect(function()
    HopBtn.Text = "جاري النقل..."
    pcall(function()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in pairs(req.data) do
                if type(s) == "table" and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers, s.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end)

-- فحص تلقائي فور دخول أي سيرفر جديد
task.spawn(function()
    task.wait(3) -- انتظار تحميل الماب
    local function ParseValue(val)
        if type(val) == "number" then return val end
        if type(val) ~= "string" then return 0 end
        local num = tonumber(val:match("[%d%.]+")) or 0
        if val:find("B") or val:find("b") then return num * 1000000000
        elseif val:find("M") or val:find("m") then return num * 1000000 end
        return num
    end

    for _, obj in pairs(Workspace:GetChildren()) do
        local valObj = obj:FindFirstChild("Value") or obj:FindFirstChild("Income") or obj:FindFirstChild("Cash")
        if valObj then
            local val = ParseValue(valObj.Value)
            if val >= 1000000000 then
                StarterGui:SetCore("SendNotification", {
                    Title = "🚨 صيد ثمين في هذا السيرفر!",
                    Text = "تم العثور على " .. obj.Name .. " بقيمة فوق 1B!",
                    Duration = 8
                })
                HopBtn.Text = "🚨 وجدنا هدف +1B!"
                HopBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                return
            end
        end
    end
end)
