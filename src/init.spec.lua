return function()
	local Stater = require(script.Parent)
	local StaterObject = Stater.new({
		["Hi"] = function(self)
			print("Hello.")
		end,
		["RetTrue"] = function(self)
			return true
		end,
		["RetFalse"] = function(self)
			return false
		end,
	})

	describe("Construct", function()
		it("Should Construct a Stater Object", function()
			expect(getmetatable(StaterObject)).to.equal(Stater)
		end)
	end)

	describe("IsWorking", function()
		it("Should Return the state of the StaterObject", function()
			expect(StaterObject:IsWorking()).to.equal(false)
		end)
	end)

	describe("Start", function()
		it("Should Start the State", function()
			expect(function()
				StaterObject:Start("Hi")
			end).never.to.throw()
			expect(StaterObject.State).to.be.ok()
		end)
	end)

	describe("Switch", function()
		it("Should Switch the State", function()
			expect(function()
				StaterObject:SetState("Hi")
			end).never.to.throw()
			expect(StaterObject.State).to.equal("Hi")
		end)
	end)

	describe("Stop", function()
		it("Should Stop the State", function()
			expect(function()
				StaterObject:Stop()
			end).never.to.throw()
			expect(StaterObject._Connections.Main).never.to.be.ok()
		end)
	end)

	describe("Enabling Strict States", function()
		it("Should Function normally", function()
			expect(function()
				StaterObject.StateConfirmation = true
				StaterObject:Start("RetTrue")
			end).never.to.throw()
		end)
		it("Should Error due to returning false", function()
			expect(function()
				StaterObject:SetState("RetFalse")
			end).never.to.throw()
		end)
	end)

	describe("Destroy", function()
		it("Should Destroy the Stater Object", function()
			expect(function()
				StaterObject:Destroy()
			end).never.to.throw()
		end)
	end)
end