-- file for message generation
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local prompt = script.Parent
local Database = require(script.Parent.database)

local DialogueEvent = ReplicatedStorage:WaitForChild("DialogueEvent")

local conversations = {}

local function getConversation(player)
	local convo = conversations[player.UserId]
	if not convo then
		convo = { state = "Greeting", slots = {} }
		conversations[player.UserId] = convo
	end
	return convo
end

local function fillTemplate(text, slots)
	if not text then return "" end
	return (text:gsub("{(%w+)}", function(key)
		return slots[key] or ""
	end))
end

local function sendState(player, convo)
	local stateData = Database.States[convo.state]
	local promptText = fillTemplate(stateData.prompt, convo.slots)
	DialogueEvent:FireClient(player, {
		state = convo.state,
		prompt = promptText,
		inputType = stateData.inputType,
		options = stateData.options,
	})
end

-- debounce so a rapid double-trigger doesn't restart the convo mid-flow
local debounceByPlayer = {}

prompt.Triggered:Connect(function(player)
	if debounceByPlayer[player.UserId] then return end
	debounceByPlayer[player.UserId] = true
	task.delay(0.5, function()
		debounceByPlayer[player.UserId] = nil
	end)

	local convo = getConversation(player)
	convo.state = "Greeting"
	convo.slots = {}
	sendState(player, convo)
end)

DialogueEvent.OnServerEvent:Connect(function(player, response)
	local convo = getConversation(player)
	local stateData = Database.States[convo.state]
	if not stateData then return end

	if stateData.inputType == "text" then
		if convo.state == "Greeting" then
			local nameToStore = response
			local ok, filterResult = pcall(function()
				return TextService:FilterStringAsync(response, player.UserId)
			end)
			if ok then
				local ok2, filtered = pcall(function()
					return filterResult:GetNonChatStringForBroadcastAsync()
				end)
				if ok2 then nameToStore = filtered end
			end

			convo.slots.name = nameToStore
			convo.state = stateData.nextState
			sendState(player, convo)
		end

	elseif stateData.inputType == "choice" then
		local slotKey = (convo.state == "AskFeeling") and "feeling" or "reason"
		convo.slots[slotKey] = response

		local nextState = stateData.nextState
		if type(nextState) == "table" then
			nextState = nextState[response]
		end
		convo.state = nextState
		sendState(player, convo)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	conversations[player.UserId] = nil
	debounceByPlayer[player.UserId] = nil
end)
