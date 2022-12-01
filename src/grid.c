
#include "grid.h"

int getValueAt(Grid* grid, int row, int col) 
{	
	if (row < 1 || row > grid->numRows || col < 1 || col > grid->numCols) {
		return -1;
	}
	
	int realPosition = (row - 1) * grid->numCols + (col - 1);
	
	return grid->data[realPosition];
}

static PlaydateAPI* pd = NULL;

static int grid_newobject(lua_State* L)
{
	int numRows = pd->lua->getArgInt(1);
	int numCols = pd->lua->getArgInt(2);
	
	if ( numRows * numCols <= 0 )
		return 0;

	Grid* grid = pd->system->realloc(NULL, sizeof(Grid));
	grid->numRows = numRows;
	grid->numCols = numCols;
	
	grid->data = pd->system->realloc(NULL, sizeof(int) * numRows * numCols);
	
	pd->lua->pushObject(grid, "intgrid", 0);
	
	return 1;
}

static int grid_gc(lua_State* L)
{
	Grid* grid = pd->lua->getArgObject(1, "intgrid", NULL);
	
	if ( grid != NULL )
	{
		pd->system->realloc(grid->data, 0);
		pd->system->realloc(grid, 0);
	}
	
	return 0;
}

static int grid_get(lua_State* L)
{
	Grid* grid = pd->lua->getArgObject(1, "intgrid", NULL);
	int row = pd->lua->getArgInt(2);
	int col = pd->lua->getArgInt(3);
	
	pd->lua->pushInt(getValueAt(grid, row, col));
	
	return 1;
}

static int grid_set(lua_State* L)
{	
	Grid* grid = pd->lua->getArgObject(1, "intgrid", NULL);
	int row = pd->lua->getArgInt(2);
	int col = pd->lua->getArgInt(3);
	int value = pd->lua->getArgInt(4);
	
	int realPosition = (row - 1) * grid->numCols + (col - 1);
	
	grid->data[realPosition] = value;
	
	return 0;
}

static int grid_setAll(lua_State* L)
{	
	Grid* grid = pd->lua->getArgObject(1, "intgrid", NULL);
	int value = pd->lua->getArgInt(2);
	
	for (int row = 0; row < grid->numRows; row++) {
		for (int col = 0; col < grid->numCols; col++) {			
			int realPosition = row * grid->numCols + col;
			grid->data[realPosition] = value;
		}
	}
	
	return 0;
}

static const lua_reg gridLib[] =
{
	{ "new", 		grid_newobject },
	{ "__gc",		grid_gc },
	{ "get", 		grid_get },
	{ "set",		grid_set },
	{ "setAll",		grid_setAll },
	{ NULL, NULL }
};

void registerGrid(PlaydateAPI* playdate)
{
	pd = playdate;
	
	const char* err;
	
	if ( !pd->lua->registerClass("intgrid", gridLib, NULL, 0, &err) )
		pd->system->logToConsole("%s:%i: registerClass failed, %s", __FILE__, __LINE__, err);
}
