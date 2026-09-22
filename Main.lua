-- Steal an Egg: Pro Finder (5-Min Auto Restock + No Lag)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهة القديمة لمنع التكرار
if CoreGui:FindFirstChild("SyncFinderPro") then
    CoreGui.SyncFinderPro:Destroy()
end

-- 1. إنشاء واجهة احترافية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyncFinderPro"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 450)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✨ PRO FINDER (+1B)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 100, 0, 30)
RefreshBtn.Position = UDim2.new(1, -115, 0, 7)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
RefreshBtn.Text = "Refresh 🔄"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 13
RefreshBtn.Parent = TopBar

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -65)
ScrollList.Position = UDim2.new(0, 10, 0, 55)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 4
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- دالة تحويل الأرقام
local function ParseValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local num = tonumber(val:match("[%d%.]+")) or 0
    if val:find("B") or val:find("b") then return num * 1000000000
    elseif val:find("M") or val:find("m") then return num * 1000000 end
    return num
end

-- دالة إضافة الكروت
local function AddCard(name, valueText, targetObj)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 65)
    Card.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Card.Parent = ScrollList

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(0, 200, 1, 0)
    Info.Position = UDim2.new(0, 15, 0, 0)
    Info.Text = name .. "\n<font color='#00ff88'>💰 " .. valueText .. "</font>"
    Info.RichText = true
    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Font = Enum.Font.GothamSemibold
    Info.TextSize = 14
    Info.BackgroundTransparency = 1
    Info.Parent = Card

    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Size = UDim2.new(0, 90, 0, 35)
    TeleportBtn.Position = UDim2.new(1, -105, 0.5, -17)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 110)
    TeleportBtn.Text = "Teleport ⚡"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.TextSize = 13
    TeleportBtn.Parent = Card

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
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

-- دالة الفحص (يتم استدعاؤها يدوياً أو تلقائياً)
local function PerformScan(isAutoScan)
    for _, obj in pairs(ScrollList:GetChildren()) do
        if obj:IsA("Frame") or obj:IsA("TextLabel") then obj:Destroy() end
    end

    local count = 0
    for _, obj in pairs(Workspace:GetChildren()) do
        if count >= 5 then break end 

        local valObj = obj:FindFirstChild("Value") or obj:FindFirstChild("Income") or obj:FindFirstChild("Cash")
        if valObj then
            local numericVal = ParseValue(valObj.Value)
            if numericVal >= 1000000000 then -- 1B
                count = count + 1
                AddCard(obj.Name, tostring(valObj.Value) .. "/s", obj)
            end
        end
    end

    -- رسالة الواجهة
    if count == 0 then
        local NoItem = Instance.new("TextLabel")
        NoItem.Size = UDim2.new(1, 0, 0, 50)
        NoItem.Text = "لا يوجد سيكريت +1B حالياً.\nجاري انتظار الـ Restock..."
        NoItem.TextColor3 = Color3.fromRGB(150, 150, 150)
        NoItem.Font = Enum.Font.Gotham
        NoItem.TextSize = 13
        NoItem.BackgroundTransparency = 1
        NoItem.Parent = ScrollList
        
        -- الإشعار الجانبي (إذا كان الفحص تلقائياً كل 5 دقائق)
        if isAutoScan then
            StarterGui:SetCore("SendNotification", {
                Title = "Restock Update 🥚",
                Text = "لايوجد اي حيوان حاليا رسبن",
                Duration = 5
            })
        end
    else
        -- إذا وجد حيوان أثناء الفحص التلقائي يرسل إشعار قوي
        if isAutoScan then
            StarterGui:SetCore("SendNotification", {
                Title = "🚨 رسبن نادر! 🚨",
                Text = "تم نزول حيوان يعطي فوق 1B!",
                Duration = 7
            })
        end
    end
end

-- تفعيل زر التحديث اليدوي
RefreshBtn.MouseButton1Click:Connect(function()
    RefreshBtn.Text = "..."
    PerformScan(false) -- فحص يدوي (لا يرسل إشعار الشاشة الجانبي)
    task.wait(0.3)
    RefreshBtn.Text = "Refresh 🔄"
end)

-- تشغيل أول فحص عند فتح السكربت
PerformScan(false)

-- نظام الفحص التلقائي (كل 5 دقائق = 300 ثانية) يعمل في الخلفية بدون Lag
task.spawn(function()
    while true do
        task.wait(300)
        PerformScan(true) -- فحص تلقائي (يرسل إشعار)
    end
end)
