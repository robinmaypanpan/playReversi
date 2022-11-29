import 'CoreLibs/object'

import 'players/base-ai'

class('RandomAi').extends(BaseAi)

function RandomAi:init(gameController, myColor)
	RandomAi.super.init(self, gameController, myColor)	
	self.name = 'Easy AI'
end


-- Returns the move this AI wants to play
function RandomAi:thinkAboutMove()
	assert(self.gameController ~= nil)
	local gameController = self.gameController
	local gameState = gameController.gameState
		
	local chosenMoveIndex = math.random(gameState.validMoves.first, gameState.validMoves.last)
	local chosenMove = gameState.validMoves[chosenMoveIndex]
	
	return chosenMove
end