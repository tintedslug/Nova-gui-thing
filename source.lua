--[[
	Nova UI Framework
	Inspired by Rayfield (Sirius)
	A modern, performant Roblox GUI library
]]

local Nova = {
	Flags = {},
	Themes = {},
	ActiveWindows = 0,
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local IsExecutor = syn and true or false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local function protectGui()
	local ok, err = pcall(function()
		ScreenGui.Parent = (IsExecutor and CoreGui) or Player:WaitForChild("PlayerGui")
	end)
	if not ok then
		ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	end
end
protectGui()

-- Tween helper
local function tween(obj, props, duration, style, direction)
	local ti = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, ti, props)
	tw:Play()
	return tw
end

-- Drag system
local function makeDraggable(frame, dragHandle)
	dragHandle = dragHandle or frame
	local dragging, dragInput, dragStart, startPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Image loading helper
local function getIcon(id)
	if type(id) == "string" and id ~= "" then
		return id
	elseif type(id) == "number" and id > 0 then
		return "rbxassetid://" .. id
	end
	return ""
end

-- Ripple effect
local function createRipple(button, x, y)
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ripple.BackgroundTransparency = 0.7
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 10

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = ripple

	ripple.Parent = button
	tween(ripple, {Size = UDim2.new(0, button.AbsoluteSize.X * 2, 0, button.AbsoluteSize.X * 2), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	game:GetService("Debris"):AddItem(ripple, 0.6)
end

--[[
	THEME SYSTEM
]]
local Themes = {
	Default = {
		Window = {
			BackgroundColor = Color3.fromRGB(18, 18, 22),
			TopbarColor = Color3.fromRGB(14, 14, 18),
			BorderColor = Color3.fromRGB(30, 30, 40),
			TitleColor = Color3.fromRGB(255, 255, 255),
			SubtitleColor = Color3.fromRGB(150, 150, 170),
			AccentColor = Color3.fromRGB(88, 101, 242),
			AccentGradientTop = Color3.fromRGB(88, 101, 242),
			AccentGradientBottom = Color3.fromRGB(120, 80, 240),
			ShadowColor = Color3.fromRGB(0, 0, 0),
			ShadowTransparency = 0.6,
		},
		Tab = {
			BackgroundColor = Color3.fromRGB(24, 24, 30),
			SelectedColor = Color3.fromRGB(88, 101, 242),
			TextColor = Color3.fromRGB(160, 160, 180),
			SelectedTextColor = Color3.fromRGB(255, 255, 255),
			HoverBackground = Color3.fromRGB(35, 35, 45),
		},
		Element = {
			BackgroundColor = Color3.fromRGB(24, 24, 30),
			HoverBackgroundColor = Color3.fromRGB(30, 30, 38),
			BorderColor = Color3.fromRGB(35, 35, 45),
			TitleColor = Color3.fromRGB(220, 220, 240),
			DescriptionColor = Color3.fromRGB(140, 140, 160),
			ToggleOn = Color3.fromRGB(88, 101, 242),
			ToggleOff = Color3.fromRGB(40, 40, 50),
			SliderBackground = Color3.fromRGB(35, 35, 45),
			SliderFill = Color3.fromRGB(88, 101, 242),
			DropdownBackground = Color3.fromRGB(28, 28, 36),
			DropdownHover = Color3.fromRGB(40, 40, 52),
			InputBackground = Color3.fromRGB(28, 28, 36),
			InputTextColor = Color3.fromRGB(220, 220, 240),
			PlaceholderColor = Color3.fromRGB(100, 100, 120),
		},
		Notification = {
			BackgroundColor = Color3.fromRGB(22, 22, 28),
			BorderColor = Color3.fromRGB(40, 40, 52),
			TitleColor = Color3.fromRGB(255, 255, 255),
			ContentColor = Color3.fromRGB(180, 180, 200),
			AccentColor = Color3.fromRGB(88, 101, 242),
		},
		Section = {
			TextColor = Color3.fromRGB(120, 120, 150),
			LineColor = Color3.fromRGB(35, 35, 45),
		},
	},

	Ocean = {
		Window = {
			BackgroundColor = Color3.fromRGB(10, 18, 28),
			TopbarColor = Color3.fromRGB(8, 14, 24),
			BorderColor = Color3.fromRGB(20, 40, 60),
			TitleColor = Color3.fromRGB(220, 240, 255),
			SubtitleColor = Color3.fromRGB(120, 180, 220),
			AccentColor = Color3.fromRGB(0, 150, 255),
			AccentGradientTop = Color3.fromRGB(0, 150, 255),
			AccentGradientBottom = Color3.fromRGB(0, 100, 220),
			ShadowColor = Color3.fromRGB(0, 0, 0),
			ShadowTransparency = 0.65,
		},
		Tab = {
			BackgroundColor = Color3.fromRGB(14, 24, 36),
			SelectedColor = Color3.fromRGB(0, 150, 255),
			TextColor = Color3.fromRGB(140, 180, 210),
			SelectedTextColor = Color3.fromRGB(255, 255, 255),
			HoverBackground = Color3.fromRGB(22, 36, 52),
		},
		Element = {
			BackgroundColor = Color3.fromRGB(14, 24, 36),
			HoverBackgroundColor = Color3.fromRGB(20, 32, 46),
			BorderColor = Color3.fromRGB(24, 44, 64),
			TitleColor = Color3.fromRGB(200, 220, 240),
			DescriptionColor = Color3.fromRGB(120, 160, 190),
			ToggleOn = Color3.fromRGB(0, 150, 255),
			ToggleOff = Color3.fromRGB(28, 44, 60),
			SliderBackground = Color3.fromRGB(24, 40, 56),
			SliderFill = Color3.fromRGB(0, 150, 255),
			DropdownBackground = Color3.fromRGB(18, 30, 44),
			DropdownHover = Color3.fromRGB(28, 46, 64),
			InputBackground = Color3.fromRGB(18, 30, 44),
			InputTextColor = Color3.fromRGB(200, 220, 240),
			PlaceholderColor = Color3.fromRGB(80, 120, 150),
		},
		Notification = {
			BackgroundColor = Color3.fromRGB(14, 24, 36),
			BorderColor = Color3.fromRGB(24, 48, 72),
			TitleColor = Color3.fromRGB(220, 240, 255),
			ContentColor = Color3.fromRGB(160, 200, 230),
			AccentColor = Color3.fromRGB(0, 150, 255),
		},
		Section = {
			TextColor = Color3.fromRGB(100, 150, 190),
			LineColor = Color3.fromRGB(24, 44, 64),
		},
	},

	Amethyst = {
		Window = {
			BackgroundColor = Color3.fromRGB(20, 14, 28),
			TopbarColor = Color3.fromRGB(16, 10, 24),
			BorderColor = Color3.fromRGB(40, 28, 55),
			TitleColor = Color3.fromRGB(240, 230, 255),
			SubtitleColor = Color3.fromRGB(190, 160, 220),
			AccentColor = Color3.fromRGB(160, 80, 255),
			AccentGradientTop = Color3.fromRGB(160, 80, 255),
			AccentGradientBottom = Color3.fromRGB(130, 50, 230),
			ShadowColor = Color3.fromRGB(0, 0, 0),
			ShadowTransparency = 0.6,
		},
		Tab = {
			BackgroundColor = Color3.fromRGB(26, 18, 36),
			SelectedColor = Color3.fromRGB(160, 80, 255),
			TextColor = Color3.fromRGB(180, 160, 200),
			SelectedTextColor = Color3.fromRGB(255, 255, 255),
			HoverBackground = Color3.fromRGB(38, 28, 50),
		},
		Element = {
			BackgroundColor = Color3.fromRGB(26, 18, 36),
			HoverBackgroundColor = Color3.fromRGB(34, 24, 46),
			BorderColor = Color3.fromRGB(44, 32, 58),
			TitleColor = Color3.fromRGB(230, 220, 245),
			DescriptionColor = Color3.fromRGB(170, 150, 190),
			ToggleOn = Color3.fromRGB(160, 80, 255),
			ToggleOff = Color3.fromRGB(42, 30, 56),
			SliderBackground = Color3.fromRGB(38, 28, 52),
			SliderFill = Color3.fromRGB(160, 80, 255),
			DropdownBackground = Color3.fromRGB(30, 22, 42),
			DropdownHover = Color3.fromRGB(44, 32, 58),
			InputBackground = Color3.fromRGB(30, 22, 42),
			InputTextColor = Color3.fromRGB(230, 220, 245),
			PlaceholderColor = Color3.fromRGB(130, 110, 150),
		},
		Notification = {
			BackgroundColor = Color3.fromRGB(24, 16, 34),
			BorderColor = Color3.fromRGB(48, 34, 64),
			TitleColor = Color3.fromRGB(240, 230, 255),
			ContentColor = Color3.fromRGB(200, 180, 220),
			AccentColor = Color3.fromRGB(160, 80, 255),
		},
		Section = {
			TextColor = Color3.fromRGB(150, 130, 170),
			LineColor = Color3.fromRGB(44, 32, 58),
		},
	},

	Bloom = {
		Window = {
			BackgroundColor = Color3.fromRGB(10, 22, 16),
			TopbarColor = Color3.fromRGB(8, 18, 12),
			BorderColor = Color3.fromRGB(24, 48, 36),
			TitleColor = Color3.fromRGB(220, 255, 235),
			SubtitleColor = Color3.fromRGB(140, 200, 170),
			AccentColor = Color3.fromRGB(0, 200, 120),
			AccentGradientTop = Color3.fromRGB(0, 200, 120),
			AccentGradientBottom = Color3.fromRGB(0, 160, 90),
			ShadowColor = Color3.fromRGB(0, 0, 0),
			ShadowTransparency = 0.65,
		},
		Tab = {
			BackgroundColor = Color3.fromRGB(14, 28, 20),
			SelectedColor = Color3.fromRGB(0, 200, 120),
			TextColor = Color3.fromRGB(140, 190, 170),
			SelectedTextColor = Color3.fromRGB(255, 255, 255),
			HoverBackground = Color3.fromRGB(22, 40, 30),
		},
		Element = {
			BackgroundColor = Color3.fromRGB(14, 28, 20),
			HoverBackgroundColor = Color3.fromRGB(20, 36, 26),
			BorderColor = Color3.fromRGB(28, 52, 38),
			TitleColor = Color3.fromRGB(200, 240, 220),
			DescriptionColor = Color3.fromRGB(130, 180, 160),
			ToggleOn = Color3.fromRGB(0, 200, 120),
			ToggleOff = Color3.fromRGB(28, 52, 38),
			SliderBackground = Color3.fromRGB(24, 48, 34),
			SliderFill = Color3.fromRGB(0, 200, 120),
			DropdownBackground = Color3.fromRGB(18, 34, 26),
			DropdownHover = Color3.fromRGB(28, 52, 38),
			InputBackground = Color3.fromRGB(18, 34, 26),
			InputTextColor = Color3.fromRGB(200, 240, 220),
			PlaceholderColor = Color3.fromRGB(100, 150, 130),
		},
		Notification = {
			BackgroundColor = Color3.fromRGB(14, 28, 20),
			BorderColor = Color3.fromRGB(28, 56, 42),
			TitleColor = Color3.fromRGB(220, 255, 235),
			ContentColor = Color3.fromRGB(160, 210, 185),
			AccentColor = Color3.fromRGB(0, 200, 120),
		},
		Section = {
			TextColor = Color3.fromRGB(110, 170, 145),
			LineColor = Color3.fromRGB(28, 52, 38),
		},
	},

	Ember = {
		Window = {
			BackgroundColor = Color3.fromRGB(22, 14, 12),
			TopbarColor = Color3.fromRGB(18, 10, 8),
			BorderColor = Color3.fromRGB(48, 28, 24),
			TitleColor = Color3.fromRGB(255, 230, 220),
			SubtitleColor = Color3.fromRGB(210, 150, 130),
			AccentColor = Color3.fromRGB(255, 100, 50),
			AccentGradientTop = Color3.fromRGB(255, 100, 50),
			AccentGradientBottom = Color3.fromRGB(220, 60, 30),
			ShadowColor = Color3.fromRGB(0, 0, 0),
			ShadowTransparency = 0.55,
		},
		Tab = {
			BackgroundColor = Color3.fromRGB(28, 18, 16),
			SelectedColor = Color3.fromRGB(255, 100, 50),
			TextColor = Color3.fromRGB(200, 170, 160),
			SelectedTextColor = Color3.fromRGB(255, 255, 255),
			HoverBackground = Color3.fromRGB(40, 28, 24),
		},
		Element = {
			BackgroundColor = Color3.fromRGB(28, 18, 16),
			HoverBackgroundColor = Color3.fromRGB(36, 24, 22),
			BorderColor = Color3.fromRGB(50, 32, 28),
			TitleColor = Color3.fromRGB(240, 220, 215),
			DescriptionColor = Color3.fromRGB(190, 160, 150),
			ToggleOn = Color3.fromRGB(255, 100, 50),
			ToggleOff = Color3.fromRGB(50, 32, 28),
			SliderBackground = Color3.fromRGB(44, 28, 24),
			SliderFill = Color3.fromRGB(255, 100, 50),
			DropdownBackground = Color3.fromRGB(34, 22, 20),
			DropdownHover = Color3.fromRGB(50, 32, 28),
			InputBackground = Color3.fromRGB(34, 22, 20),
			InputTextColor = Color3.fromRGB(240, 220, 215),
			PlaceholderColor = Color3.fromRGB(150, 120, 110),
		},
		Notification = {
			BackgroundColor = Color3.fromRGB(26, 16, 14),
			BorderColor = Color3.fromRGB(54, 34, 30),
			TitleColor = Color3.fromRGB(255, 230, 220),
			ContentColor = Color3.fromRGB(210, 180, 170),
			AccentColor = Color3.fromRGB(255, 100, 50),
		},
		Section = {
			TextColor = Color3.fromRGB(170, 140, 130),
			LineColor = Color3.fromRGB(50, 32, 28),
		},
	},
}

Nova.Themes = Themes

-- Utility: Create UI corner
local function addCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = obj
	return c
end

-- Utility: Create UI padding
local function addPadding(obj, pad)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, pad or 8)
	p.PaddingRight = UDim.new(0, pad or 8)
	p.PaddingTop = UDim.new(0, pad or 8)
	p.PaddingBottom = UDim.new(0, pad or 8)
	p.Parent = obj
	return p
end

-- Utility: Create gradient
local function addGradient(obj, color1, color2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)})
	g.Rotation = rotation or 45
	g.Parent = obj
	return g
