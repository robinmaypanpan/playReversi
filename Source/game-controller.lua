-- Class used to manipulate the game state

import 'CoreLibs/object'

import "lib/pulp-audio"

import 'game-state'

local audio = pulp.audio

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
	board:addPiece(Location.new(4, 5), BLACK)
	board:addPiece(Location.new(5, 4), BLACK)
	board:addPiece(Location.new(4, 4), WHITE)
	board:addPiece(Location.new(5, 5), WHITE)
	
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
	local board = self.board
	
	-- Update the UI first
	board:addPiece(location, self.gameState.currentPlayer)
	board:flipPiecesAround(location)
	audio.playSound('placePiece')
	
	-- Get the game state that corresponds to the new move
	local newGameState = stateGenerator:makeMove(self.gameState, location)
	self.gameState = newGameState
	
	board:validateGameState(newGameState)
	
	self.whiteDisplay:setScore(newGameState.numWhitePieces)
	self.blackDisplay:setScore(newGameState.numBlackPieces)
	self.whiteDisplay:setActive(newGameState.currentPlayer == WHITE)
	self.blackDisplay:setActive(newGameState.currentPlayer == BLACK)
	
	if (newGameState.state == GAME_OVER) then
		print('Game over! Restart to play again!')
	else
		self:notifyPlayerTurn()
	end
end

function GameController:moveCursorBy(delta)	
	local newPosition = Location.add(self.board.cursorPosition, delta)
	self:moveCursorTo(newPosition)
end

-- Controls the position of the onscreen cursor
function GameController:moveCursorTo(newPosition)
	local gameState = self.gameState
	local board = self.board
	
	-- Check if we can move the cursor to this new position
	local canMoveCursor = gameState:isOnBoard(newPosition)	
	if (canMoveCursor) then
		board:setCursorPosition(newPosition)
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
		playdate.timer.performAfterDelay(10, function()
			self.whitePlayer:takeTurn()
		end)
	else
		playdate.timer.performAfterDelay(10, function()
			self.blackPlayer:takeTurn()
		end)
	end
end

-- When called, starts the game by telling the current player to take their turn
function GameController:startGame()
	self:notifyPlayerTurn()
end