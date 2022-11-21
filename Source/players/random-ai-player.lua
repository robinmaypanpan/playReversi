import 'CoreLibs/object'

import 'game-controller'

import 'game-state'

local vector2D = playdate.geometry.vector2D

class('AiRandy').extends()

function AiRandy:init(gameController)
	HumanPlayer.super.init(self)
	self.gameController = gameController
end

function AiRandy:takeTurn()
	local gameController = self.gameController
	local gameState = gameController.gameState
	
	local chosenMoveIndex = math.random(1, gameState.numValidMoves)
	local chosenMove = gameState.validMoves[chosenMoveIndex]	
	
	playdate.timer.performAfterDelay(500, function() 
		gameController:moveCursorTo(chosenMove) 
		playdate.timer.performAfterDelay(200, function()
			gameController:makeMove(chosenMove)
		end)
	end)
end