import 'CoreLibs/object'

import 'game-controller'

import 'game-state'

local vector2D = playdate.geometry.vector2D

class('BaseAi').extends()

function BaseAi:init(gameController)
	BaseAi.super.init(self)
	self.gameController = gameController
end

function BaseAi:takeTurn()
	local gameController = self.gameController
	
	local chosenMove = self:chooseMove()
	
	playdate.timer.performAfterDelay(500, function() 
		gameController:moveCursorTo(chosenMove) 
		playdate.timer.performAfterDelay(200, function()
			gameController:makeMove(chosenMove)
		end)
	end)
end

-- Returns the move this AI wants to play
function BaseAi:chooseMove()	
	-- Should never be called in the base
	assert(false)
end