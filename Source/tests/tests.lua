local gfx = playdate.graphics

import '../game-state.lua'

TestState = {}

function assertContainsLocation(moveList, row, col)	
	luaunit.assertIsTrue(
		List.find(moveList,
			function(testValue) 
				return testValue.x == row and testValue.y == col
			end
		)
	)
end

function assertNotContainsLocation(moveList, row, col)	
	luaunit.assertIsFalse(
		List.find(moveList,
			function(testValue) 
				return testValue.x == row and testValue.y == col
			end
		)
	)
end

function TestState:setUp()
	self.gameState = GameState()
end

function TestState:testCreationAndInitialState()	
	local gameState = self.gameState
	luaunit.assertNotIsNil(gameState)
	
	luaunit.assertEquals(gameState.board[4][5], BLACK)
	luaunit.assertEquals(gameState.board[5][4], BLACK)
	luaunit.assertEquals(gameState.board[4][4], WHITE)
	luaunit.assertEquals(gameState.board[5][5], WHITE)
	
	luaunit.assertEquals(gameState.currentPlayer, WHITE)
	luaunit.assertEquals(gameState.nonCurrentPlayer, BLACK)	
	
	luaunit.assertEquals(gameState.numWhitePieces, 2)
	luaunit.assertEquals(gameState.numBlackPieces, 2)
	
	luaunit.assertEquals(gameState.state, GAME_UNDERWAY)
	
	luaunit.assertEquals(self.gameState.validMoves.length, 4)
	luaunit.assertEquals(self.gameState.numValidMoves, 4)
	
	assertContainsLocation(self.gameState.validMoves, 3, 5)
	assertContainsLocation(self.gameState.validMoves, 4, 6)
	assertContainsLocation(self.gameState.validMoves, 5, 3)
	assertContainsLocation(self.gameState.validMoves, 6, 4)	
end

function TestState:testCopyWorks()
	local copyState = GameState(self.gameState)
	
	luaunit.assertNotIsNil(copyState)
	
	luaunit.assertEquals(copyState.board[4][5], BLACK)
	luaunit.assertEquals(copyState.board[5][4], BLACK)
	luaunit.assertEquals(copyState.board[4][4], WHITE)
	luaunit.assertEquals(copyState.board[5][5], WHITE)
	
	luaunit.assertEquals(copyState.currentPlayer, WHITE)
	luaunit.assertEquals(copyState.nonCurrentPlayer, BLACK)	
	
	luaunit.assertEquals(copyState.numWhitePieces, 2)
	luaunit.assertEquals(copyState.numBlackPieces, 2)
	
	luaunit.assertEquals(copyState.state, GAME_UNDERWAY)
	
	luaunit.assertEquals(copyState.validMoves.length, 4)
	luaunit.assertEquals(copyState.numValidMoves, 4)
	
	assertContainsLocation(copyState.validMoves, 3, 5)
	assertContainsLocation(copyState.validMoves, 4, 6)
	assertContainsLocation(copyState.validMoves, 5, 3)
	assertContainsLocation(copyState.validMoves, 6, 4)	
end

function TestState:testStateAfterMove()
	self.gameState:makeMove(Location.new(4,6))
	
	luaunit.assertEquals(self.gameState.numWhitePieces, 4)
	luaunit.assertEquals(self.gameState.numBlackPieces, 1)
	
	luaunit.assertEquals(self.gameState.currentPlayer, BLACK)
	
	luaunit.assertEquals(self.gameState.validMoves.length, 3)
	luaunit.assertEquals(self.gameState.numValidMoves, 3)
	
	assertContainsLocation(self.gameState.validMoves, 3, 4)
	assertContainsLocation(self.gameState.validMoves, 3, 6)
	assertContainsLocation(self.gameState.validMoves, 5, 6)
	
	assertNotContainsLocation(self.gameState.validMoves, 4, 3)	
	
end

function TestState:tearDown()
	self.gameState = nil
end