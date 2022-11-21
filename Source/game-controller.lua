-- Class used to manipulate the game state

import 'CoreLibs/object'

import "lib/pulp-audio"

import 'game-state'

local audio = pulp.audio
local vector2D = playdate.geometry.vector2D

class('GameController').extends()

function GameController:init(board, whiteDisplay, blackDisplay)
	GameController.super.init(self)
	
	self.board = board
	self.whiteDisplay = whiteDisplay
	self.blackDisplay = blackDisplay
	
	self:initializeGameState()
	
	assert(self.gameState.validMoves[1] ~= nil)
	
	-- Initialize the cursor to a valid move
	self.board:setCursorPosition(self.gameState.validMoves[1])
	self.board.cursor:setValidPosition(true)
end

-- Initializes the game state by setting us back into the initial state of the game
function GameController:initializeGameState()
	self.gameState = GameState()
	local gameState = self.gameState
	local board = self.board
	
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
	self.whiteDisplay:setScore(gameState.numWhitePieces)
	self.blackDisplay:setScore(gameState.numWhitePieces)
	self.whiteDisplay:setActive(gameState.currentPlayer == WHITE)
	self.blackDisplay:setActive(gameState.currentPlayer == BLACK)
end

-- Called to restart the game
function GameController:restartGame()
	self.board:clearBoard()
	self:initializeGameState()
end

function GameController:makeMove(location)	
	local gameState = self.gameState
	local board = self.board
	
	-- Update the UI first
	board:addPiece(location, gameState.currentPlayer)
	board:flipPiecesAround(location)
	audio.playSound('placePiece')
	
	-- Now update the game state
	gameState:makeMove(location)
	
	self.whiteDisplay:setScore(gameState.numWhitePieces)
	self.blackDisplay:setScore(gameState.numBlackPieces)
	self.whiteDisplay:setActive(gameState.currentPlayer == WHITE)
	self.blackDisplay:setActive(gameState.currentPlayer == BLACK)
	
	if (gameState.state == GAME_OVER) then
		print('Game over! Restart to play again!')
	else
		self:notifyPlayerTurn()
	end
end

-- Controls the position of the onscreen cursor
function GameController:moveCursor(delta)
	local gameState = self.gameState
	local board = self.board
	
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

-- When called, notifies the current player that it is their turn
function GameController:notifyPlayerTurn()
	if (self.gameState.currentPlayer == WHITE) then
		self.whitePlayer:takeTurn()
	else
		self.blackPlayer:takeTurn()
	end
end

-- When called, starts the game by telling the current player to take their turn
function GameController:startGame()
	self:notifyPlayerTurn()
end