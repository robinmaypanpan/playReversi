
#include "list.h"

static PlaydateAPI* pd = NULL;

ListNode* popNode(List* list)
{
	ListNode* oldTail = list->tail;
	if (oldTail != NULL) {
		if (list->head == oldTail) {
			// This is our only node.
			list->head = NULL;
			list->tail = NULL;
			list->size = 0;			
		} else {			
			list->tail = oldTail->prev;
			list->tail->next = NULL;
			list->size--;
		}		
	}
	return oldTail;
}

void pushNode(List* list, ListNode* node)
{
	ListNode* oldTail = list->tail;
	ListNode* oldHead = list->head;
	
	if (oldHead == NULL && oldTail == NULL) {
		// Putting in the first element of the list
		list->head = node;
		list->tail = node;
		list->size++;
	} else {
		// Add this item to the end of the list
		list->tail->next = node;
		node->prev = list->tail;
		list->tail = node;
		list->size++;
	}
}

ListNode* createNode(int row, int col)
{
	ListNode* node = pd->system->realloc(NULL, sizeof(ListNode));
	node->next = NULL;
	node->prev = NULL;
	node->row = row;
	node->col = col;
	
	return node;
}

static int list_newobject(lua_State* L)
{	
	List* list = pd->system->realloc(NULL, sizeof(List));
	list->size = 0;
	list->head = NULL;
	list->tail = NULL;
	
	pd->lua->pushObject(list, "pointlist", 0);
	
	return 1;
}

static int list_gc(lua_State* L)
{		
	List* list = pd->lua->getArgObject(1, "pointlist", NULL);
	
	if ( list != NULL )
	{
		while(list->size > 0) {
			ListNode* node = popNode(list);
			pd->system->realloc(node, 0);
		}
		pd->system->realloc(list, 0);
	}
	
	return 0;
}

static int list_pop(lua_State* L)
{	
	List* list = pd->lua->getArgObject(1, "pointlist", NULL);
	
	ListNode* node = popNode(list);
	
	if (node != NULL) {
		pd->lua->pushNil();
		pd->lua->pushNil();
	} else {		
		pd->lua->pushInt(node->row);
		pd->lua->pushInt(node->col);
	}
	
	return 2;
}

static int list_push(lua_State* L)
{	
	List* list = pd->lua->getArgObject(1, "pointlist", NULL);
	int row = pd->lua->getArgInt(2);
	int col = pd->lua->getArgInt(3);
	
	ListNode* node = createNode(row, col);
	pushNode(list, node);
	
	return 0;
}

static int list_getsize(lua_State* L)
{	
	List* list = pd->lua->getArgObject(1, "pointlist", NULL);
	
	pd->lua->pushInt(list->size);
	return 1;
}


static const lua_reg listLib[] =
{
	{ "new", 		list_newobject },
	{ "__gc",		list_gc },
	{ "pop", 		list_pop },
	{ "push",		list_push },
	{ "getSize",	list_getsize },
	{ NULL, NULL }
};

void registerList(PlaydateAPI* playdate)
{
	pd = playdate;
	
	const char* err;
	
	if ( !pd->lua->registerClass("pointlist", listLib, NULL, 0, &err) )
		pd->system->logToConsole("%s:%i: registerClass failed, %s", __FILE__, __LINE__, err);
}