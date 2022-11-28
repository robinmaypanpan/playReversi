import 'CoreLibs/object'

import 'game-controller'
import 'game-state'

import 'players/player'

local vector2D = playdate.geometry.vector2D

class('BaseAi').extends(Player)

function BaseAi:init(gameController, myColor)
	BaseAi.super.init(self, gameController, myColor)
	self.stateGenerator = stateGenerator
end

function BaseAi:chooseMove()
	local gameController = self.gameController
		
	local function onComplete(chosenMove)
		playdate.timer.performAfterDelay(500, function() 
			gameController:moveCursorTo(chosenMove) 
			playdate.timer.performAfterDelay(200, function()
				gameController:makeMove(chosenMove)
			end)
		end)
	end
	
	playdate.timer.performAfterDelay(10, function()		
		local chosenMove = self:thinkAboutMove()
		playdate.timer.performAfterDelay(10, function()
			onComplete(chosenMove)
		end)
	end)
end

-- Returns the move this AI wants to play
function BaseAi:thinkAboutMove()	
	-- Should never be called in the base
	assert(false)
end