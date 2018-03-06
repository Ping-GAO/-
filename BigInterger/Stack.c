

#include "Stack.h"


void initStack(Stack *s)
{
    s->top = 0;
    s->size = INIT_STACK;
    s->items = malloc(INIT_STACK*sizeof(Item));
    assert(s->items != NULL);
}

int  pushStack(Stack *s, Item val)
{
    if (s->top == s->size) {
        // increase array size
        s->size *= 2;
        s->items = realloc(s->items, s->size*sizeof(Item));
        assert(s->items != NULL);
    }
    s->items[s->top++] = val;
    return 1;
}

Item popStack(Stack *s)
{
    if (s->top == 0) return -1;
    s->top--;
    return s->items[s->top];
}

int  isEmptyStack(Stack s)
{
    if (s.top == 0)
        return 1;
    else
        return 0;

//	return (s.top == 0) ? 1 : 0;

//  return (s.top == 0);
}

void showStack(Stack s)
{
    printf("Base ");
    for (int i = 0; i < s.top; i++) {
        printf("%c ", s.items[i]);
    }
    printf("Top\n");
}