end

-- Utility: Create stroke/border
local function addStroke(obj, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(35, 35, 45)
	s.Thickness = thickness or 1
	s.Parent = obj
	return s
end

--[[
	NOTIFICATION SYSTEM
]]
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 340, 1, -20)
NotificationContainer.Position = UDim2.new(1, -360, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local NotificationListLayout = Instance.new("UIListLayout")
NotificationListLayout.Name = "ListLayout"
NotificationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationListLayout.Padding = UDim.new(0, 8)
NotificationListLayout.Parent = NotificationContainer

function Nova:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local content = config.Content or ""
	local duration = config.Duration or 5
	local icon = config.Image or config.Icon

	local theme = self.Theme or Themes.Default

	local frame = Instance.new("Frame")
	frame.Name = "Notification"
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundColor3 = theme.Notification.BackgroundColor
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = NotificationContainer

	local stroke = addStroke(frame, theme.Notification.BorderColor)

	local corner = addCorner(frame, 8)

	local iconHolder
	if icon then
		iconHolder = Instance.new("ImageLabel")
		iconHolder.Name = "Icon"
		iconHolder.Size = UDim2.new(0, 20, 0, 20)
		iconHolder.Position = UDim2.new(0, 14, 0, 14)
		iconHolder.BackgroundTransparency = 1
		iconHolder.Image = type(icon) == "number" and ("rbxassetid://" .. icon) or icon
		iconHolder.ImageColor3 = theme.Notification.AccentColor
		iconHolder.Parent = frame
	end

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -28, 0, 18)
	titleLabel.Position = icon and UDim2.new(0, 40, 0, 12) or UDim2.new(0, 14, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = theme.Notification.TitleColor
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Name = "Content"
	contentLabel.Size = UDim2.new(1, -28, 0, 0)
	contentLabel.Position = UDim2.new(0, 14, 0, 34)
	contentLabel.BackgroundTransparency = 1
	contentLabel.Text = content
	contentLabel.TextColor3 = theme.Notification.ContentColor
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextSize = 13
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextWrapped = true
	contentLabel.RichText = true
	contentLabel.Parent = frame

	local accentLine = Instance.new("Frame")
	accentLine.Name = "AccentLine"
	accentLine.Size = UDim2.new(0, 3, 1, 0)
	accentLine.BorderSizePixel = 0
	accentLine.BackgroundColor3 = theme.Notification.AccentColor
	accentLine.Parent = frame

	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(1, 0, 0, 2)
	progressBar.Position = UDim2.new(0, 0, 1, -2)
	progressBar.BorderSizePixel = 0
	progressBar.BackgroundColor3 = theme.Notification.AccentColor
	progressBar.BackgroundTransparency = 0.5
	progressBar.Parent = frame

	local actualHeight = 52 + contentLabel.TextBounds.Y
	frame.Size = UDim2.new(1, 0, 0, actualHeight)
	frame.Position = UDim2.new(1, 20, 0, 0)
	contentLabel.Size = UDim2.new(1, -28, 0, contentLabel.TextBounds.Y)

	frame.LayoutOrder = -1

	-- Slide in
	tween(frame, {Position = UDim2.new(1, -10, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	-- Progress bar shrink
	local startTime = tick()

	-- Fade out after duration
	task.spawn(function()
		task.wait(duration)
		tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, 0.3)
		tween(frame, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		wait(0.35)
		for _, v in pairs(frame:GetChildren()) do
			if v:IsA("ImageLabel") or v:IsA("TextLabel") then
				tween(v, {TextTransparency = 1, ImageTransparency = 1}, 0.15)
			end
		end
		wait(0.2)
		frame:Destroy()
	end)

	-- Animate progress bar
	task.spawn(function()
		while frame and frame.Parent do
			local elapsed = tick() - startTime
			local remaining = math.clamp(1 - (elapsed / duration), 0, 1)
			progressBar.Size = UDim2.new(remaining, 0, 0, 2)
			task.wait(0.05)
		end
	end)

	return frame
end

--[[
	WINDOW CLASS
]]
function Nova:CreateWindow(config)
	config = config or {}
	if not config.Name then
		config.Name = "Nova UI"
	end

	local windowInfo = {
		Name = config.Name,
		Icon = config.Icon or 0,
		LoadingTitle = config.LoadingTitle or "Nova",
		LoadingSubtitle = config.LoadingSubtitle or "Framework",
		Theme = config.Theme or "Default",
		KeySystem = config.KeySystem or false,
		KeySettings = config.KeySettings or {},
		ConfigurationSaving = config.ConfigurationSaving or {Enabled = false},
		Discord = config.Discord or {Enabled = false},
		DisableBuildWarnings = config.DisableBuildWarnings or false,
	}

	local theme = Themes[windowInfo.Theme] or Themes.Default
	local windowsTab = windowInfo.Name

	Nova.ActiveWindows += 1
	Nova.Theme = theme

	-- Main window frame
	local Window = Instance.new("Frame")
	Window.Name = "Window"
	Window.Size = UDim2.new(0, 600, 0, 420)
	Window.Position = UDim2.new(0.5, -300, 0.5, -210)
	Window.BackgroundColor3 = theme.Window.BackgroundColor
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Parent = ScreenGui

	addCorner(Window, 10)

	-- Window border stroke
	addStroke(Window, theme.Window.BorderColor, 1.5)

	-- Shadow
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.Size = UDim2.new(1, 60, 1, 60)
	Shadow.Position = UDim2.new(0, -30, 0, -30)
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://1316045217"
	Shadow.ImageColor3 = theme.Window.ShadowColor
	Shadow.ImageTransparency = theme.Window.ShadowTransparency or 0.6
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	Shadow.ZIndex = 0
	Shadow.Parent = Window

	-- Window appear animation
	Window.Size = UDim2.new(0, 0, 0, 0)
	Window.Position = UDim2.new(0.5, 0, 0.5, 0)
	tween(Window, {Size = UDim2.new(0, 600, 0, 420), Position = UDim2.new(0.5, -300, 0.5, -210)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- Topbar
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 44)
	Topbar.BackgroundColor3 = theme.Window.TopbarColor
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Window

	local TopbarCorner = addCorner(Topbar, 10)
	TopbarCorner:Destroy()

	local TopbarCorner2 = Instance.new("UICorner")
	TopbarCorner2.CornerRadius = UDim.new(0, 10)
	TopbarCorner2.Parent = Topbar

	-- Fix top corners
	local TopbarFix = Instance.new("Frame")
	TopbarFix.Name = "TopbarFix"
	TopbarFix.Size = UDim2.new(1, 0, 0, 10)
	TopbarFix.Position = UDim2.new(0, 0, 1, -10)
	TopbarFix.BackgroundColor3 = theme.Window.TopbarColor
	TopbarFix.BorderSizePixel = 0
	TopbarFix.Parent = Topbar

	local TopbarGradient = addGradient(Topbar, theme.Window.AccentGradientTop, theme.Window.AccentGradientBottom, 0)
	TopbarGradient.Transparency = NumberSequence.new(0.85)

	-- Title
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 14, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = windowInfo.Name
	TitleLabel.TextColor3 = theme.Window.TitleColor
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Topbar

	-- Close button
	local CloseButton = Instance.new("ImageButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 28, 0, 28)
	CloseButton.Position = UDim2.new(1, -36, 0, 8)
	CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	CloseButton.BorderSizePixel = 0
	CloseButton.Image = "rbxassetid://6031094678"
	CloseButton.ImageColor3 = Color3.fromRGB(180, 180, 200)
	CloseButton.Parent = Topbar

	local CloseCorner = addCorner(CloseButton, 6)

	CloseButton.MouseEnter:Connect(function()
		tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(220, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
	end)
	CloseButton.MouseLeave:Connect(function()
		tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 50), ImageColor3 = Color3.fromRGB(180, 180, 200)}, 0.15)
	end)

	-- Tabs container (left sidebar)
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 160, 1, -44)
	TabContainer.Position = UDim2.new(0, 0, 0, 44)
	TabContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	TabContainer.BorderSizePixel = 0
	TabContainer.Parent = Window

	local TabPadding = addPadding(TabContainer, 6)

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Name = "TabList"
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 2)
	TabListLayout.Parent = TabContainer

	-- Content area
	local ContentContainer = Instance.new("ScrollingFrame")
	ContentContainer.Name = "Content"
	ContentContainer.Size = UDim2.new(1, -160, 1, -44)
	ContentContainer.Position = UDim2.new(0, 160, 0, 44)
	ContentContainer.BackgroundColor3 = theme.Window.BackgroundColor
	ContentContainer.BorderSizePixel = 0
	ContentContainer.ScrollBarThickness = 4
	ContentContainer.ScrollBarImageColor3 = theme.Window.AccentColor
	ContentContainer.ScrollBarImageTransparency = 0.6
	ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ContentContainer.Parent = Window

	local ContentPadding = Instance.new("UIPadding")
	ContentPadding.PaddingLeft = UDim.new(0, 10)
	ContentPadding.PaddingRight = UDim.new(0, 10)
	ContentPadding.PaddingTop = UDim.new(0, 10)
	ContentPadding.PaddingBottom = UDim.new(0, 10)
	ContentPadding.Parent = ContentContainer

	local ContentListLayout = Instance.new("UIListLayout")
	ContentListLayout.Name = "ContentList"
	ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentListLayout.Padding = UDim.new(0, 6)
	ContentListLayout.Parent = ContentContainer

	ContentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentListLayout.AbsoluteContentSize.Y + 20)
	end)

	makeDraggable(Window, Topbar)

	-- Tab management
	local Tabs = {}
	local ActiveTab = nil

	local TabObject = {}
	TabObject.Tabs = Tabs
	TabObject.ActiveTab = ActiveTab
	TabObject.WindowRef = Window

	--[[
		CREATE TAB
	]]
	function TabObject:CreateTab(name, icon)
		local tabTheme = theme.Tab

		local tabButton = Instance.new("ImageButton")
		tabButton.Name = "Tab_" .. name
		tabButton.Size = UDim2.new(1, 0, 0, 36)
		tabButton.BackgroundColor3 = tabTheme.BackgroundColor
		tabButton.BackgroundTransparency = 1
		tabButton.BorderSizePixel = 0
		tabButton.ImageTransparency = 1
		tabButton.Parent = TabContainer

		local TabButtonCorner = addCorner(tabButton, 6)

		local iconLabel
		if icon and icon ~= 0 then
			iconLabel = Instance.new("ImageLabel")
			iconLabel.Name = "Icon"
			iconLabel.Size = UDim2.new(0, 18, 0, 18)
			iconLabel.Position = UDim2.new(0, 8, 0.5, -9)
			iconLabel.BackgroundTransparency = 1
			iconLabel.Image = getIcon(icon)
			iconLabel.ImageColor3 = tabTheme.TextColor
			iconLabel.Parent = tabButton

			local iconLabel2 = iconLabel:Clone()
			iconLabel2.Name = "IconActive"
			iconLabel2.ImageColor3 = tabTheme.SelectedTextColor
			iconLabel2.ImageTransparency = 1
			iconLabel2.Parent = tabButton
		end

		local tabLabel = Instance.new("TextLabel")
		tabLabel.Name = "Label"
		tabLabel.Size = UDim2.new(1, -32, 1, 0)
		tabLabel.Position = icon and UDim2.new(0, 32, 0, 0) or UDim2.new(0, 10, 0, 0)
		tabLabel.BackgroundTransparency = 1
		tabLabel.Text = name
		tabLabel.TextColor3 = tabTheme.TextColor
		tabLabel.Font = Enum.Font.Gotham
		tabLabel.TextSize = 14
		tabLabel.TextXAlignment = Enum.TextXAlignment.Left
		tabLabel.Parent = tabButton

		local tabLabelActive = tabLabel:Clone()
		tabLabelActive.Name = "LabelActive"
		tabLabelActive.TextColor3 = tabTheme.SelectedTextColor
		tabLabelActive.TextTransparency = 1
		tabLabelActive.Parent = tabButton

		-- Selection indicator
		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator"
		indicator.Size = UDim2.new(0, 3, 0, 0)
		indicator.Position = UDim2.new(0, 0, 0.5, 0)
		indicator.BackgroundColor3 = tabTheme.SelectedColor
		indicator.BorderSizePixel = 0
		indicator.Parent = tabButton

		addCorner(indicator, 2)

		-- Content frame for this tab
		local tabContent = Instance.new("Frame")
		tabContent.Name = "TabContent_" .. name
		tabContent.Size = UDim2.new(1, 0, 0, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.BorderSizePixel = 0
		tabContent.Visible = false
		tabContent.Parent = ContentContainer

		local tabContentListLayout = Instance.new("UIListLayout")
		tabContentListLayout.Name = "ContentList"
		tabContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabContentListLayout.Padding = UDim.new(0, 6)
		tabContentListLayout.Parent = tabContent

		tabContentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabContent.Size = UDim2.new(1, 0, 0, tabContentListLayout.AbsoluteContentSize.Y)
		end)

		local tabInfo = {
			Name = name,
			Button = tabButton,
			Content = tabContent,
			Icon = icon,
			Elements = {},
		}

		Tabs[name] = tabInfo

		-- Tab element creation API
		local TabElementAPI = {}
		TabElementAPI.TabInfo = tabInfo
		TabElementAPI.Theme = theme

		--[[
			CREATE SECTION
		]]
		function TabElementAPI:CreateSection(name)
			local sectionTheme = theme.Section

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = "Section_" .. name
			sectionFrame.Size = UDim2.new(1, 0, 0, 28)
			sectionFrame.BackgroundTransparency = 1
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Parent = tabContent

			local line = Instance.new("Frame")
			line.Name = "Line"
			line.Size = UDim2.new(1, 0, 0, 1)
			line.Position = UDim2.new(0, 0, 0.5, 0)
			line.BackgroundColor3 = sectionTheme.LineColor
			line.BorderSizePixel = 0
			line.Parent = sectionFrame

			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(0, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = "  " .. name
			label.TextColor3 = sectionTheme.TextColor
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.AutomaticSize = Enum.AutomaticSize.X
			label.Parent = sectionFrame

			return sectionFrame
		end

		--[[
			ELEMENT: BUTTON
		]]
		function TabElementAPI:CreateButton(config)
			config = config or {}
			local elemTheme = theme.Element

			local elemFrame = Instance.new("ImageButton")
			elemFrame.Name = "Button_" .. (config.Name or "Button")
			elemFrame.Size = UDim2.new(1, 0, 0, 44)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BackgroundTransparency = 0
			elemFrame.BorderSizePixel = 0
			elemFrame.AutoButtonColor = false
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(1, -24, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Button"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = elemFrame

			local arrow = Instance.new("ImageLabel")
			arrow.Name = "Arrow"
			arrow.Size = UDim2.new(0, 16, 0, 16)
			arrow.Position = UDim2.new(1, -24, 0.5, -8)
			arrow.BackgroundTransparency = 1
			arrow.Image = "rbxassetid://6031094678"
			arrow.ImageColor3 = elemTheme.DescriptionColor
			arrow.Rotation = 45
			arrow.Parent = elemFrame

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)
			elemFrame.MouseButton1Click:Connect(function()
				local ok, err = pcall(config.Callback or function() end)
				if not ok and not windowInfo.DisableBuildWarnings then
					warn("Nova: Button callback error:", err)
				end
				createRipple(elemFrame, 0, 0)
			end)

			return elemFrame
		end

		--[[
			ELEMENT: TOGGLE
		]]
		function TabElementAPI:CreateToggle(config)
			config = config or {}
			local elemTheme = theme.Element
			local currentValue = config.CurrentValue or false
			local flag = config.Flag

			local elemFrame = Instance.new("Frame")
			elemFrame.Name = "Toggle_" .. (config.Name or "Toggle")
			elemFrame.Size = UDim2.new(1, 0, 0, 44)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BorderSizePixel = 0
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(1, -60, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Toggle"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextTruncate = Enum.TextTruncate.AtEnd
			title.Parent = elemFrame

			-- Toggle switch
			local toggleBg = Instance.new("Frame")
			toggleBg.Name = "ToggleBg"
			toggleBg.Size = UDim2.new(0, 44, 0, 22)
			toggleBg.Position = UDim2.new(1, -52, 0.5, -11)
			toggleBg.BackgroundColor3 = currentValue and elemTheme.ToggleOn or elemTheme.ToggleOff
			toggleBg.BorderSizePixel = 0
			toggleBg.Parent = elemFrame

			local toggleBgCorner = addCorner(toggleBg, 11)

			local toggleKnob = Instance.new("Frame")
			toggleKnob.Name = "ToggleKnob"
			toggleKnob.Size = UDim2.new(0, 18, 0, 18)
			toggleKnob.Position = currentValue and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleKnob.BorderSizePixel = 0
			toggleKnob.Parent = toggleBg

			local toggleKnobCorner = addCorner(toggleKnob, 9)

			-- Description
			local desc
			if config.Description then
				desc = Instance.new("TextLabel")
				desc.Name = "Description"
				desc.Size = UDim2.new(1, -60, 0, 16)
				desc.Position = UDim2.new(0, 12, 0, 22)
				desc.BackgroundTransparency = 1
				desc.Text = config.Description
				desc.TextColor3 = elemTheme.DescriptionColor
				desc.Font = Enum.Font.Gotham
				desc.TextSize = 12
				desc.TextXAlignment = Enum.TextXAlignment.Left
				desc.TextTruncate = Enum.TextTruncate.AtEnd
				desc.Parent = elemFrame
				elemFrame.Size = UDim2.new(1, 0, 0, 60)
			end

			-- Callback
			local function updateToggle(val)
				currentValue = val
				tween(toggleBg, {BackgroundColor3 = val and elemTheme.ToggleOn or elemTheme.ToggleOff}, 0.2)
				tween(toggleKnob, {Position = val and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				if flag then
					Nova.Flags[flag] = val
				end
				local ok, err = pcall(config.Callback or function() end, val)
				if not ok and not windowInfo.DisableBuildWarnings then
					warn("Nova: Toggle callback error:", err)
				end
			end

			local hoverBg = false
			elemFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					updateToggle(not currentValue)
					createRipple(toggleBg, toggleBg.AbsoluteSize.X / 2, toggleBg.AbsoluteSize.Y / 2)
				end
			end)

			toggleBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					updateToggle(not currentValue)
					createRipple(toggleBg, toggleBg.AbsoluteSize.X / 2, toggleBg.AbsoluteSize.Y / 2)
				end
			end)

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)

			-- Set value method
			local elementObj = {
				Frame = elemFrame,
				SetValue = function(val)
					updateToggle(val)
				end,
				GetValue = function()
					return currentValue
				end,
				CurrentValue = currentValue,
			}
			tabInfo.Elements[#tabInfo.Elements + 1] = elementObj

			if flag then
				Nova.Flags[flag] = currentValue
			end

			return elementObj
		end

		--[[
			ELEMENT: SLIDER
		]]
		function TabElementAPI:CreateSlider(config)
			config = config or {}
			local elemTheme = theme.Element
			local min = config.Min or 0
			local max = config.Max or 100
			local currentValue = config.CurrentValue or 0
			local suffix = config.Suffix or ""
			local flag = config.Flag

			currentValue = math.clamp(currentValue, min, max)
			local ratio = (currentValue - min) / (max - min)

			local elemFrame = Instance.new("Frame")
			elemFrame.Name = "Slider_" .. (config.Name or "Slider")
			elemFrame.Size = UDim2.new(1, 0, 0, 56)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BorderSizePixel = 0
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(1, -24, 0, 18)
			title.Position = UDim2.new(0, 12, 0, 8)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Slider"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = elemFrame

			local valueLabel = Instance.new("TextLabel")
			valueLabel.Name = "Value"
			valueLabel.Size = UDim2.new(0, 60, 0, 18)
			valueLabel.Position = UDim2.new(1, -68, 0, 8)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Text = tostring(math.floor(currentValue)) .. suffix
			valueLabel.TextColor3 = elemTheme.DescriptionColor
			valueLabel.Font = Enum.Font.Gotham
			valueLabel.TextSize = 13
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.Parent = elemFrame

			-- Slider track
			local sliderTrack = Instance.new("Frame")
			sliderTrack.Name = "Track"
			sliderTrack.Size = UDim2.new(1, -24, 0, 6)
			sliderTrack.Position = UDim2.new(0, 12, 1, -16)
			sliderTrack.BackgroundColor3 = elemTheme.SliderBackground
			sliderTrack.BorderSizePixel = 0
			sliderTrack.Parent = elemFrame

			local trackCorner = addCorner(sliderTrack, 3)

			local sliderFill = Instance.new("Frame")
			sliderFill.Name = "Fill"
			sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
			sliderFill.BackgroundColor3 = elemTheme.SliderFill
			sliderFill.BorderSizePixel = 0
			sliderFill.Parent = sliderTrack

			local fillCorner = addCorner(sliderFill, 3)

			local sliderKnob = Instance.new("Frame")
			sliderKnob.Name = "Knob"
			sliderKnob.Size = UDim2.new(0, 14, 0, 14)
			sliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
			sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sliderKnob.BorderSizePixel = 0
			sliderKnob.Parent = sliderTrack

			local knobCorner = addCorner(sliderKnob, 7)

			local dragging = false

			local function updateSlider(inputPos)
				local trackPos = sliderTrack.AbsolutePosition
				local trackSize = sliderTrack.AbsoluteSize.X
				local localX = math.clamp(inputPos - trackPos.X, 0, trackSize)
				ratio = localX / trackSize
				currentValue = math.floor(min + (max - min) * ratio)

				sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
				sliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
				valueLabel.Text = tostring(currentValue) .. suffix

				if flag then
					Nova.Flags[flag] = currentValue
				end
			end

			local function finishSlider()
				dragging = false
				local ok, err = pcall(config.Callback or function() end, currentValue)
				if not ok and not windowInfo.DisableBuildWarnings then
					warn("Nova: Slider callback error:", err)
				end
			end

			sliderTrack.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateSlider(input.Position.X)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(input.Position.X)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
					finishSlider()
				end
			end)

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)

			local elementObj = {
				Frame = elemFrame,
				SetValue = function(val)
					val = math.clamp(val, min, max)
					ratio = (val - min) / (max - min)
					currentValue = val
					sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
					sliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
					valueLabel.Text = tostring(currentValue) .. suffix
				end,
				GetValue = function()
					return currentValue
				end,
				CurrentValue = currentValue,
			}
			tabInfo.Elements[#tabInfo.Elements + 1] = elementObj

			if flag then
				Nova.Flags[flag] = currentValue
			end

			return elementObj
		end

		--[[
			ELEMENT: DROPDOWN
		]]
		function TabElementAPI:CreateDropdown(config)
			config = config or {}
			local elemTheme = theme.Element
			local options = config.Options or {}
			local currentOption = config.CurrentOption or (options[1] or "")
			local flag = config.Flag
			local isOpen = false

			local elemFrame = Instance.new("Frame")
			elemFrame.Name = "Dropdown_" .. (config.Name or "Dropdown")
			elemFrame.Size = UDim2.new(1, 0, 0, 44)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BorderSizePixel = 0
			elemFrame.ClipsDescendants = true
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(0.5, -12, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Dropdown"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = elemFrame

			local chevron = Instance.new("ImageLabel")
			chevron.Name = "Chevron"
			chevron.Size = UDim2.new(0, 14, 0, 14)
			chevron.Position = UDim2.new(1, -22, 0.5, -7)
			chevron.BackgroundTransparency = 1
			chevron.Image = "rbxassetid://6031094678"
			chevron.ImageColor3 = elemTheme.DescriptionColor
			chevron.Rotation = 0
			chevron.Parent = elemFrame

			local selectedLabel = Instance.new("TextLabel")
			selectedLabel.Name = "Selected"
			selectedLabel.Size = UDim2.new(0.5, -10, 1, 0)
			selectedLabel.Position = UDim2.new(0.5, 2, 0, 0)
			selectedLabel.BackgroundTransparency = 1
			selectedLabel.Text = currentOption
			selectedLabel.TextColor3 = elemTheme.DescriptionColor
			selectedLabel.Font = Enum.Font.Gotham
			selectedLabel.TextSize = 13
			selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
			selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
			selectedLabel.Parent = elemFrame

			-- Dropdown list
			local dropdownList = Instance.new("Frame")
			dropdownList.Name = "DropdownList"
			dropdownList.Size = UDim2.new(1, 0, 0, 0)
			dropdownList.Position = UDim2.new(0, 0, 0, 44)
			dropdownList.BackgroundColor3 = elemTheme.DropdownBackground
			dropdownList.BorderSizePixel = 0
			dropdownList.ClipsDescendants = true
			dropdownList.Visible = false
			dropdownList.Parent = elemFrame

			addCorner(dropdownList, 8)
			addStroke(dropdownList, elemTheme.BorderColor)

			local dropdownListLayout = Instance.new("UIListLayout")
			dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			dropdownListLayout.Padding = UDim.new(0, 2)
			dropdownListLayout.Parent = dropdownList

			local dropdownPadding = addPadding(dropdownList, 4)

			local optionButtons = {}

			local function rebuildOptions()
				for _, child in pairs(dropdownList:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				optionButtons = {}

				for _, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Name = "Option_" .. tostring(opt)
					optBtn.Size = UDim2.new(1, 0, 0, 32)
					optBtn.BackgroundColor3 = (opt == currentOption) and elemTheme.DropdownHover or Color3.fromRGB(0, 0, 0)
					optBtn.BackgroundTransparency = (opt == currentOption) and 0.4 or 1
					optBtn.BorderSizePixel = 0
					optBtn.Text = tostring(opt)
					optBtn.TextColor3 = (opt == currentOption) and theme.Window.AccentColor or elemTheme.TitleColor
					optBtn.Font = Enum.Font.Gotham
					optBtn.TextSize = 13
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.AutoButtonColor = false
					optBtn.Parent = dropdownList

					addCorner(optBtn, 4)

					optBtn.MouseEnter:Connect(function()
						tween(optBtn, {BackgroundTransparency = 0.2, BackgroundColor3 = elemTheme.DropdownHover}, 0.1)
					end)
					optBtn.MouseLeave:Connect(function()
						tween(optBtn, {BackgroundTransparency = (opt == currentOption) and 0.4 or 1, BackgroundColor3 = (opt == currentOption) and elemTheme.DropdownHover or Color3.fromRGB(0, 0, 0)}, 0.1)
					end)
					optBtn.MouseButton1Click:Connect(function()
						currentOption = opt
						selectedLabel.Text = tostring(opt)
						if flag then
							Nova.Flags[flag] = opt
						end
						local ok, err = pcall(config.Callback or function() end, opt)
						if not ok and not windowInfo.DisableBuildWarnings then
							warn("Nova: Dropdown callback error:", err)
						end
						rebuildOptions()
						toggleDropdown()
					end)

					optionButtons[opt] = optBtn
				end

				local listHeight = #options * 34 + 8
				dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
			end

			local function toggleDropdown()
				isOpen = not isOpen
				dropdownList.Visible = true
				if isOpen then
					local newHeight = #options * 34 + 8
					elemFrame.Size = UDim2.new(1, 0, 0, 44 + newHeight + 4)
					dropdownList.Size = UDim2.new(1, 0, 0, newHeight)
					tween(dropdownList, {Size = UDim2.new(1, 0, 0, newHeight)}, 0.2)
					tween(chevron, {Rotation = 180}, 0.2)
				else
					local newHeight = 44
					tween(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
					tween(chevron, {Rotation = 0}, 0.2)
					task.delay(0.16, function()
						if dropdownList then
							dropdownList.Visible = false
						end
					end)
					elemFrame.Size = UDim2.new(1, 0, 0, 44)
				end
			end

			rebuildOptions()

			elemFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					toggleDropdown()
				end
			end)

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)

			local elementObj = {
				Frame = elemFrame,
				SetValue = function(val)
					if table.find(options, val) then
						currentOption = val
						selectedLabel.Text = tostring(val)
						rebuildOptions()
					end
				end,
				GetValue = function()
					return currentOption
				end,
				CurrentOption = currentOption,
				CurrentValue = currentOption,
			}
			tabInfo.Elements[#tabInfo.Elements + 1] = elementObj

			if flag then
				Nova.Flags[flag] = currentOption
			end

			return elementObj
		end

		--[[
			ELEMENT: TEXTBOX
		]]
		function TabElementAPI:CreateTextbox(config)
			config = config or {}
			local elemTheme = theme.Element
			local currentText = config.CurrentText or ""
			local placeholder = config.PlaceholderText or "Enter text..."
			local removeText = config.RemoveTextAfterFocusLost or false
			local flag = config.Flag

			local elemFrame = Instance.new("Frame")
			elemFrame.Name = "Textbox_" .. (config.Name or "Textbox")
			elemFrame.Size = UDim2.new(1, 0, 0, 44)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BorderSizePixel = 0
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(0.4, -12, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Textbox"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = elemFrame

			local textBox = Instance.new("TextBox")
			textBox.Name = "Input"
			textBox.Size = UDim2.new(0.6, -16, 0, 30)
			textBox.Position = UDim2.new(0.4, 2, 0.5, -15)
			textBox.BackgroundColor3 = elemTheme.InputBackground
			textBox.BorderSizePixel = 0
			textBox.Text = currentText
			textBox.PlaceholderText = placeholder
			textBox.TextColor3 = elemTheme.InputTextColor
			textBox.PlaceholderColor3 = elemTheme.PlaceholderColor
			textBox.Font = Enum.Font.Gotham
			textBox.TextSize = 14
			textBox.ClearTextOnFocus = false
			textBox.Parent = elemFrame

			addCorner(textBox, 6)

			textBox.FocusLost:Connect(function(enterPressed)
				currentText = textBox.Text
				if removeText then
					textBox.Text = ""
				end
				if flag then
					Nova.Flags[flag] = currentText
				end
				local ok, err = pcall(config.Callback or function() end, currentText)
				if not ok and not windowInfo.DisableBuildWarnings then
					warn("Nova: Textbox callback error:", err)
				end
			end)

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)

			local elementObj = {
				Frame = elemFrame,
				SetValue = function(val)
					currentText = tostring(val)
					textBox.Text = currentText
				end,
				GetValue = function()
					return currentText
				end,
				CurrentValue = currentText,
			}
			tabInfo.Elements[#tabInfo.Elements + 1] = elementObj

			if flag then
				Nova.Flags[flag] = currentText
			end

			return elementObj
		end

		--[[
			ELEMENT: KEYBIND
		]]
		function TabElementAPI:CreateKeybind(config)
			config = config or {}
			local elemTheme = theme.Element
			local currentKey = config.CurrentKeybind or Enum.KeyCode.F
			local holdToInteract = config.HoldToInteract or false
			local flag = config.Flag
			local isListening = false
			local isHolding = false

			local elemFrame = Instance.new("Frame")
			elemFrame.Name = "Keybind_" .. (config.Name or "Keybind")
			elemFrame.Size = UDim2.new(1, 0, 0, 44)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BorderSizePixel = 0
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(1, -80, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Keybind"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextTruncate = Enum.TextTruncate.AtEnd
			title.Parent = elemFrame

			local keyButton = Instance.new("TextButton")
			keyButton.Name = "KeyButton"
			keyButton.Size = UDim2.new(0, 60, 0, 28)
			keyButton.Position = UDim2.new(1, -68, 0.5, -14)
			keyButton.BackgroundColor3 = elemTheme.InputBackground
			keyButton.BorderSizePixel = 0
			keyButton.Text = currentKey.Name
			keyButton.TextColor3 = elemTheme.InputTextColor
			keyButton.Font = Enum.Font.Gotham
			keyButton.TextSize = 13
			keyButton.AutoButtonColor = false
			keyButton.Parent = elemFrame

			addCorner(keyButton, 6)

			local function keyToString(key)
				local name = key.Name
				if name:sub(1, 5) == "KEY_C" then
					return name:sub(6)
				end
				return name
			end

			keyButton.MouseButton1Click:Connect(function()
				isListening = true
				keyButton.Text = "..."
				keyButton.TextColor3 = theme.Window.AccentColor
			end)

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end

				if isListening and (input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3) then
					isListening = false
					if input.UserInputType == Enum.UserInputType.Keyboard then
						currentKey = input.KeyCode
					else
						currentKey = input.UserInputType
					end
					keyButton.Text = keyToString(currentKey)
					keyButton.TextColor3 = elemTheme.InputTextColor
					return
				end

				if not isListening then
					local pressed = false
					if currentKey.ClassName == "EnumItem" and currentKey.EnumType == Enum.KeyCode then
						pressed = input.KeyCode == currentKey
					elseif currentKey.ClassName == "EnumItem" and currentKey.EnumType == Enum.UserInputType then
						pressed = input.UserInputType == currentKey
					end

					if pressed then
						if holdToInteract then
							isHolding = true
						end
						local ok, err = pcall(config.Callback or function() end, currentKey, false)
						if not ok and not windowInfo.DisableBuildWarnings then
							warn("Nova: Keybind callback error:", err)
						end
					end
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if holdToInteract and isHolding then
					local released = false
					if currentKey.ClassName == "EnumItem" and currentKey.EnumType == Enum.KeyCode then
						released = input.KeyCode == currentKey
					elseif currentKey.ClassName == "EnumItem" and currentKey.EnumType == Enum.UserInputType then
						released = input.UserInputType == currentKey
					end
					if released then
						isHolding = false
						local ok, err = pcall(config.Callback or function() end, currentKey, true)
						if not ok and not windowInfo.DisableBuildWarnings then
							warn("Nova: Keybind callback error:", err)
						end
					end
				end
			end)

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)

			local elementObj = {
				Frame = elemFrame,
				SetValue = function(val)
					currentKey = val
					keyButton.Text = keyToString(val)
				end,
				GetValue = function()
					return currentKey
				end,
				CurrentKeybind = currentKey,
				CurrentValue = currentKey,
			}
			tabInfo.Elements[#tabInfo.Elements + 1] = elementObj

			if flag then
				Nova.Flags[flag] = currentKey
			end

			return elementObj
		end

		--[[
			ELEMENT: LABEL
		]]
		function TabElementAPI:CreateLabel(text)
			local elemTheme = theme.Element

			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(1, 0, 0, 28)
			label.BackgroundTransparency = 1
			label.Text = text or "Label"
			label.TextColor3 = elemTheme.TitleColor
			label.Font = Enum.Font.Gotham
			label.TextSize = 14
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextWrapped = true
			label.RichText = true
			label.Parent = tabContent

			return label
		end

		--[[
			ELEMENT: PARAGRAPH
		]]
		function TabElementAPI:CreateParagraph(config)
			config = config or {}
			local elemTheme = theme.Element

			local paragraphFrame = Instance.new("Frame")
			paragraphFrame.Name = "Paragraph_" .. (config.Title or "Paragraph")
			paragraphFrame.Size = UDim2.new(1, 0, 0, 0)
			paragraphFrame.BackgroundColor3 = elemTheme.BackgroundColor
			paragraphFrame.BorderSizePixel = 0
			paragraphFrame.Parent = tabContent

			addCorner(paragraphFrame, 8)
			addStroke(paragraphFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(1, -20, 0, 20)
			title.Position = UDim2.new(0, 10, 0, 10)
			title.BackgroundTransparency = 1
			title.Text = config.Title or "Information"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = paragraphFrame

			local content = Instance.new("TextLabel")
			content.Name = "Content"
			content.Size = UDim2.new(1, -20, 0, 0)
			content.Position = UDim2.new(0, 10, 0, 36)
			content.BackgroundTransparency = 1
			content.Text = config.Content or ""
			content.TextColor3 = elemTheme.DescriptionColor
			content.Font = Enum.Font.Gotham
			content.TextSize = 13
			content.TextXAlignment = Enum.TextXAlignment.Left
			content.TextWrapped = true
			content.RichText = true
			content.Parent = paragraphFrame

			local contentHeight = content.TextBounds.Y + 10
			content.Size = UDim2.new(1, -20, 0, contentHeight)
			paragraphFrame.Size = UDim2.new(1, 0, 0, 36 + contentHeight + 10)

			return paragraphFrame
		end

		--[[
			ELEMENT: COLOR PICKER
		]]
		function TabElementAPI:CreateColorPicker(config)
			config = config or {}
			local elemTheme = theme.Element
			local currentColor = config.Color or Color3.fromRGB(255, 255, 255)
			local flag = config.Flag
			local isOpen = false

			local elemFrame = Instance.new("Frame")
			elemFrame.Name = "ColorPicker_" .. (config.Name or "ColorPicker")
			elemFrame.Size = UDim2.new(1, 0, 0, 44)
			elemFrame.BackgroundColor3 = elemTheme.BackgroundColor
			elemFrame.BorderSizePixel = 0
			elemFrame.ClipsDescendants = true
			elemFrame.Parent = tabContent

			addCorner(elemFrame, 8)
			addStroke(elemFrame, elemTheme.BorderColor)

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.Size = UDim2.new(1, -52, 1, 0)
			title.Position = UDim2.new(0, 12, 0, 0)
			title.BackgroundTransparency = 1
			title.Text = config.Name or "Color Picker"
			title.TextColor3 = elemTheme.TitleColor
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = elemFrame

			local colorPreview = Instance.new("ImageLabel")
			colorPreview.Name = "ColorPreview"
			colorPreview.Size = UDim2.new(0, 24, 0, 24)
			colorPreview.Position = UDim2.new(1, -32, 0.5, -12)
			colorPreview.BackgroundColor3 = currentColor
			colorPreview.BorderSizePixel = 0
			colorPreview.Image = "rbxassetid://2975267309"
			colorPreview.ImageColor3 = currentColor
			colorPreview.ScaleType = Enum.ScaleType.Slice
			colorPreview.Parent = elemFrame

			local previewCorner = addCorner(colorPreview, 6)

			-- Expanded color picker
			local colorPickerFrame = Instance.new("Frame")
			colorPickerFrame.Name = "ColorPickerPanel"
			colorPickerFrame.Size = UDim2.new(1, 0, 0, 180)
			colorPickerFrame.Position = UDim2.new(0, 0, 0, 44)
			colorPickerFrame.BackgroundColor3 = elemTheme.DropdownBackground
			colorPickerFrame.BorderSizePixel = 0
			colorPickerFrame.Visible = false
			colorPickerFrame.Parent = elemFrame

			addCorner(colorPickerFrame, 8)
			addStroke(colorPickerFrame, elemTheme.BorderColor)

			-- Hue/Saturation square
			local hueSatBox = Instance.new("ImageLabel")
			hueSatBox.Name = "HueSatBox"
			hueSatBox.Size = UDim2.new(0, 160, 1, -40)
			hueSatBox.Position = UDim2.new(0, 8, 0, 8)
			hueSatBox.BackgroundColor3 = currentColor
			hueSatBox.BorderSizePixel = 0
			hueSatBox.Image = "rbxassetid://4155801252"
			hueSatBox.Parent = colorPickerFrame

			local hueSatCorner = addCorner(hueSatBox, 6)

			local hueSatCursor = Instance.new("Frame")
			hueSatCursor.Name = "Cursor"
			hueSatCursor.Size = UDim2.new(0, 12, 0, 12)
			hueSatCursor.Position = UDim2.new(1, -6, 0, -6)
			hueSatCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hueSatCursor.BorderSizePixel = 0
			hueSatCursor.ZIndex = 5
			hueSatCursor.Parent = hueSatBox

			addCorner(hueSatCursor, 6)
			addStroke(hueSatCursor, Color3.fromRGB(0, 0, 0), 1.5)

			-- Hue slider
			local hueSlider = Instance.new("Frame")
			hueSlider.Name = "HueSlider"
			hueSlider.Size = UDim2.new(1, -184, 0, 12)
			hueSlider.Position = UDim2.new(0, 174, 0, 8)
			hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			hueSlider.BorderSizePixel = 0
			hueSlider.Parent = colorPickerFrame

			local hueGradient = Instance.new("UIGradient")
			hueGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
			})
			hueGradient.Parent = hueSlider
			addCorner(hueSlider, 6)

			local hueCursor = Instance.new("Frame")
			hueCursor.Name = "HueCursor"
			hueCursor.Size = UDim2.new(0, 8, 0, 18)
			hueCursor.Position = UDim2.new(1, -4, 0, -3)
			hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hueCursor.BorderSizePixel = 0
			hueCursor.ZIndex = 5
			hueCursor.Parent = hueSlider

			addCorner(hueCursor, 4)
			addStroke(hueCursor, Color3.fromRGB(0, 0, 0), 1.5)

			-- Hex input
			local hexBox = Instance.new("TextBox")
			hexBox.Name = "HexInput"
			hexBox.Size = UDim2.new(1, -184, 0, 24)
			hexBox.Position = UDim2.new(0, 174, 0, 26)
			hexBox.BackgroundColor3 = elemTheme.InputBackground
			hexBox.BorderSizePixel = 0
			hexBox.Text = "#" .. currentColor:ToHex()
			hexBox.TextColor3 = elemTheme.InputTextColor
			hexBox.PlaceholderColor3 = elemTheme.PlaceholderColor
			hexBox.Font = Enum.Font.Gotham
			hexBox.TextSize = 13
			hexBox.ClearTextOnFocus = true
			hexBox.Parent = colorPickerFrame

			addCorner(hexBox, 6)

			-- Color preview bar
			local previewBar = Instance.new("Frame")
			previewBar.Name = "PreviewBar"
			previewBar.Size = UDim2.new(1, -184, 0, 24)
			previewBar.Position = UDim2.new(0, 174, 0, 56)
			previewBar.BackgroundColor3 = currentColor
			previewBar.BorderSizePixel = 0
			previewBar.Parent = colorPickerFrame

			addCorner(previewBar, 6)

			-- Confirm button
			local confirmBtn = Instance.new("TextButton")
			confirmBtn.Name = "Confirm"
			confirmBtn.Size = UDim2.new(1, -184, 0, 28)
			confirmBtn.Position = UDim2.new(0, 174, 0, 86)
			confirmBtn.BackgroundColor3 = theme.Window.AccentColor
			confirmBtn.BorderSizePixel = 0
			confirmBtn.Text = "Apply"
			confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			confirmBtn.Font = Enum.Font.GothamSemibold
			confirmBtn.TextSize = 13
			confirmBtn.AutoButtonColor = false
			confirmBtn.Parent = colorPickerFrame

			addCorner(confirmBtn, 6)

			local h, s, v = currentColor:ToHSV()

			local function updateColorFromHS()
				local newColor = Color3.fromHSV(h, s, v)
				currentColor = newColor
				colorPreview.BackgroundColor3 = newColor
				colorPreview.ImageColor3 = newColor
				previewBar.BackgroundColor3 = newColor
				hueSatBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				hexBox.Text = "#" .. newColor:ToHex()
				hueSatCursor.Position = UDim2.new(s, -6, 1 - v, -6)
			end

			-- Hue dragging
			local hueDragging = false
			hueSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					hueDragging = true
					local pos = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
					h = pos
					hueCursor.Position = UDim2.new(pos, -4, 0, -3)
					updateColorFromHS()
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local pos = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
					h = pos
					hueCursor.Position = UDim2.new(pos, -4, 0, -3)
					updateColorFromHS()
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and hueDragging then
					hueDragging = false
				end
			end)

			-- Hue/Sat dragging
			local hsDragging = false
			hueSatBox.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					hsDragging = true
					local x = math.clamp((input.Position.X - hueSatBox.AbsolutePosition.X) / hueSatBox.AbsoluteSize.X, 0, 1)
					local y = math.clamp((input.Position.Y - hueSatBox.AbsolutePosition.Y) / hueSatBox.AbsoluteSize.Y, 0, 1)
					s = x
					v = 1 - y
					updateColorFromHS()
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if hsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local x = math.clamp((input.Position.X - hueSatBox.AbsolutePosition.X) / hueSatBox.AbsoluteSize.X, 0, 1)
					local y = math.clamp((input.Position.Y - hueSatBox.AbsolutePosition.Y) / hueSatBox.AbsoluteSize.Y, 0, 1)
					s = x
					v = 1 - y
					updateColorFromHS()
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and hsDragging then
					hsDragging = false
				end
			end)

			-- Hex input
			hexBox.FocusLost:Connect(function()
				local hex = hexBox.Text:gsub("#", "")
				local ok, color = pcall(Color3.fromHex, hex)
				if ok then
					currentColor = color
					h, s, v = color:ToHSV()
					updateColorFromHS()
					previewBar.BackgroundColor3 = currentColor
					hexBox.Text = "#" .. currentColor:ToHex()
				end
			end)

			-- Confirm
			confirmBtn.MouseButton1Click:Connect(function()
				if flag then
					Nova.Flags[flag] = currentColor
				end
				local ok, err = pcall(config.Callback or function() end, currentColor)
				if not ok and not windowInfo.DisableBuildWarnings then
					warn("Nova: ColorPicker callback error:", err)
				end
				toggleColorPicker()
			end)

			confirmBtn.MouseEnter:Connect(function()
				tween(confirmBtn, {BackgroundColor3 = theme.Window.AccentColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)}, 0.15)
			end)
			confirmBtn.MouseLeave:Connect(function()
				tween(confirmBtn, {BackgroundColor3 = theme.Window.AccentColor}, 0.15)
			end)

			-- Initial cursor position
			hueSatCursor.Position = UDim2.new(s, -6, 1 - v, -6)
			hueCursor.Position = UDim2.new(h, -4, 0, -3)
			hueSatBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

			local function toggleColorPicker()
				isOpen = not isOpen
				colorPickerFrame.Visible = true
				if isOpen then
					elemFrame.Size = UDim2.new(1, 0, 0, 44 + 188)
					tween(colorPickerFrame, {Size = UDim2.new(1, 0, 0, 180)}, 0.2)
				else
					tween(colorPickerFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
					task.delay(0.16, function()
						if colorPickerFrame then
							colorPickerFrame.Visible = false
						end
					end)
					elemFrame.Size = UDim2.new(1, 0, 0, 44)
				end
			end

			elemFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					-- Only toggle if clicking on the main frame, not child elements
					toggleColorPicker()
				end
			end)

			elemFrame.MouseEnter:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.HoverBackgroundColor}, 0.15)
			end)
			elemFrame.MouseLeave:Connect(function()
				tween(elemFrame, {BackgroundColor3 = elemTheme.BackgroundColor}, 0.15)
			end)

			local elementObj = {
				Frame = elemFrame,
				SetValue = function(val)
					currentColor = val
					h, s, v = val:ToHSV()
					colorPreview.BackgroundColor3 = val
					colorPreview.ImageColor3 = val
					previewBar.BackgroundColor3 = val
					hexBox.Text = "#" .. val:ToHex()
					hueSatBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					hueSatCursor.Position = UDim2.new(s, -6, 1 - v, -6)
					hueCursor.Position = UDim2.new(h, -4, 0, -3)
				end,
				GetValue = function()
					return currentColor
				end,
				CurrentValue = currentColor,
			}
			tabInfo.Elements[#tabInfo.Elements + 1] = elementObj

			if flag then
				Nova.Flags[flag] = currentColor
			end

			return elementObj
		end

		-- Tab switching
		tabButton.MouseButton1Click:Connect(function()
			for _, t in pairs(Tabs) do
				if t.Button ~= tabButton then
					tween(t.Button, {BackgroundTransparency = 1}, 0.15)
					local label = t.Button:FindFirstChild("Label")
					if label then
						tween(label, {TextTransparency = 0, TextColor3 = tabTheme.TextColor}, 0.15)
					end
					local labelActive = t.Button:FindFirstChild("LabelActive")
					if labelActive then
						labelActive.TextTransparency = 1
					end
					local icon = t.Button:FindFirstChild("Icon")
					if icon then
						tween(icon, {ImageTransparency = 0, ImageColor3 = tabTheme.TextColor}, 0.15)
					end
					local iconActive = t.Button:FindFirstChild("IconActive")
					if iconActive then
						iconActive.ImageTransparency = 1
					end
					local ind = t.Button:FindFirstChild("Indicator")
					if ind then
						tween(ind, {Size = UDim2.new(0, 3, 0, 0)}, 0.15)
					end
					t.Content.Visible = false
				end
			end

			tween(tabButton, {BackgroundTransparency = 0, BackgroundColor3 = tabTheme.BackgroundColor}, 0.15)
			local label = tabButton:FindFirstChild("Label")
			if label then
				tween(label, {TextTransparency = 1}, 0.15)
			end
			local labelActive = tabButton:FindFirstChild("LabelActive")
			if labelActive then
				labelActive.TextTransparency = 0
				labelActive.TextColor3 = tabTheme.SelectedTextColor
			end
			local icon = tabButton:FindFirstChild("Icon")
			if icon then
				tween(icon, {ImageTransparency = 1}, 0.15)
			end
			local iconActive = tabButton:FindFirstChild("IconActive")
			if iconActive then
				iconActive.ImageTransparency = 0
			end
			local ind = tabButton:FindFirstChild("Indicator")
			if ind then
				tween(ind, {Size = UDim2.new(0, 3, 0, 18)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end

			tabContent.Visible = true
			ActiveTab = tabInfo
		end)

		-- Activate if first tab
		if next(Tabs) == nil then
			task.spawn(function()
				task.wait(0.1)
				tabButton.MouseButton1Click:Fire()
			end)
		end

		return TabElementAPI
	end

	--[[
		WINDOW METHODS
	]]
	function TabObject:SelectTab(name)
		local tab = Tabs[name]
		if tab then
			tab.Button.MouseButton1Click:Fire()
		end
	end

	function TabObject:Destroy()
		Window:Destroy()
	end

	function TabObject:SetTheme(themeName)
		if Themes[themeName] then
			windowInfo.Theme = themeName
			theme = Themes[themeName]
			Nova.Theme = theme

			Window.BackgroundColor3 = theme.Window.BackgroundColor
			Shadow.ImageColor3 = theme.Window.ShadowColor
			Shadow.ImageTransparency = theme.Window.ShadowTransparency or 0.6
			Window:FindFirstChild("UIStroke", true).Color = theme.Window.BorderColor
			Topbar.BackgroundColor3 = theme.Window.TopbarColor
			TopbarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, theme.Window.AccentGradientTop), ColorSequenceKeypoint.new(1, theme.Window.AccentGradientBottom)})
			TitleLabel.TextColor3 = theme.Window.TitleColor
			ContentContainer.BackgroundColor3 = theme.Window.BackgroundColor
			ContentContainer.ScrollBarImageColor3 = theme.Window.AccentColor
		end
	end

	function TabObject:SetName(name)
		windowInfo.Name = name
		TitleLabel.Text = name
	end

	--[[
		CONFIGURATION SAVING
	]]
	function TabObject:SaveConfiguration()
		local config = windowInfo.ConfigurationSaving
		if not config.Enabled then return end
		local folder = config.FolderName or "NovaUI"
		local fileName = config.FileName or "Config"
		local data = HttpService:JSONEncode(Nova.Flags)
		if IsExecutor and syn and syn.writefile then
			syn.writefile(folder .. "/" .. fileName .. ".json", data)
		elseif writefile then
			writefile(folder .. "/" .. fileName .. ".json", data)
		end
	end

	function TabObject:LoadConfiguration()
		local config = windowInfo.ConfigurationSaving
		if not config.Enabled then return end
		local folder = config.FolderName or "NovaUI"
		local fileName = config.FileName or "Config"
		local data
		if IsExecutor and syn and syn.readfile then
			local ok, err = pcall(syn.readfile, folder .. "/" .. fileName .. ".json")
			if ok then data = err end
		elseif readfile then
			local ok, err = pcall(readfile, folder .. "/" .. fileName .. ".json")
			if ok then data = err end
		end
		if data then
			local ok, decoded = pcall(HttpService.JSONDecode, HttpService, data)
			if ok and type(decoded) == "table" then
				for k, v in pairs(decoded) do
					Nova.Flags[k] = v
				end
			end
		end
	end

	-- Discord
	if windowInfo.Discord and windowInfo.Discord.Enabled then
		task.spawn(function()
			local url = "https://discord.com/api/v9/invites/" .. windowInfo.Discord.Invite
			if syn and syn.request then
				syn.request({Url = url, Method = "GET"})
			elseif request then
				request({Url = url, Method = "GET"})
			end
		end)
	end

	return TabObject
end

--[[
	DESTROY ALL
]]
function Nova:Destroy()
	for _, child in pairs(ScreenGui:GetChildren()) do
		child:Destroy()
	end
end

--[[
	SET THEME GLOBAL
]]
function Nova:SetTheme(themeName)
	if Themes[themeName] then
		self.Theme = Themes[themeName]
	end
end

--[[
	LOAD CONFIGURATION
]]
function Nova:LoadConfiguration()
	for _, tabObj in pairs(self.OpenWindows or {}) do
		if tabObj.LoadConfiguration then
			tabObj:LoadConfiguration()
		end
	end
end

return Nova
