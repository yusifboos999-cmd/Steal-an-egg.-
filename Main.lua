-- Steal an Egg: Clean Server Hop (No Error 279)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("CleanHopper") then
    CoreGui.CleanHopper:Destroy()
end

-- واجهة بسيطة زر واحد فقط
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanHopper"
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

-- الانتقال الآمن لتجنب خطأ 279
HopBtn.MouseButton1Click:Connect(function()
    HopBtn.Text = "جاري النقل..."
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end)

-- فحص تلقائي فور دخول أي سيرفر جديد
task.spawn(function()
    task.wait(3)
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
