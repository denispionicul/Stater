-- This example is made for roblox studio usage rather than wally, although you can easily just change the location
-- of where I require the Stater module.
-- This should be placed inside a dummy, Although Stater heavily benefits and was made with the intention of being used in
-- a module script.
local Model = script.Parent
local Humanoid = Model:WaitForChild("Humanoid")
local HumanoidRootPart = Model:WaitForChild("HumanoidRootPart")

HumanoidRootPart:SetNetworkOwner(nil)

local Stater = require(script.Stater)
local States = require(script.States)

local AI = Stater.new(States, 0.5, Model)
AI.Info.Humanoid = Humanoid
AI.Info.HumanoidRootPart = HumanoidRootPart
AI.StateConfirmation = false -- if this is enabled, all states must return a boolean.

AI:Start("Walking")

AI.Changed:Connect(function(CurrentState: string, PreviousState: string)
    print("State Changed from " .. PreviousState .. " to " .. CurrentState)
end)

Humanoid.Died:Once(function()
    AI:Destroy()
end)