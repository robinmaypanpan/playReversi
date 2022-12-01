//
//  main.c
//  Extension

#include <stdio.h>
#include <stdlib.h>

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

static int generateValidMoves(lua_State* L)
{	
	Grid* board = pd->lua->getArgObject(1, "intgrid", NULL);
	int currentPlayerColor = pd->lua->getArgInt(2);
	
	List* list = pd->system->realloc(NULL, sizeof(List));
	
	// Let's get to work!
	
	
	pd->lua->pushObject(list, "pointlist", 0);
	
	return 1;
}
