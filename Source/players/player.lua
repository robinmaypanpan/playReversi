import 'CoreLibs/object'

import 'game-controller'
import 'game-state'

class('Player').extends()

function Player:init(gameController, myColor)
	Player.super.init(self)
	assert(gameController ~= nil)
	assert(myColor ~= nil)
	self.gameController = gameController
	self.myColor = myColor
end

-- Called to tell this player to take their turn
function Player:takeTurn()	
	-- Should never be called in the base
	assert(false)
end

-- Called when this player no longer should exist
function Player:shutDown()
end