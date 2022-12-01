-- Class used to manipulate the game state

import 'CoreLibs/object'

import 'ui/game-over'

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
	local validMoves = self.gameState.validMoves
	
	assert(validMoves[validMoves.first] ~= nil)
	
	-- Initialize the cursor to a valid move
	board:setCursorPosition(validMoves[validMoves.first])
	board.cursor:setValidPosition(true)
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
	self.board:addCursor()
	self.board:setCursorPosition(self.gameState.validMoves[1])
	self.board.cursor:setValidPosition(true)
	
	-- Reset the state generator as well
	stateGenerator:reset(self.gameState)
	
	if (self.gameOverDisplay) then
		self.gameOverDisplay:remove()
		self.gameOverDisplay = nil
	end
	
	self:notifyPlayerTurn()
end

-- Save the current state of the game to disk
function GameController:saveGame()
	
	local toSave = {
		whitePlayer = self.whitePlayer.name,
		blackPlayer = self.blackPlayer.name,
		gameState = self.gameState
	}
	
	playdate.datastore.write(toSave)
end

-- Attempt to load the game
function GameController:loadState(gameStateData)
	self.gameState = GameState(gameStateData)
	local gameState = self.gameState
	
	self.board:setCursorPosition(self.gameState.validMoves[1])
	
	self.board:loadState(gameState)
	
	self.whiteDisplay:setScore(gameState.numWhitePieces)
	self.blackDisplay:setScore(gameState.numBlackPieces)
	self.whiteDisplay:setActive(gameState.currentPlayer == WHITE)
	self.blackDisplay:setActive(gameState.currentPlayer == BLACK)	
end

-- Shows the game over display
function GameController:showGameOver(endGameState)	
	if (endGameState.numWhitePieces > endGameState.numBlackPieces) then			
		self.gameOverDisplay = GameOver('Light', endGameState.numWhitePieces, endGameState.numBlackPieces)
	else
		self.gameOverDisplay = GameOver('Dark', endGameState.numBlackPieces, endGameState.numWhitePieces)
	end
	local gameOverDisplay = self.gameOverDisplay
	
	gameOverDisplay:add()
	
	local screenWidth = playdate.display.getWidth()
	local screenHeight = playdate.display.getHeight()
	gameOverDisplay:moveTo(screenWidth / 2, screenHeight / 2)
	gameOverDisplay:add()
	board:removeCursor()
			
	local playerInputHandlers = {
		AButtonDown = function()
			playdate.inputHandlers.pop()
			self:restartGame()
		end
	}
	playdate.inputHandlers.push(playerInputHandlers)
	
	-- Remove the datastore since we don't care about this anymore
	playdate.datastore.delete()
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
	
	self.whiteDisplay:setScore(newGameState.numWhitePieces)
	self.blackDisplay:setScore(newGameState.numBlackPieces)
	self.whiteDisplay:setActive(newGameState.currentPlayer == WHITE)
	self.blackDisplay:setActive(newGameState.currentPlayer == BLACK)
	
	if (newGameState.state == GAME_OVER) then	
		self:showGameOver(newGameState)
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
	local nextPlayer
	if (self.gameState.currentPlayer == WHITE) then
		nextPlayer = self.whitePlayer
	else
		nextPlayer = self.blackPlayer
	end
	
	playdate.timer.performAfterDelay(10, function()
		nextPlayer:takeTurn()
		playdate.timer.performAfterDelay(150, function()
			self.checkReady = true
		end)
	end)
end

-- When called, starts the game by telling the current player to take their turn
function GameController:startGame()
	self:notifyPlayerTurn()
end

-- Should be called on update
function GameController:update()
	if (self.checkReady) then
		if (self.gameState.currentPlayer == WHITE) then
			local whiteCanMove = self.whitePlayer:canFullyMove()
			self.checkReady = not whiteCanMove
			self.whiteDisplay:setIsReady(whiteCanMove)
			
			self.blackDisplay:setIsReady(true)
		else
			self.whiteDisplay:setIsReady(true)		
				
			local blackCanMove = self.blackPlayer:canFullyMove()
			self.checkReady = not blackCanMove
			self.blackDisplay:setIsReady(blackCanMove)
		end
	end
end