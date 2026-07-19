-- Eityum Hub - Universal Script Hub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1.lua"))()
local MainWindow = Library.CreateLib("Eityum Hub", "RJTheme4")

local ScriptsTab = MainWindow:NewTab("Scripts")
local ScriptsSection = ScriptsTab:NewSection("Universal Scripts")

ScriptsSection:NewButton("Mech", "Build a robot from loose parts", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/robot.lua"))()
end)

ScriptsSection:NewButton("Cobra", "Snake with kill ability", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Cobra.lua"))()
end)

ScriptsSection:NewButton("Text Blocks", "Spell words in the air", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/TextManipulate.lua"))()
end)

ScriptsSection:NewButton("Telekinesis", "Move anything with your mouse", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/TelekinesisByEityum.lua"))()
end)

ScriptsSection:NewButton("F3X", "Advanced building tools", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/F3X%20abuse.lua"))()
end)

ScriptsSection:NewButton("SmileyHub", "Original hub by Claude", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/SmileyHub.lua"))()
end)

local CreditsTab = MainWindow:NewTab("Credits")
local MadeBy = CreditsTab:NewSection("Created by Eityum")
local ThanksTo = CreditsTab:NewSection("Thanks to")
ThanksTo:NewLabel("Claude - Smiley Hub")
ThanksTo:NewLabel("DeepSeek - Mech, Cobra, Text Blocks")
ThanksTo:NewLabel("Robojini - UI Library")
