-- very basic state demonstration.
local RNG = Random.new()

local function RandomizeVector(): Vector3
    return Vector3.new(RNG:NextInteger(-10, 10), 0, RNG:NextInteger(-10, 10))
end

local function GetHumanoid(self): Humanoid
    local OP = OverlapParams.new()
    OP.FilterType = Enum.RaycastFilterType.Exclude
    OP.FilterDescendantsInstances = {self.Info.HumanoidRootPart.Parent}

    for _, Part in workspace:GetPartBoundsInRadius(self.Info.HumanoidRootPart.Position, 30, OP) do
        local Model = Part:FindFirstAncestorOfClass("Model")

        if Model then
            local Humanoid = Model:FindFirstChildOfClass("Humanoid")

            if Humanoid then
                return Humanoid
            end
        end
    end
end

local States = {}

function States.ChasingEnd(self)
    print("Chasing ended.")
end

function States.ChasingStart(self)
    print("Chasing Start Ran.")
end

function States.Chasing(self)
    local Humanoid = GetHumanoid(self)

    if Humanoid then
        self.Info.Humanoid:MoveTo(Humanoid.Parent.HumanoidRootPart.Position)
    else
        self:SetState("Walking")
    end
    
    return true -- if StateConfirmation is set to off, this will not matter
end

function States.Walking(self) -- You always get self (the Stater Object) as a first parameter.
    local RandomVector = RandomizeVector()

    self.Info.Humanoid:MoveTo(self.Info.HumanoidRootPart.Position + RandomVector)
    task.wait(2.5) -- delay the next action by 2.5 seconds

    local Humanoid = GetHumanoid(self)

    if Humanoid then
        self:SetState("Chasing")
    end

    return true -- if StateConfirmation is set to off, this will not matter
end

return States