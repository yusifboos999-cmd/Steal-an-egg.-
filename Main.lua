-- Steal an Egg: Light Egg Finder (Max 5 Display + Refresh Button)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- حذف الواجهة القديمة إن وجدت لمنع التكرار
if game.CoreGui:FindFirstChild("EggFinderLightUI") then
    game.CoreGui.EggFinderLightUI:Destroy()
end

-- 1. إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggFinderLightUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- شريط العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = " 🥚 FINDER (+1B) "
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- زر تحديث / Restock
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.3, -5, 0, 30)
RefreshBtn.Position = UDim2.new(0.7, 0, 0, 5)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
RefreshBtn.Text = "Refresh 🔄"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

-- قائمة العرض
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -50)
ScrollList.Position = UDim2.new(0, 10, 0, 45)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 4
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.Padding = UDim.new(0, 6)

-- 2. تحويل القيم المالية بسرعة بدون تعليق
local function ParseValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local num = tonumber(val:match("[%d%.]+")) or 0
    if val:find("B") or val:find("b") then return num * 1000000000
    elseif val:find("M") or val:find("m") then return num * 1000000 end
    return num
end

-- 3. إضافة بطاقة العنصر (حد أقصى 5 بطاقات فقط لتفادي التعليق)
local function AddEggCard(name, valueText, targetObj)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 55)
    Card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Card.Parent = ScrollList

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(0, 180, 1, 0)
    Info.Position = UDim2.new(0, 10, 0, 0)
    Info.Text = name .. "\n💰 " .. valueText
    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Font = Enum.Font.SourceSansBold
    Info.TextSize = 13
    Info.BackgroundTransparency = 1
    Info.Parent = Card

    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Size = UDim2.new(0, 80, 0, 30)
    JoinBtn.Position = UDim2.new(1, -88, 0.5, -15)
    JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    JoinBtn.Text = "Teleport ⚡"
    JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    JoinBtn.Font = Enum.Font.SourceSansBold
    JoinBtn.TextSize = 12
    JoinBtn.Parent = Card

    JoinBtn.MouseButton1Click:Connect(function()
        if targetObj then
            local part = targetObj:IsA("BasePart") and targetObj or targetObj:FindFirstChildWhichIsA("BasePart") or targetObj.PrimaryPart
            if part then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
            end
        end
    end)
end

-- 4. فحص السيرفر خفيف ومحدد بـ 5 سيرفرات/حيوانات فقط
local function FastScan()
    -- تفريغ الشاشة
    for _, obj in pairs(ScrollList:GetChildren()) do
        if obj:IsA("Frame") or obj:IsA("TextLabel") then
            obj:Destroy()
        end
    end

    local count = 0
    for _, obj in pairs(Workspace:GetChildren()) do -- الفحص على المستوى الأول فقط لتقليل الـ Lag
        if count >= 5 then break end -- التوقف فور الوصول لـ 5 نتائج

        local valObj = obj:FindFirstChild("Value") or obj:FindFirstChild("Income") or obj:FindFirstChild("Cash")
        if valObj then
            local numericVal = ParseValue(valObj.Value)
            if numericVal >= 1000000000 then
                count = count + 1
                AddEggCard(obj.Name, tostring(valObj.Value) .. "/s", obj)
            end
        end
    end

    if count == 0 then
        local NoItem = Instance.new("TextLabel")
        NoItem.Size = UDim2.new(1, 0, 0, 40)
        NoItem.Text = "لا يوجد بيض +1B حالياً.\nاضغط Refresh عند الـ Restock."
        NoItem.TextColor3 = Color3.fromRGB(180, 180, 180)
        NoItem.Font = Enum.Font.SourceSans
        NoItem.TextSize = 13
        NoItem.BackgroundTransparency = 1
        NoItem.Parent = ScrollList
    end
end

-- ربط زر التحديث Refresh
RefreshBtn.MouseButton1Click:Connect(function()
    RefreshBtn.Text = "جاري التحديث..."
    FastScan()
    task.wait(0.5)
    RefreshBtn.Text = "Refresh 🔄"
end)

-- تشغيل أول مرة
FastScan()
