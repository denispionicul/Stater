--!nonstrict
-- Version 0.2.1

-- Dependencies
local Option = require(script.Parent:FindFirstChild("Option") or script.Option)
local Promise = require(script.Parent:FindFirstChild("Promise") or script.Promise)
local Signal = require(script.Parent:FindFirstChild("Signal") or script.Signal)
local Trove = require(script.Parent:FindFirstChild("Trove") or script.Trove)

--[=[
    @class Stater

    Stater is a finite state machine module with the purpose of easing the creation of ai and npcs in games,
    Stater was built with the intent of being used in module scripts.
]=]
local Stater = {}
Stater.__index = Stater

-- Types
--[=[
    @type State (Stater) -> boolean?
    @within Stater
]=]

--[=[
    @interface Stater
    @within Stater
    .States {State} -- The Provided States Table, if theres a "Init" state then that function will execute each time the Stater Starts.
    .Info {any?} -- A table that you can add anything in, this is more recommended than directly inserting variables inside the object.
    .Tick number? -- The time it takes for the current state to be called again after a function is done. Default is 0
    .Instance Model? -- Optional model for when you don't want to do self.Info.Instance. Default is nil.
    .State State -- The current state that the Stater is on.
    .StateConfirmation boolean -- If this is enabled, the state MUST return a boolean indicating if the function ran properly.
    .Changed Signal | RBXScriptSignal -- A signal that fires whenever the State changes. Returns Current State and Previous State
    .StatusChanged Signal | RBXScriptSignal -- Fired whenever the Stater starts or closes. Returns the current status as a boolean.
]=]

export type State =  (self: Stater) -> boolean?

type self = {
    States: {State},
    Info: {any?},
    Tick: number?,
    Instance: Model?,
    State: string,
    StateConfirmation: boolean,

    Changed: Signal | RBXScriptSignal, -- ignore if this is underlined
    StatusChanged: Signal | RBXScriptSignal -- ignore if this is underlined
}

export type Stater = typeof(setmetatable({} :: self, Stater))


-- Functions

--[=[
    Returns a new Stater Object.

    @error "No States" -- Happens when no States are provided
    @param States -- The Table that will have all the States
    @param Tick -- Optional tick to be set.
    @param Instance -- Optional model to be set.
]=]
function Stater.new(States: State, Tick: number?, Instance: Model?): Stater
    assert(typeof(States) == "table", "Please provide a valid table with the states.")

    local self = setmetatable({}, Stater)

   -- Non Usable
   self._Trove = Trove.new()
   self._Connections = {
       Main = nil
   }

    -- Usable
    self.States = States
    self.Info = {}
    self.Instance = Instance
    self.Tick = Tick or 0
    self.State = nil
    self.StateConfirmation = false

    self.Changed = self._Trove:Construct(Signal)
    self.StatusChanged = self._Trove:Construct(Signal)

    return self
end

--[=[
    Returns the current state the Stater is on indicated by a string. If none then nil.

    @deprecated v0.2.1 -- You might want to use self.State instead.
]=]
function Stater:GetCurrentState(): string | nil
    return self.State
end

--[=[
    Returns a boolean indicating if the State currently is on.
]=]
function Stater:IsWorking(): boolean
    return self._Connections.Main ~= nil
end

--[=[
    Returns a boolean indicating if the State currently is on.

    @param State -- The function name inside States represented by a string
    @error "No State" -- Happens when no State is provided.
    @error "Invalid State" -- Happens when the state provided doesn't exist.
]=]
function Stater:SetState(State: string)
    assert(type(State) == "string", "Please provide a state when setting.")

    local StateInStates = Option.Wrap(self.States[State])

    StateInStates:Match({
        ["Some"] = function(_)
            self.Changed:Fire(State, self.State)
            self.State = State
        end,
        ["None"] = function()
            error("No State with the given name.")
        end
    })

    StateInStates = nil
end

--[=[
    Begins the Stater

    @param State -- The function name inside States represented by a string, this state will be set at the start.
    @error "No State" -- Happens when no State is provided.
    @error "Already Started" -- Happens when the Stater has already started.
]=]
function Stater:Start(State: string)
    assert(type(State) == "string", "Please provide a state when starting.")
    assert(self._Connections.Main == nil, "You cannot start twice.")

    if self.States["Init"] then
        self.States["Init"](self)
    end

    self:SetState(State)
    self.StatusChanged:Fire(true)

    self._Connections.Main = self._Trove:AddPromise(Promise.try(function()
        while true do
            task.wait(self.Tick)
            local StateOption = Option.Wrap(self.States[self.State])

            if StateOption:IsSome() then
                local Result = Option.Wrap(StateOption:Unwrap()(self))

                if self.StateConfirmation and (Result:IsNone() or Result:Contains(false)) then
                    warn("State returned false or nil, stopping...")
                    self:Stop()
                end

                Result = nil
            else
                warn("Current State is not set, Please consider setting a state.")
            end
            StateOption = nil
        end
    end)):catch(function()
        error("There was a problem starting, please try again.")
    end)
end

--[=[
    Stops the stater and its state.

    @error "Already Stopped" -- Happens when the Stater has already been stopped.
]=]
function Stater:Stop()
    assert(self._Connections.Main ~= nil, "You cannot stop twice.")

    self._Trove:Remove(self._Connections.Main)
    self._Connections.Main:cancel()
    self._Connections.Main = nil
    self._CurrentState = nil
    self.State = nil

    self.StatusChanged:Fire(false)
end

--[=[
    Gets rid of the Stater Object.
]=]
function Stater:Destroy()
    self._Trove:Destroy()
    table.clear(self)
    self = nil
end


return Stater
