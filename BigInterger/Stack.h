// Interface to Stack data type

#define INIT_STACK 3
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>

typedef char Item;

typedef struct _stack {
    int  top;
    int  size;
    Item *items;
} Stack;

void initStack(Stack *s);
int  pushStack(Stack *s, Item val);
Item popStack(Stack *s);
int  isEmptyStack(Stack s);
void showStack(Stack s);