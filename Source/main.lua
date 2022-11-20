import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "pulp-audio"

import 'board'
import 'player-display'

local gfx = playdate.graphics
local vector2D = playdate.geometry.vector2D

-- Game state
local board
local currentPlayer
local upTimer
local downTimer
local leftTimer
local rightTimer
local passedTurn = false
local whiteDisplay
local blackDisplay

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
	board:addPiece(vector2D.new(4, 5), 0)
	board:addPiece(vector2D.new(5, 4), 0)
	board:addPiece(vector2D.new(4, 4), 1)
	board:addPiece(vector2D.new(5, 5), 1)
	
	currentPlayer = 1
	
	whiteDisplay:setScore(2)
	blackDisplay:setScore(2)
	whiteDisplay:setActive(true)
	blackDisplay:setActive(false)
end

function restartGame()
	board:clearBoard()
	initializeGameState()
end
	
local pieceTable = gfx.imagetable.new('images/piece')
local whitePieceImage = pieceTable[1]
local blackPieceImage = pieceTable[7]

function setupGame()
	whiteDisplay = PlayerDisplay('LIGHT', whitePieceImage)
	whiteDisplay:add()
	whiteDisplay:moveTo(10,15)
	
	blackDisplay = PlayerDisplay('DARK', blackPieceImage)
	blackDisplay:add()
	blackDisplay:moveTo(320,15)
	setupBoard()
	initializeGameState()
	board:addCursor()
end

function switchTurns()
	currentPlayer = invertColor(currentPlayer)
	
	local validMoves, numValidMoves = board:getValidMoves(currentPlayer)
	
	if (numValidMoves == 0) then
		if (passedTurn) then
			-- TODO: show an end game screen of some sort
			restartGame()
			return
		else
			-- Pass the player's turn to the next player
			passedTurn = true
			switchTurns()
			return
		end
	end
	
	local numWhitePieces, numBlackPieces = board:getScores()
	whiteDisplay:setScore(numWhitePieces)
	blackDisplay:setScore(numBlackPieces)
	whiteDisplay:setActive(currentPlayer == 1)
	blackDisplay:setActive(currentPlayer == 0)
end

-- Get the party started
pulp.audio.init()
setupGame()
board:setCursor(vector2D.new(2,2), currentPlayer)


local rootInputHandlers = {
	downButtonDown = function()	
		local function timerCallback()
			board:moveCursor(vector2D.new(1,0), currentPlayer)
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
			board:moveCursor(vector2D.new(-1,0), currentPlayer)
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
			board:moveCursor(vector2D.new(0,1), currentPlayer)
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
			board:moveCursor(vector2D.new(0,-1), currentPlayer)
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
			switchTurns()
		else
			pulp.audio.playSound('invalid')
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
	pulp.audio.update() 
end