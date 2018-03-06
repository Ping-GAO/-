// BigNum.h ... LARGE positive integer values


#include "BigNum.h"


int max(int a,int b){
    return a>b?a:b;
}
int mini(int a, int b){
    return  a>b?b:a;
}
// Initialise a BigNum to N bytes, all zero
void initBigNum(BigNum *n, int Nbytes)
{
    n->nbytes = Nbytes;
    n->bytes = malloc(Nbytes * sizeof(Byte));
    assert(n->bytes != NULL);
    int i;
    for(i=0;i<n->nbytes;i++){
        n->bytes[i] = '0';
    }
}

// Add two BigNums and store result in a third BigNum
void addBigNums(BigNum n, BigNum m, BigNum *res)
{
    // can do any modification on m and n since they all just a copy
    // put two BigNum in a stack
    Stack mys1,mys2,ans;
    initStack(&mys1);
    initStack(&mys2);
    initStack(&ans);
    int i,j;
    int flag = 0;
    int flag2 = 0;
    for(i=0;i<n.nbytes;i++){
        if(flag == 0){
            if(n.bytes[i]!='0'){
                flag = 1;
                pushStack(&mys1,n.bytes[i]);
            }
        }
        else{
            pushStack(&mys1,n.bytes[i]);
        }
    }
    // showStack(mys1);
    for(i=0;i<m.nbytes;i++){
        if(flag2 == 0){
            if(m.bytes[i]!='0'){
                flag2 = 1;
                pushStack(&mys2,m.bytes[i]);
            }
        }
        else{
            pushStack(&mys2,m.bytes[i]);
        }
    }
    // showStack(mys2);
    int pre_val = 0;
    while((!isEmptyStack(mys1)) && (!isEmptyStack(mys2))){
        char c1 = popStack(&mys1);
        char c2 = popStack(&mys2);
        int mynum = (c1-'0')+(c2-'0');
        mynum += pre_val;
        if(mynum >=10){
            mynum = mynum%10;
            pre_val = 1;
            pushStack(&ans, (Item) (mynum + '0'));
        }
        else{
            pre_val = 0;
            pushStack(&ans, (Item) (mynum + '0'));
        }
    }

    while(!isEmptyStack(mys1)){
        char temp3 = popStack(&mys1);
        int num3 = temp3-'0'+pre_val;
        if(num3>=10){
            pre_val = 1;
            num3 = num3%10;
            pushStack(&ans,num3+'0');
        }
        else{
            pre_val = 0;
            pushStack(&ans,num3+'0');
        }

    }

    while(!isEmptyStack(mys2)){
        char temp4 = popStack(&mys2);
        int num4 = temp4-'0'+pre_val;
        if(num4>=10){
            pre_val = 1;
            num4 = num4%10;
            pushStack(&ans,num4+'0');
        }
        else{
            pre_val = 0;
            pushStack(&ans,num4+'0');
        }
    }
    // showStack(mys1);
    // showStack(mys2);
    if(pre_val!=0){
        pushStack(&ans,'1');
    }

    int size = ans.top;
    initBigNum(res,size);
    for(j=0;j<size;j++){
        char temp5 = popStack(&ans);
        // printf("char %c\n",temp5);
        res->bytes[j] = (Byte) temp5;
    }
}

// Set the value of a BigNum from a string of digits
// Returns 1 if it *was* a string of digits, 0 otherwise
int scanBigNum(char *s, BigNum *n)
{
    char *temp;
    char *start = NULL;
    int flag = 0;
    int cnt = 0;
    for(temp=s;*temp != '\0';temp++){
        if(flag == 0) {
            if (isdigit(*temp)) {
                // isdigit returns non-zero value if c is an alphabet, else it returns 0
                flag = 1;
                start = temp;
                cnt++;
            }
        }
        else{
            // flag set to 0
            if(isdigit(*temp)){
               cnt++;
            }
            else{
                break;
            }
        }
    }
    if(flag==0){
        return 0;
    }
    else{
        int j;
        if(cnt > n->nbytes){
            // need more space to hold the BigNum
            initBigNum(n,cnt);
        }
        for(j = n->nbytes - cnt;j < n->nbytes;j++){
            n->bytes[j] = (Byte) *start;
            start++;
        }
        return 1;
    }

}

// Display a BigNum in decimal format
void showBigNum(BigNum n)
{
    int i;
    int flag = 0;
    for(i=0;i < n.nbytes;i++) {
        if(flag == 0){
            if(n.bytes[i]!='0'){
                flag = 1;
                printf("%c",n.bytes[i]);
            }
        }
        else{
            printf("%c",n.bytes[i]);
        }
    }
    if(flag==0){
        printf("0");
    }

}
