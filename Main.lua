-- Steal an Egg: Simplified Finder UI (> 1B Filter)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- 1. إنشاء واجهة شاشة بسيطة ونظيفة (Custom GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggFinderUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 420)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "🥚 EGG FINDER (+1B ONLY)"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -50)
ScrollList.Position = UDim2.new(0, 10, 0, 45)
ScrollList.BackgroundTransparency = 1
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- 2. دالة تحويل وتحليل الأرقام (تصفية فوق 1B)
local function ParseValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local num = tonumber(val:match("[%d%.]+")) or 0
    if val:find("B") or val:find("b") then return num * 1000000000
    elseif val:find("M") or val:find("m") then return num * 1000000 end
    return num
end

-- 3. إضافة بطاقة لكل حيوان/بيضة تعطي فوق 1B
local function AddEggCard(name, valueText, iconId, jobId)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 65)
    Card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Card.Parent = ScrollList

    -- صورة الحيوان
    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(0, 50, 0, 50)
    Img.Position = UDim2.new(0, 8, 0, 8)
    Img.Image = iconId or "rbxassetid://4483362458"
    Img.BackgroundTransparency = 1
    Img.Parent = Card

    -- الاسم والدخل ($/s)
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(0, 160, 1, 0)
    Info.Position = UDim2.new(0, 65, 0, 0)
    Info.Text = name .. "\n💰 " .. valueText
    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Font = Enum.Font.SourceSansBold
    Info.TextSize = 14
    Info.BackgroundTransparency = 1
    Info.Parent = Card

    -- زر Join Server
    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Size = UDim2.new(0, 90, 0, 35)
    JoinBtn.Position = UDim2.new(1, -98, 0.5, -17)
    JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    JoinBtn.Text = "Spam Join"
    JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    JoinBtn.Font = Enum.Font.SourceSansBold
    JoinBtn.TextSize = 14
    JoinBtn.Parent = Card

    JoinBtn.MouseButton1Click:Connect(function()
        if jobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
        else
            -- إذا كان في نفس السيرفر ينتقل إليه مباشرة
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find(name:lower()) then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part then LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame end
                end
            end
        end
    end)
end

-- 4. فحص الـ Restock والسيرفر الحالي فوراً
local function ScanRestock()
    for _, obj in pairs(ScrollList:GetChildren()) do
        if obj:IsA("Frame") then obj:Destroy() end
    end

    local foundAny = false
    for _, obj in pairs(Workspace:GetDescendants()) do
        local valObj = obj:FindFirstChild("Value") or obj:FindFirstChild("Income") or obj:FindFirstChild("Cash")
        if valObj then
            local numericVal = ParseValue(valObj.Value)
            -- الشرط: أكبر من أو يساوي 1B
            if numericVal >= 1000000000 then
                foundAny = true
                local imgObj = obj:FindFirstChildOfClass("Decal") or obj:FindFirstChildOfClass("Texture")
                local iconId = imgObj and imgObj.Texture or "rbxassetid://4483362458"
                AddEggCard(obj.Name, tostring(valObj.Value) .. "/s", iconId, nil)
            end
        end
    end

    if not foundAny then
        local NoItem = Instance.new("TextLabel")
        NoItem.Size = UDim2.new(1, 0, 0, 50)
        NoItem.Text = "لا يوجد بيض +1B في هذا السيرفر حالياً\nانتظر الـ Restock القادم..."
        NoItem.TextColor3 = Color3.fromRGB(200, 200, 200)
        NoItem.BackgroundTransparency = 1
        NoItem.Parent = ScrollList
    end
end

-- التشغيل وتحديث القائمة تلقائياً عند الـ Restock
ScanRestock()
Workspace.DescendantAdded:Connect(function()
    task.wait(0.5)
    ScanRestock()
end)
