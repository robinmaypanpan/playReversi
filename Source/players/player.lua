import 'CoreLibs/object'

import 'game-controller'
import 'game-state'

local vector2D = playdate.geometry.vector2D

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