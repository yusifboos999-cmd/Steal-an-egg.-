-- Steal an Egg: Pro Finder (Live Restock Timer + Minimize Button + Compact UI)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهة القديمة
if CoreGui:FindFirstChild("SyncFinderPro") then
    CoreGui.SyncFinderPro:Destroy()
end

-- 1. إنشاء واجهة عريضة وصغيرة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyncFinderPro"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- شريط العنوان العلوي
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 8)
TopBarFix.Position = UDim2.new(0, 0, 1, -8)
TopBarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

-- عنوان مع العداد التنازلي (Timer)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 230, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ PRO FINDER | Restock: 5:00"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- زر التحديث Refresh
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 75, 0, 26)
RefreshBtn.Position = UDim2.new(1, -170, 0, 6)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
RefreshBtn.Text = "Refresh 🔄"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 11
RefreshBtn.Parent = TopBar

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 5)
RefreshCorner.Parent = RefreshBtn

-- زر تصغير / إخفاء الواجهة (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -88, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = MinimizeBtn

-- قائمة العرض
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -16, 1, -52)
ScrollList.Position = UDim2.new(0, 8, 0, 44)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 3
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- متغير إخفاء الواجهة
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ScrollList.Visible = false
        MainFrame.Size = UDim2.new(0, 420, 0, 38)
        MinimizeBtn.Text = "+"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        ScrollList.Visible = true
        MainFrame.Size = UDim2.new(0, 420, 0, 260)
        MinimizeBtn.Text = "-"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- تحويل القيم
local function ParseValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local num = tonumber(val:match("[%d%.]+")) or 0
    if val:find("B") or val:find("b") then return num * 1000000000
    elseif val:find("M") or val:find("m") then return num * 1000000 end
    return num
end

-- إضافة البطاقات
local function AddCard(name, valueText, targetObj)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 50)
    Card.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Card.Parent = ScrollList

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(0, 250, 1, 0)
    Info.Position = UDim2.new(0, 12, 0, 0)
    Info.Text = name .. " | <font color='#00ff88'>💰 " .. valueText .. "</font>"
    Info.RichText = true
    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Font = Enum.Font.GothamSemibold
    Info.TextSize = 13
    Info.BackgroundTransparency = 1
    Info.Parent = Card

    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Size = UDim2.new(0, 80, 0, 30)
    TeleportBtn.Position = UDim2.new(1, -92, 0.5, -15)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 110)
    TeleportBtn.Text = "Teleport ⚡"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.TextSize = 12
    TeleportBtn.Parent = Card

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = TeleportBtn

    TeleportBtn.MouseButton1Click:Connect(function()
        if targetObj then
            local part = targetObj:IsA("BasePart") and targetObj or targetObj:FindFirstChildWhichIsA("BasePart") or targetObj.PrimaryPart
            if part then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
            end
        end
    end)
end

-- فحص السيرفر
local function PerformScan(isAutoScan)
    for _, obj in pairs(ScrollList:GetChildren()) do
        if obj:IsA("Frame") or obj:IsA("TextLabel") then obj:Destroy() end
    end

    local count = 0
    for _, obj in pairs(Workspace:GetChildren()) do
        if count >= 4 then break end 

        local valObj = obj:FindFirstChild("Value") or obj:FindFirstChild("Income") or obj:FindFirstChild("Cash")
        if valObj then
            local numericVal = ParseValue(valObj.Value)
            if numericVal >= 1000000000 then
                count = count + 1
                AddCard(obj.Name, tostring(valObj.Value) .. "/s", obj)
            end
        end
    end

    if count == 0 then
        local NoItem = Instance.new("TextLabel")
        NoItem.Size = UDim2.new(1, 0, 0, 40)
        NoItem.Text = "لا يوجد سيكريت +1B حالياً. جاري انتظار الـ Restock..."
        NoItem.TextColor3 = Color3.fromRGB(150, 150, 150)
        NoItem.Font = Enum.Font.Gotham
        NoItem.TextSize = 12
        NoItem.BackgroundTransparency = 1
        NoItem.Parent = ScrollList
        
        if isAutoScan then
            StarterGui:SetCore("SendNotification", {
                Title = "Restock Update 🥚",
                Text = "لايوجد اي حيوان حاليا رسبن",
                Duration = 5
            })
        end
    else
        if isAutoScan then
            StarterGui:SetCore("SendNotification", {
                Title = "🚨 رسبن نادر! 🚨",
                Text = "تم نزول حيوان يعطي فوق 1B!",
                Duration = 7
            })
        end
    end
end

RefreshBtn.MouseButton1Click:Connect(function()
    RefreshBtn.Text = "..."
    PerformScan(false)
    task.wait(0.3)
    RefreshBtn.Text = "Refresh 🔄"
end)

PerformScan(false)

-- عداد تنازلي متزامن كل 5 دقائق (300 ثانية) يظهر بالدقائق والثواني في العنوان
task.spawn(function()
    local restockTime = 300
    while true do
        for i = restockTime, 1, -1 do
            local mins = math.floor(i / 60)
            local secs = i % 60
            Title.Text = string.format("✨ FINDER | Restock: %d:%02d", mins, secs)
            task.wait(1)
        end
        PerformScan(true)
    end
end)
