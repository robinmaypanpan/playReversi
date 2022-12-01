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

ListNode* popNode(List* list);
void pushNode(List* list, ListNode* node);
ListNode* createNode(int row, int col);

void registerList(PlaydateAPI* playdate);

#endif /* list_h */
