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
		options = {"Good", "Bad", "Okay"},
		nextState = {
			Good = "GoodFollowUp",
			Bad = "BadFollowUp",
			Okay = "NeutralFollowUp",
		},
	},
	GoodFollowUp = {
		prompt = "That's great, {name}! What's making you feel good?",
		inputType = "choice",
		options = {"Achievement", "Friends", "Good weather", "Family", "Food"},
		nextState = {
			Achievement = "Achievement",
			Friends = "Friends",
			["Good weather"] = "Good weather",
			Family = "Family",
			Food = "Food",
		},
	},
	BadFollowUp = {
		prompt = "Sorry to hear that, {name}. What's bothering you?",
		inputType = "choice",
		options = {"Stress", "Boredom", "Fatigue", "Loneliness", "Conflict"},
		nextState = {
			Stress = "Stress",
			Boredom = "Boredom",
			Fatigue = "Fatigue",
			Loneliness = "Loneliness",
			Conflict = "Conflict",
		},
	},
	NeutralFollowUp = {
		prompt = "Fair enough, {name}. What's today been like?",
		inputType = "choice",
		options = {"Nothing much", "Just chilling", "Same old"},
		nextState = "NeutralDetail",
	},

	-- ===================== BAD PATH: layer 2 =====================
	Stress = {
		prompt = "That's rough, {name}. Is it school, work, or something else weighing on you?",
		inputType = "choice",
		options = {"School", "Work", "Something else"},
		nextState = "StressDetail",
	},
	Boredom = {
		prompt = "Ah, I know that feeling. What do you usually do for fun around here?",
		inputType = "choice",
		options = {"Building", "Exploring", "Hanging with friends", "Games"},
		nextState = "BoredomDetail",
	},
	Fatigue = {
		prompt = "Tired days are the worst. Have you been sleeping okay lately?",
		inputType = "choice",
		options = {"Not really", "It's been fine"},
		nextState = "FatigueDetail",
	},
	Loneliness = {
		prompt = "That sounds tough, {name}. What's making it feel that way?",
		inputType = "choice",
		options = {"Friends are busy", "New to the area", "Just an off day"},
		nextState = "LonelinessDetail",
	},
	Conflict = {
		prompt = "That can be draining, {name}. What kind of conflict is it?",
		inputType = "choice",
		options = {"Argument with a friend", "Family tension", "Something online"},
		nextState = "ConflictDetail",
	},

	-- ===================== BAD PATH: layer 3 =====================
	StressDetail = {
		prompt = "Got it. Is there anything that usually helps you unwind?",
		inputType = "choice",
		options = {"Taking a break", "Talking to someone", "Not really, just pushing through"},
		nextState = "AnythingElse",
	},
	BoredomDetail = {
		prompt = "Sounds fun! Want a suggestion for something new to try around here?",
		inputType = "choice",
		options = {"Sure, surprise me", "Maybe later", "No thanks"},
		nextState = "AnythingElse",
	},
	FatigueDetail = {
		prompt = "That makes sense. Do you think it's stress-related or just a busy schedule?",
		inputType = "choice",
		options = {"Probably stress", "Just busy", "Not sure"},
		nextState = "AnythingElse",
	},
	LonelinessDetail = {
		prompt = "That's understandable, {name}. Would it help to meet some new people around here?",
		inputType = "choice",
		options = {"Yeah, maybe", "I'll figure it out", "Not really looking for that"},
		nextState = "AnythingElse",
	},
	ConflictDetail = {
		prompt = "Conflicts are never fun. Do you think it'll get resolved soon?",
		inputType = "choice",
		options = {"Hopefully", "Not sure", "Probably not"},
		nextState = "AnythingElse",
	},

	-- ===================== GOOD PATH: layer 2 =====================
	Achievement = {
		prompt = "Nice! What did you pull off?",
		inputType = "choice",
		options = {"Built something cool", "Won a match", "Leveled up", "Finished a project"},
		nextState = "AchievementDetail",
	},
	Friends = {
		prompt = "Good company makes the day better. What were you all up to?",
		inputType = "choice",
		options = {"Just hanging out", "Playing together", "Exploring together"},
		nextState = "FriendsDetail",
	},
	["Good weather"] = {
		prompt = "Can't argue with a nice day. Got any plans while it lasts?",
		inputType = "choice",
		options = {"Exploring", "Relaxing", "No plans yet"},
		nextState = "WeatherDetail",
	},
	Family = {
		prompt = "That's sweet, {name}. What's going on with them?",
		inputType = "choice",
		options = {"Visiting", "Video call", "Just thinking about them"},
		nextState = "FamilyDetail",
	},
	Food = {
		prompt = "Now that's a good mood booster. What's the food situation?",
		inputType = "choice",
		options = {"Had a great meal", "Trying a new recipe", "Snack time"},
		nextState = "FoodDetail",
	},

	-- ===================== GOOD PATH: layer 3 =====================
	AchievementDetail = {
		prompt = "That's genuinely impressive, {name}. How long had you been working at it?",
		inputType = "choice",
		options = {"Just today", "A few days", "Ages"},
		nextState = "AnythingElse",
	},
	FriendsDetail = {
		prompt = "Sounds like a good time. Do you all hang out often?",
		inputType = "choice",
		options = {"All the time", "Once in a while", "First time in a bit"},
		nextState = "AnythingElse",
	},
	WeatherDetail = {
		prompt = "Good choice. Indoors or outdoors kind of plans?",
		inputType = "choice",
		options = {"Definitely outdoors", "Bit of both", "Staying in, actually"},
		nextState = "AnythingElse",
	},
	FamilyDetail = {
		prompt = "That's really nice, {name}. Do you get to see them often?",
		inputType = "choice",
		options = {"Pretty often", "Not as much as I'd like", "Rarely, so this means a lot"},
		nextState = "AnythingElse",
	},
	FoodDetail = {
		prompt = "Now I'm curious — what was it?",
		inputType = "choice",
		options = {"Something homemade", "Takeout", "A personal favorite"},
		nextState = "AnythingElse",
	},

	-- ===================== NEUTRAL PATH: layer 2 =====================
	NeutralDetail = {
		prompt = "Gotcha. Anything you're looking forward to today?",
		inputType = "choice",
		options = {"Yeah, something small", "Not really", "Haven't thought about it"},
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
