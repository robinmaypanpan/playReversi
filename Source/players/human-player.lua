-- Represents the concept of a player in abstract

import 'CoreLibs/object'

import 'game-controller'

import "lib/pulp-audio"

import 'game-state'

local audio = pulp.audio
local vector2D = playdate.geometry.vector2D

class('HumanPlayer').extends()

function HumanPlayer:init(gameController)
	HumanPlayer.super.init(self)
	self.gameController = gameController
end

function HumanPlayer:moveDown()	
	self.gameController:moveCursor(vector2D.new(1,0))
end

function HumanPlayer:moveUp()	
	self.gameController:moveCursor(vector2D.new(-1,0))
end

function HumanPlayer:moveRight()
	self.gameController:moveCursor(vector2D.new(0,1))
end

function HumanPlayer:moveLeft()	
	self.gameController:moveCursor(vector2D.new(0,-1))
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
			local function timerCallback() self:moveDown() end
			self.downTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		downButtonUp = function()	
			self.downTimer:remove()
		end,
		
		upButtonDown = function()
			local function timerCallback() self:moveUp() end
			self.upTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		upButtonUp = function()		
			self.upTimer:remove()
		end,
		
		rightButtonDown = function()
			local function timerCallback() self:moveRight() end				
			self.rightTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		rightButtonUp = function()	
			self.rightTimer:remove()
		end,
		
		leftButtonDown = function()
			local function timerCallback() self:moveLeft() end
			leftTimer = playdate.timer.keyRepeatTimer(timerCallback)
		end,
		
		leftButtonUp = function()	
			if (leftTimer) then
				leftTimer:remove()
			end
		end,
		
		AButtonDown = function()
			self:attemptPlacement()
		end
	}
	playdate.inputHandlers.push(playerInputHandlers)
end