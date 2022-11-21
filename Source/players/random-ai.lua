import 'CoreLibs/object'

import 'players/base-ai'

local vector2D = playdate.geometry.vector2D

class('RandomAi').extends(BaseAi)

function RandomAi:init(gameController, myColor)
	RandomAi.super.init(self, gameController, myColor)
end

-- Returns the move this AI wants to play
function RandomAi:chooseMove()
	assert(self.gameController ~= nil)
	local gameController = self.gameController
	local gameState = gameController.gameState
		
	local chosenMoveIndex = math.random(1, gameState.numValidMoves)
	local chosenMove = gameState.validMoves[chosenMoveIndex]	
	
	return chosenMove
end