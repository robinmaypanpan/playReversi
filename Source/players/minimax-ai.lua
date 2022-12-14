import 'CoreLibs/object'

import 'game-state'
import 'players/base-ai'

local MAX_DEPTH = 2

local MAX_VALUE = 9999999
local MIN_VALUE = -9999999

class('MinimaxAi').extends(BaseAi)

function MinimaxAi:init(gameController, myColor)
	MinimaxAi.super.init(self, gameController, myColor)
	self.weights = {
		win = 1000,
		lose = -1000,
		draw = 0,
		totalPieceDifference = 1,
		cornerPieceBonus = 30, -- In addition to just having the piece out there
		edgePieceBonus = 2 -- In addition to the edge piece
	}
	self.name = 'Hard AI'
end


-- Returns the move this AI wants to play
function MinimaxAi:thinkAboutMove()		
	return self:minimax(self.gameController.gameState, MAX_DEPTH).move
end

-- The minimax algorithm!
function MinimaxAi:minimax(gameState, depth)	
	if (depth == 0) then
		-- We have hit a leaf node, so we just evaluate the board
		return {value=self:evaluateBoard(gameState), move=nil}
	end
	
	-- Initialize to absurdity
	local bestMove = {value=MIN_VALUE, move=nil}
	local worstMove = {value=MAX_VALUE, move=nil}
	
	-- Evaluate all of our possible moves
	List.forEach(gameState.validMoves, function(testMove)
		local stateAfterMove = stateGenerator:getState(gameState, testMove)
		assert(stateAfterMove ~= nil)
		
		local testResult = self:minimax(stateAfterMove, depth - 1)
		
		if (testResult.value > bestMove.value) then
			bestMove = {value=testResult.value, move=testMove}
		elseif (testResult.value < worstMove.value) then
			worstMove = {value=testResult.value, move=testMove}
		end
		
	end)
		
	-- Now we just return it	
	if (gameState.currentPlayer == self.myColor ) then		
		-- We want to maximize our choice here
		return bestMove
	else
		-- Assume our opponent will make the worst choice for us
		return worstMove
	end
end

function MinimaxAi:evaluateBoard(gameState)
	local boardGrid = gameState.boardGrid
	local weights = self.weights
	local myColor = self.myColor
	local opponentColor = invertColor(myColor)
	
	-- End game situation overrides literally everything else
	if (gameState.state == GAME_OVER) then 
		-- Initialize the victory values
		local whiteVictory, blackVictory
		if (myColor == WHITE) then
			whiteVictory = weights.win
			blackVictory = weights.lose
		else
			whiteVictory = weights.lose
			blackVictory = weights.win
		end
		
		-- Now check who won	
		if(gameState.numWhitePieces > gameState.numBlackPieces) then
			return whiteVictory
		elseif (gameState.numBlackPieces > gameState.numWhitePieces) then
			return blackVictory
		else
			-- It's a draw?!
			return weights.draw
		end
	end
	
	-- If we didn't win, let's do some calculations
	local value = 0
	
	-- Let's look at the difference in number of pieces.  That's valuable, right?
	local totalPieceDifference
	if (myColor == WHITE) then
		totalPieceDifference = gameState.numWhitePieces - gameState.numBlackPieces
	else
		totalPieceDifference = gameState.numBlackPieces - gameState.numWhitePieces
	end
	value += totalPieceDifference * weights.totalPieceDifference
	
	-- Now time for position. Corners are particularly nice for the player that gets them
	local corners = {
		{1,1},
		{NUM_BOARD_SPACES,1},
		{1,NUM_BOARD_SPACES},
		{NUM_BOARD_SPACES,NUM_BOARD_SPACES}
	}
	
	for _,corner in pairs(corners) do
		local cornerPiece = boardGrid:get(corner[1], corner[2])
		value += self:getValueDifference(cornerPiece, weights.cornerPieceBonus)
	end
	
	-- Check the edges
	for i = 2,NUM_BOARD_SPACES - 1 do
		-- Left edge
		local leftEdgePiece = boardGrid:get(i, 1)
		value += self:getValueDifference(leftEdgePiece, weights.edgePieceBonus)
		
		local topEdgePiece = boardGrid:get(1, i)
		value += self:getValueDifference(topEdgePiece, weights.edgePieceBonus)
		
		local rightEdgePiece = boardGrid:get(i, NUM_BOARD_SPACES)
		value += self:getValueDifference(rightEdgePiece, weights.edgePieceBonus)
		
		local bottomEdgePiece = boardGrid:get(NUM_BOARD_SPACES, i)
		value += self:getValueDifference(bottomEdgePiece, weights.edgePieceBonus)					
	end
	
	return value
end

-- Returns either a positive or negative of the weight, based on the color of the piece
function MinimaxAi:getValueDifference(piece, weight)		
	local myColor = self.myColor
	local opponentColor = invertColor(myColor)
	
	if (cornerPiece == myColor) then
		return weight
	elseif (cornerPiece == opponentColor) then
		return 0-weight
	else
		-- No effect if the piece does not exist
		return 0
	end
end

function MinimaxAi:isReady()
	return stateGenerator.depth > MAX_DEPTH
end

function MinimaxAi:canFullyMove()
	return stateGenerator.depth > MAX_DEPTH and not self.thinking
end