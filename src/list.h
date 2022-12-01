#ifndef list_h
#define list_h

#include <stdio.h>
#include "pd_api.h"

typedef struct ListNodeStruct
{
	int row, col;
	struct ListNodeStruct* next;
	struct ListNodeStruct* prev;
} ListNode;

typedef struct
{
	int size;
	ListNode* head;
	ListNode* tail;
} List;

void registerList(PlaydateAPI* playdate);

#endif /* list_h */
