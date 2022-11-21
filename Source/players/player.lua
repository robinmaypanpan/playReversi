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

function Player:takeTurn()	
	-- Should never be called in the base
	assert(false)
end