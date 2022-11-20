import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "board"

local gfx = playdate.graphics
local point = playdate.geometry.vector2D

-- Game state
local board
local currentPlayer
local upTimer
local downTimer
local leftTimer
local rightTimer

function setupBoard()
	local numSpaces = 8
	local spaceSize = 27
	
	board = Board(numSpaces, spaceSize)
	
	local screenWidth = playdate.display.getWidth()
	local screenHeight = playdate.display.getHeight()
	board:moveTo(screenWidth / 2, screenHeight / 2)
	
	board:add()
end

function initializeGameState()
	board:addPiece(point.new(4, 5), 0)
	board:addPiece(point.new(5, 4), 0)
	board:addPiece(point.new(4, 4), 1)
	board:addPiece(point.new(5, 5), 1)
	
	currentPlayer = 1
end
	

function setupGame()
	setupBoard()
	initializeGameState()
	board:addCursor()
end

-- Get the party started
setupGame()
board:setCursor(point.new(2,2), currentPlayer)

-- Standard main game loop
function playdate.update()
	gfx.sprite.update()
	playdate.timer.updateTimers()
end

local rootInputHandlers = {
	downButtonDown = function()	
		local function timerCallback()
			board:moveCursor(point.new(1,0), currentPlayer)
		end
		downTimer = playdate.timer.keyRepeatTimer(timerCallback)
	end,
	
	downButtonUp = function()	
		if (downTimer) then
			downTimer:remove()
		end
	end,
	
	upButtonDown = function()
		local function timerCallback()
			board:moveCursor(point.new(-1,0), currentPlayer)
		end
		upTimer = playdate.timer.keyRepeatTimer(timerCallback)
	end,
	
	upButtonUp = function()		
		if (upTimer) then
			upTimer:remove()
		end
	end,
	
	rightButtonDown = function()
		local function timerCallback()
			board:moveCursor(point.new(0,1), currentPlayer)
		end
		rightTimer = playdate.timer.keyRepeatTimer(timerCallback)
	end,
	
	rightButtonUp = function()	
		if (rightTimer) then
			rightTimer:remove()
		end
	end,
	
	leftButtonDown = function()
		local function timerCallback()
			board:moveCursor(point.new(0,-1), currentPlayer)
		end
		leftTimer = playdate.timer.keyRepeatTimer(timerCallback)
	end,
	
	leftButtonUp = function()	
		if (leftTimer) then
			leftTimer:remove()
		end
	end,
	
	AButtonDown = function()
		if (board:canPlacePieceAtCursor(currentPlayer)) then
			board:placePieceAtCursor(currentPlayer)			
			currentPlayer = invertColor(currentPlayer)
		end
	end
}

playdate.inputHandlers.push(rootInputHandlers)

local menuItem,error = playdate:getSystemMenu():addMenuItem("Restart Game", function()
	board:clearBoard()
	initializeGameState()
end)
