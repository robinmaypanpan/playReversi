#ifndef grid_h
#define grid_h

#include <stdio.h>
#include "pd_api.h"

typedef struct
{
	int numRows;
	int numCols;
	int* data;
} Grid;

void registerGrid(PlaydateAPI* playdate);
int getValueAt(Grid* grid, int row, int col);

#endif /* grid_h */
