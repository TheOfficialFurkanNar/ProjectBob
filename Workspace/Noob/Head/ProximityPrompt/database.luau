-- Database, you can extend this as you like. Don't forget that this is a ModuleScript.
local Database = {}

Database.States = {

	Greeting = {
		prompt = "Hi! Nice to see you. What's your name?",
		inputType = "text",
		nextState = "AskFeeling",
	},

	AskFeeling = {
		prompt = "How are you, {name}?",
		inputType = "choice",
		options = {"Good", "Bad"},
		nextState = {
			Good = "GoodFollowUp",
			Bad = "BadFollowUp",
		},
	},

	GoodFollowUp = {
		prompt = "That's great, {name}! What's making you feel good?",
		inputType = "choice",
		options = {"Achievement", "Friends", "Good weather"},
		nextState = {
			Achievement = "Achievement",
			Friends = "Friends",
			["Good weather"] = "Good weather",
		},
	},

	BadFollowUp = {
		prompt = "Sorry to hear that, {name}. What's bothering you?",
		inputType = "choice",
		options = {"Stress", "Boredom", "Fatigue"},
		nextState = {
			Stress = "Stress",
			Boredom = "Boredom",
			Fatigue = "Fatigue",
		},
	},

	-- Bad-path second layer

	Stress = {
		prompt = "That's rough, {name}. Is it school, work, or something else weighing on you?",
		inputType = "choice",
		options = {"School", "Work", "Something else"},
		nextState = "AnythingElse",
	},

	Boredom = {
		prompt = "Ah, I know that feeling. What do you usually do for fun around here?",
		inputType = "choice",
		options = {"Building", "Exploring", "Hanging with friends", "Games"},
		nextState = "AnythingElse",
	},

	Fatigue = {
		prompt = "Tired days are the worst. Have you been sleeping okay lately?",
		inputType = "choice",
		options = {"Not really", "It's been fine"},
		nextState = "AnythingElse",
	},

	-- Good-path second layer

	Achievement = {
		prompt = "Nice! What did you pull off?",
		inputType = "choice",
		options = {"Built something cool", "Won a match", "Leveled up", "Finished a project"},
		nextState = "AnythingElse",
	},

	Friends = {
		prompt = "Good company makes the day better. What were you all up to?",
		inputType = "choice",
		options = {"Just hanging out", "Playing together", "Exploring together"},
		nextState = "AnythingElse",
	},

	["Good weather"] = {
		prompt = "Can't argue with a nice day. Got any plans while it lasts?",
		inputType = "choice",
		options = {"Exploring", "Relaxing", "No plans yet"},
		nextState = "AnythingElse",
	},

	-- Convergence point

	AnythingElse = {
		prompt = "Thanks for telling me, {name}. Anything else on your mind?",
		inputType = "choice",
		options = {"Yes, let's keep talking", "No, that's all"},
		nextState = {
			["Yes, let's keep talking"] = "AskFeeling",
			["No, that's all"] = "Response",
		},
	},

	Response = {
		prompt = "Thanks for sharing, {name}. Take care!",
		inputType = "end",
	},
}

return Database
