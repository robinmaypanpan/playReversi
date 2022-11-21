import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "lib/pulp-audio"

import 'board'
import 'player-display'
import 'game-state'

-- Save typing!
local gfx = playdate.graphics
local vector2D = playdate.geometry.vector2D
local audio = pulp.audio

-- Game state
local gameState
local upTimer
local downTimer
local leftTimer
local rightTimer
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

function initializeGameState()
	gameState = GameState()
	
	-- We know a few facts about the initial game state
	assert(gameState.state == GAME_UNDERWAY)
	assert(gameState.numValidMoves == 4)
	assert(gameState.validMoves ~= nil)
	
	-- Add the initial pieces here	
	-- TODO: Find a way to do this once in one place instead of multiple
	board:addPiece(vector2D.new(4, 5), BLACK)
	board:addPiece(vector2D.new(5, 4), BLACK)
	board:addPiece(vector2D.new(4, 4), WHITE)
	board:addPiece(vector2D.new(5, 5), WHITE)
	
	-- Setup the displays correctly
	whiteDisplay:setScore(gameState.numWhitePieces)
	blackDisplay:setScore(gameState.numWhitePieces)
	whiteDisplay:setActive(gameState.currentPlayer == WHITE)
	blackDisplay:setActive(gameState.currentPlayer == BLACK)
end

-- Called to restart the game
function restartGame()
	board:clearBoard()
	initializeGameState()
end

function makeMove(location)
	-- Update the UI first
	board:addPiece(location, gameState.currentPlayer)
	board:flipPiecesAround(location)
	audio.playSound('placePiece')
	
	-- Now update the game state
	gameState:makeMove(location)
	
	whiteDisplay:setScore(gameState.numWhitePieces)
	blackDisplay:setScore(gameState.numBlackPieces)
	whiteDisplay:setActive(gameState.currentPlayer == WHITE)
	blackDisplay:setActive(gameState.currentPlayer == BLACK)
	
	if (gameState.state == GAME_OVER) then
		print('Game over! Restart to play again!')
	end
end

function moveCursor(delta)
	local newPosition = board.cursorPosition + delta	
	
	-- Check if we can move the cursor to this new position
	local canMoveCursor = gameState:isOnBoard(newPosition)	
	if (canMoveCursor) then
		board:moveCursor(delta)
		audio.playSound('moveCursor')
		
		-- Now check if our new location is a valid location
		local isValidMove = gameState:isValidMove(newPosition)
		board.cursor:setValidPosition(isValidMove)
	else
		audio.playSound('invalid')
	end
end

-- Get the party started
audio.init('assets/audio/pulp-songs.json', 'assets/audio/pulp-sounds.json')
setupGame()
initializeGameState()
assert(gameState.validMoves[1] ~= nil)
board:setCursorPosition(gameState.validMoves[1])
board.cursor:setValidPosition(true)

-- Setup the input handlers to handle controls
local rootInputHandlers = {
	downButtonDown = function()	
		local function timerCallback()
			moveCursor(vector2D.new(1,0))
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
			moveCursor(vector2D.new(-1,0))
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
			moveCursor(vector2D.new(0,1))
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
			moveCursor(vector2D.new(0,-1))
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
		if (gameState:isValidMove(cursorPosition)) then			
			makeMove(cursorPosition)
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