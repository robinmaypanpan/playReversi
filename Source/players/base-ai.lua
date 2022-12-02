import 'CoreLibs/object'

import 'game-controller'
import 'game-state'

import 'players/player'

local vector2D = playdate.geometry.vector2D

class('BaseAi').extends(Player)

function BaseAi:init(gameController, myColor)
	BaseAi.super.init(self, gameController, myColor)
	self.stateGenerator = stateGenerator		
	self.name = 'Base AI'
	self.thinking = false
end

function BaseAi:takeTurn()
	self.thinking = true
	BaseAi.super.takeTurn(self)
end

function BaseAi:chooseMove()
	local gameController = self.gameController
		
	local function onComplete(chosenMove)
		self.thinking = false
		
		self.activeAiTimer = playdate.timer.performAfterDelay(500, function() 
			gameController:moveCursorTo(chosenMove) 
			self.activeAiTimer = playdate.timer.performAfterDelay(200, function()
				self.activeAiTimer = nil
				gameController:makeMove(chosenMove)
			end)
		end)
	end
	
	self.activeAiTimer =playdate.timer.performAfterDelay(10, function()		
		local chosenMove = self:thinkAboutMove()
		self.activeAiTimer =playdate.timer.performAfterDelay(10, function()
			onComplete(chosenMove)
		end)
	end)
end

-- Returns the move this AI wants to play
function BaseAi:thinkAboutMove()	
	-- Should never be called in the base
	assert(false)
end

function BaseAi:shutDown()
	BaseAi.super.shutDown(self)
	if (self.activeAiTimer) then
		self.activeAiTimer:remove()
		self.activeAiTimer = nil
	end
end