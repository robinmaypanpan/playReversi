//
//  main.c
//  Extension

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "pd_api.h"
#include "grid.h"
#include "list.h"

static PlaydateAPI* pd = NULL;
static int generateValidMoves(lua_State* L);

#ifdef _WINDLL
__declspec(dllexport)
#endif
int
eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInitLua )
	{
		pd = playdate;
		
		registerGrid(pd);
		registerList(pd);
		
		const char* err;

		if ( !pd->lua->addFunction(generateValidMoves, "flipflop.generateValidMoves", &err) )
			pd->system->logToConsole("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
			
	}
	
	return 0;
}

static bool checkDirectionForMove(Grid* board, int row, int col, int dRow, int dCol, int currentPlayer)
{
	pd->system->logToConsole("checkDirectionForMove at %d,%d, direction %d,%d", row, col, dRow, dCol);
	
	// We don't check our home square.
	if (dRow == 0 && dCol == 0) {
		return false;
	}
	
	bool foundAnOpponentPiece = false;
	int nextRow = row + dRow;
	int nextCol = col + dCol;
	int piece = getValueAt(board, nextRow, nextCol);
	int nonCurrentPlayer = currentPlayer == 1 ? 2 : 1;
	
	while (piece == nonCurrentPlayer) {
		foundAnOpponentPiece = true;
		
		nextRow = nextRow + dRow;
		nextCol = nextCol + dCol;
		piece = getValueAt(board, nextRow, nextCol);		
	}
	
	return (foundAnOpponentPiece && piece == currentPlayer);
}

static bool calculateIfValidMove(Grid* board, int row, int col, int currentPlayer)
{
	pd->system->logToConsole("calculateIfValidMove at %d,%d", row, col);
		
	// You can't move onto spaces that already have pieces
	if (getValueAt(board, row, col) == 0) {
		return false;
	}
	
	// Look in every direction for a valid move
	for (int dRow = -1; dRow <= 1; dRow ++) {
		for (int dCol = -1; dCol <= 1; dCol++) {
			if (checkDirectionForMove(board, row, col, dRow, dCol, currentPlayer)) 			{				
				return true;
			}
		}
	}
	
	// If we look in every direction and find nothing, we're hosed	
	return false;
}

static int generateValidMoves(lua_State* L)
{	
	Grid* board = pd->lua->getArgObject(1, "intgrid", NULL);
	int currentPlayerColor = pd->lua->getArgInt(2);
	
	List* list = pd->system->realloc(NULL, sizeof(List));
	list->size = 0;
	list->head = NULL;
	list->tail = NULL;
	
	for (int row = 1; row <= board->numRows; row ++) {
		for (int col = 1; col <= board->numCols; col++) {	
			if (calculateIfValidMove(board, row, col, currentPlayerColor)) {	
				pd->system->logToConsole("Found valid move at %d,%d", row, col);
				ListNode* newNode = createNode(row, col);
				pushNode(list, newNode);
			}		
		}
	}
	
	pd->system->logToConsole("Returning list of size %d", list->size);
		
	pd->lua->pushObject(list, "pointlist", 0);
	
	return 1;
}
