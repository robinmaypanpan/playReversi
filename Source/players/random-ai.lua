import 'CoreLibs/object'

import 'players/base-ai'

class('RandomAi').extends(BaseAi)

function RandomAi:init(gameController, myColor)
	RandomAi.super.init(self, gameController, myColor)	
	self.name = 'Easy AI'
end


-- Returns the move this AI wants to play
function RandomAi:thinkAboutMove()
	local gameController = self.gameController
	local gameState = gameController.gameState
	local validMoves = gameState.validMoves
		
	local chosenMoveIndex = math.random(validMoves.first, validMoves.last)
	local chosenMove = validMoves[chosenMoveIndex]
	
	return chosenMove
end