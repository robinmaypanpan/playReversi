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
	self.name = 'BasePlayer'
end


-- Called to tell this player to take their turn
function Player:takeTurn()		
	if (self:isReady()) then
		self:chooseMove()
	else
		playdate.timer.performAfterDelay(200, function()
			self:takeTurn()
		end)
	end
end

-- Called to request a move from this player
function Player:chooseMove()
	-- Should never be called on the base class
	assert(false)
end

-- Called when this player no longer should exist
function Player:shutDown()
end

-- Returns true if the player is ready to make a move
function Player:isReady()
	return stateGenerator.depth > 2
end