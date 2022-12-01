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

#endif /* grid_h */
