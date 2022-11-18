import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "board"

local gfx = playdate.graphics

function setupBoard()
	local numSpaces = 8
	local spaceSize = 29
	
	board = Board(numSpaces, spaceSize)
	
	local screenWidth = playdate.display.getWidth()
	local screenHeight = playdate.display.getHeight()
	board:moveTo(screenWidth / 2, screenHeight / 2)
	
	board:add()
end

function initGame()
	setupBoard()
	board:addPiece(4, 5, 0)
	board:addPiece(5, 4, 0)
	board:addPiece(4, 4, 1)
	board:addPiece(5, 5, 1)
	board:addCursor()
end

-- Get the party started
initGame()
board:setCursor(2,2)

-- Standard main game loop
function playdate.update()
	gfx.sprite.update()
	playdate.timer.updateTimers()
end

local rootInputHandlers = {
	downButtonDown = function()
		board:moveCursor(1,0)
	end,
	
	upButtonDown = function()
		board:moveCursor(-1,0)
	end,
	
	rightButtonDown = function()
		board:moveCursor(0,1)
	end,
	
	leftButtonDown = function()
		board:moveCursor(0,-1)
	end,
	
	AButtonDown = function()
		if board:hasPieceAtCursor() then
			board:flipPieceAtCursor()
		else 
			board:addPieceAtCursor(0)
		end
	end
	
}

playdate.inputHandlers.push(rootInputHandlers)
