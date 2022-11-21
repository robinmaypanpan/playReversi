import 'CoreLibs/object'

import 'game-controller'

import "lib/pulp-audio"

import 'game-state'
import 'location'
import 'players/player'

local audio = pulp.audio

class('HumanPlayer').extends(Player)

function HumanPlayer:init(gameController, myColor)
	HumanPlayer.super.init(self, gameController, myColor)
end

function HumanPlayer:moveDown()	
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location(1,0))
	end)
end

function HumanPlayer:moveUp()	
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location(-1,0))
	end)
end

function HumanPlayer:moveRight()	
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location(0,1))
	end)
end

function HumanPlayer:moveLeft()		
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location(0,-1))
	end)
end

function HumanPlayer:attemptPlacement()	
	local cursorPosition = self.gameController.board.cursorPosition
	if (self.gameController.gameState:isValidMove(cursorPosition)) then		
		playdate.inputHandlers.pop()
		self.gameController:makeMove(cursorPosition)
	else
		audio.playSound('invalid')
	end
end

-- Signals the player to take their turn
function HumanPlayer:takeTurn()	
	-- Setup the input handlers to handle controls
	local playerInputHandlers = {
		downButtonDown = function()	
			if (self.downTimer) then self.downTimer:remove() end
			local function timerCallback() self:moveDown() end
			self.downTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		downButtonUp = function()	
			if (self.downTimer) then self.downTimer:remove() end
		end,
		
		upButtonDown = function()
			if (self.upTimer) then self.upTimer:remove() end
			local function timerCallback() self:moveUp() end
			self.upTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		upButtonUp = function()		
			if (self.upTimer) then self.upTimer:remove() end
		end,
		
		rightButtonDown = function()
			if (self.rightTimer) then self.rightTimer:remove() end
			local function timerCallback() self:moveRight() end				
			self.rightTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		rightButtonUp = function()	
			if (self.rightTimer) then self.rightTimer:remove() end
		end,
		
		leftButtonDown = function()
			if (self.leftTimer) then self.leftTimer:remove() end
			local function timerCallback() self:moveLeft() end
			self.leftTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		leftButtonUp = function()	
			if (self.leftTimer) then self.leftTimer:remove() end
		end,
		
		AButtonDown = function()
			self:attemptPlacement()
		end
	}
	playdate.inputHandlers.push(playerInputHandlers)
end