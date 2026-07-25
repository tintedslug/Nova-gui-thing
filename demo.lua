local Nova = loadstring(game:HttpGet('https://raw.githubusercontent.com/tintedslug/Nova-gui-thing/refs/heads/main/source.lua'))()

local Window = Nova:CreateWindow({
	Name = "Nova Framework",
	Icon = 0,
	LoadingTitle = "Nova UI",
	LoadingSubtitle = "Framework Demo",
	Theme = "Default",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "NovaDemo",
		FileName = "Settings",
	},
	KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Elements")

MainTab:CreateButton({
	Name = "Test Notification",
	Callback = function()
		Nova:Notify({
			Title = "Hello",
			Content = "This is a notification",
			Duration = 3,
		})
	end,
})

MainTab:CreateToggle({
	Name = "Toggle Me",
	CurrentValue = false,
	Flag = "MainToggle",
	Callback = function(Value)
		print("Toggle:", Value)
	end,
})

MainTab:CreateDropdown({
	Name = "Theme",
	Options = {"Default", "Ocean", "Amethyst", "Bloom", "Ember"},
	CurrentOption = "Default",
	Flag = "SelectedTheme",
	Callback = function(Value)
		Window:SetTheme(Value)
	end,
})

MainTab:CreateTextbox({
	Name = "Input",
	PlaceholderText = "Type something...",
	Flag = "TextInput",
	Callback = function(Value)
		print("Input:", Value)
	end,
})

local KeybindTab = Window:CreateTab("Keys", 6031094678)

KeybindTab:CreateSection("Controls")

KeybindTab:CreateKeybind({
	Name = "Test Keybind",
	CurrentKeybind = Enum.KeyCode.F,
	Flag = "TestKey",
	Callback = function(Key, IsHold)
		print("Key:", Key.Name, "Hold:", IsHold)
	end,
})

KeybindTab:CreateColorPicker({
	Name = "Pick Color",
	Color = Color3.fromRGB(88, 101, 242),
	Flag = "PickColor",
	Callback = function(Color)
		print("Color:", Color:ToHex())
	end,
})

KeybindTab:CreateParagraph({
	Title = "Nova Framework",
	Content = "A modern Roblox GUI framework inspired by Rayfield. Built for performance.",
})

Window:LoadConfiguration()
print("Nova UI loaded!")
