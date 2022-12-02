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
	self.name = 'Human'
end


function HumanPlayer:moveDown()	
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location.new(1,0))
	end)
end

function HumanPlayer:moveUp()	
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location.new(-1,0))
	end)
end

function HumanPlayer:moveRight()	
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location.new(0,1))
	end)
end

function HumanPlayer:moveLeft()		
	playdate.timer.performAfterDelay(1, function()
		self.gameController:moveCursorBy(Location.new(0,-1))
	end)
end

function HumanPlayer:doMove(location)
	if (stateGenerator.depth > 2) then
		-- We have enough states to do this	
		self.gameController:makeMove(location)
	else		
		self.humanTimer = playdate.timer.performAfterDelay(200, function()
			self.humanTimer = nil
			self:doMove(location)
		end)
	end
end

function HumanPlayer:attemptPlacement()	
	local cursorPosition = self.gameController.board.cursorPosition
	if (self.gameController.gameState:isValidMove(cursorPosition)) then		
		self:shutDown()
		self:doMove(cursorPosition)
	else
		audio.playSound('invalid')
	end
end

-- Signals the player to take their turn
function HumanPlayer:chooseMove()	
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

function HumanPlayer:shutDown()
	HumanPlayer.super.shutDown(self)
	if (self.humanTimer) then
		self.humanTimer:remove()
		self.humanTimer = nil
	end
	playdate.inputHandlers.pop()
end

function HumanPlayer:isReady()
	-- The human player can immediately move around, but cannot select right away
	return true
end

function HumanPlayer:canFullyMove()
	return stateGenerator.depth > 2
end