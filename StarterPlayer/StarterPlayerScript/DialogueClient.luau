-- LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local DialogueEvent = ReplicatedStorage:WaitForChild("DialogueEvent")

-- Build the GUI once
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DialogueGui"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 200)
frame.Position = UDim2.new(0.5, -210, 0.75, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local promptLabel = Instance.new("TextLabel")
promptLabel.Size = UDim2.new(1, -20, 0, 60)
promptLabel.Position = UDim2.new(0, 10, 0, 10)
promptLabel.BackgroundTransparency = 1
promptLabel.TextColor3 = Color3.new(1, 1, 1)
promptLabel.TextWrapped = true
promptLabel.TextSize = 18
promptLabel.Font = Enum.Font.SourceSansBold
promptLabel.Parent = frame

-- Text input row (for free-typed answers)
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -100, 0, 36)
textBox.Position = UDim2.new(0, 10, 0, 80)
textBox.PlaceholderText = "Type your answer..."
textBox.ClearTextOnFocus = false
textBox.Parent = frame

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0, 80, 0, 36)
submitButton.Position = UDim2.new(1, -90, 0, 80)
submitButton.Text = "Send"
submitButton.Parent = frame

-- Container for choice buttons
local choiceContainer = Instance.new("Frame")
choiceContainer.Size = UDim2.new(1, -20, 0, 100)
choiceContainer.Position = UDim2.new(0, 10, 0, 80)
choiceContainer.BackgroundTransparency = 1
choiceContainer.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = choiceContainer

local function clearChoices()
	for _, child in ipairs(choiceContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function showTextInput(show)
	textBox.Visible = show
	submitButton.Visible = show
end

local function showChoices(options)
	clearChoices()
	for _, optionText in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Text = optionText
		btn.Parent = choiceContainer

		btn.MouseButton1Click:Connect(function()
			DialogueEvent:FireServer(optionText)
			choiceContainer.Visible = false
		end)
	end
	choiceContainer.Visible = true
end

submitButton.MouseButton1Click:Connect(function()
	local text = textBox.Text
	if text and text ~= "" then
		DialogueEvent:FireServer(text)
		textBox.Text = ""
		showTextInput(false)
	end
end)

-- Main listener: server tells us what to display
DialogueEvent.OnClientEvent:Connect(function(data)
	screenGui.Enabled = true
	promptLabel.Text = data.prompt

	if data.inputType == "text" then
		choiceContainer.Visible = false
		showTextInput(true)

	elseif data.inputType == "choice" then
		showTextInput(false)
		showChoices(data.options)

	elseif data.inputType == "end" then
		showTextInput(false)
		choiceContainer.Visible = false
		task.wait(3)
		screenGui.Enabled = false
	end
end)
