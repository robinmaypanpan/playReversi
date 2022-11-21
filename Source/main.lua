import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/pulp-audio"

import 'board'
import 'player-display'
import 'game-state'
import 'game-controller'

-- Save typing!
local gfx = playdate.graphics
local vector2D = playdate.geometry.vector2D
local audio = pulp.audio

-- Timers for the input handlers
local upTimer
local downTimer
local leftTimer
local rightTimer

-- UI elements we construct here and give control to the game controller
local board
local whiteDisplay
local blackDisplay

-- Sets up the game board display
function setupBoard()
	board = Board()
	
	local screenWidth = playdate.display.getWidth()
	local screenHeight = playdate.display.getHeight()
	board:moveTo(screenWidth / 2, screenHeight / 2)
	
	board:add()
end

-- Sets up the display of the game
function setupGame()
	-- Setup the player displays first	
	local pieceTable = gfx.imagetable.new('assets/images/piece')
	local whitePieceImage = pieceTable[1]
	local blackPieceImage = pieceTable[7]
	
	whiteDisplay = PlayerDisplay('LIGHT', whitePieceImage)
	whiteDisplay:add()
	whiteDisplay:moveTo(10,15)
	
	blackDisplay = PlayerDisplay('DARK', blackPieceImage)
	blackDisplay:add()
	blackDisplay:moveTo(320,15)
	
	setupBoard()
	board:addCursor()
end

-- Get the party started
audio.init('assets/audio/pulp-songs.json', 'assets/audio/pulp-sounds.json')
setupGame()

local gameController = GameController(board, whiteDisplay, blackDisplay)

-- Setup the input handlers to handle controls
local rootInputHandlers = {
	downButtonDown = function()	
		local function timerCallback()
			gameController:moveCursor(vector2D.new(1,0))
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
			gameController:moveCursor(vector2D.new(-1,0))
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
			gameController:moveCursor(vector2D.new(0,1))
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
			gameController:moveCursor(vector2D.new(0,-1))
		end
		leftTimer = playdate.timer.keyRepeatTimer(timerCallback)
	end,
	
	leftButtonUp = function()	
		if (leftTimer) then
			leftTimer:remove()
		end
	end,
	
	AButtonDown = function()
		local cursorPosition = board.cursorPosition
		if (gameController.gameState:isValidMove(cursorPosition)) then			
			gameController:makeMove(cursorPosition)
		else
			audio.playSound('invalid')
		end
	end
}

playdate.inputHandlers.push(rootInputHandlers)

-- Update the system menu with our options
local menuItem,error = playdate:getSystemMenu():addMenuItem("Restart Game", restartGame)

-- Standard main game loop
function playdate.update()
	gfx.sprite.update()
	playdate.timer.updateTimers()
	audio.update() 
end