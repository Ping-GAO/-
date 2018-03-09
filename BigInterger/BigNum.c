// BigNum.h ... LARGE positive integer values


#include "BigNum.h"


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
            pushStack(&ans,(Item)(num3+'0'));
        }
        else{
            pre_val = 0;
            pushStack(&ans,(Item)(num3 + '0'));
        }

    }

    while(!isEmptyStack(mys2)){
        char temp4 = popStack(&mys2);
        int num4 = temp4-'0'+pre_val;
        if(num4>=10){
            pre_val = 1;
            num4 = num4%10;
            pushStack(&ans,(Item)(num4 + '0'));
        }
        else{
            pre_val = 0;
            pushStack(&ans,(Item)(num4 + '0'));
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
        if (flag == 0) {
            if (n.bytes[i] != '0' && (n.bytes[i] != '-' )) {
                flag = 1;
                printf("%c", n.bytes[i]);
            }
            if(n.bytes[i] == '-' ){
                flag = 0;
                printf("%c", n.bytes[i]);
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


void subtractBigNums(BigNum n, BigNum m, BigNum *res){
    Stack mys1,mys2,ans;
    Stack mys1_,mys2_;
    initStack(&mys1);
    initStack(&mys2);
    initStack(&mys1_);
    initStack(&mys2_);
    initStack(&ans);
    int i,j;
    int flag = 0;
    int flag2 = 0;
    for(i=0;i<n.nbytes;i++){
        if(flag == 0){
            if(n.bytes[i]!='0'){
                flag = 1;
                pushStack(&mys1,n.bytes[i]);
                pushStack(&mys1_,n.bytes[i]);
            }
        }
        else{
            pushStack(&mys1,n.bytes[i]);
            pushStack(&mys1_,n.bytes[i]);
        }
    }
    // showStack(mys1);
    for(i=0;i<m.nbytes;i++){
        if(flag2 == 0){
            if(m.bytes[i]!='0'){
                flag2 = 1;
                pushStack(&mys2,m.bytes[i]);
                pushStack(&mys2_,m.bytes[i]);
            }
        }
        else{
            pushStack(&mys2,m.bytes[i]);
            pushStack(&mys2_,m.bytes[i]);
        }
    }

    // first we need to find out which number is larger
    int sign = 1;
    // 1 for positive and 0 for negative
    Stack s3,s4;
    initStack(&s3);
    initStack(&s4);
    while(!isEmptyStack(mys1)){
        char c = popStack(&mys1);
        pushStack(&s3,c);
    }
    while(!isEmptyStack(mys2)){
        char c2 = popStack(&mys2);
        pushStack(&s4,c2);
    }

    if(mys1_.top>mys2_.top){
        sign = 1;
    }
    else if(mys1_.top == mys2_.top){
        while(!isEmptyStack(s3)){
            char c3 = popStack(&s3);
            char c4 = popStack(&s4);
            if((c3-'0')>(c4-'0')){
                sign=1;
                break;
            }
            else if((c3-'0')<(c4-'0')){
                sign = 0;
                break;
            }
        }
    }
    else{
        sign = 0;
    }
    // swap the value
    // printf("sign is %d\n",sign);
    Stack *mys1_ptr = &mys1_;
    Stack *mys2_ptr = &mys2_;
    if(sign == 0){
        Stack *temp;
        temp = mys1_ptr;
        mys1_ptr = mys2_ptr;
        mys2_ptr = temp;
    }

    int pre_val = 0;


    while((!isEmptyStack(*mys1_ptr)) && (!isEmptyStack(*mys2_ptr))){
        char c1 = popStack(mys1_ptr);
        char c2 = popStack(mys2_ptr);
        int mynum;
        mynum = (c1-'0')+pre_val-(c2-'0');
        if(mynum >= 0){

            pre_val = 0;
            pushStack(&ans, (Item) (mynum + '0'));
        }
        else{
            mynum += 10;
            pre_val = -1;
            pushStack(&ans, (Item) (mynum + '0'));
        }
    }

    while(!isEmptyStack(*mys1_ptr)){
        char temp3 = popStack(mys1_ptr);
        int num3 = temp3-'0'+pre_val;
        if(num3>= 0){
            pre_val = 0;
            pushStack(&ans,(Item)(num3+'0'));
        }
        else{
            pre_val = -1;
            num3 += 10;
            pushStack(&ans,(Item)(num3 + '0'));
        }

    }

    while(!isEmptyStack(*mys2_ptr)){
        char temp4 = popStack(mys2_ptr);
        int num4 = temp4-'0'+pre_val;
        if(num4 >= 0){
            pre_val = 0;
            pushStack(&ans,(Item)(num4 + '0'));
        }
        else{
            pre_val = -1;
            num4 += 10;
            pushStack(&ans,(Item)(num4 + '0'));
        }
    }
    if(sign==0){
        pushStack(&ans,'-');
    }


    int size = ans.top;
    initBigNum(res,size);
    for(j=0;j<size;j++){
        char temp5 = popStack(&ans);
        res->bytes[j] = (Byte) temp5;
    }
}


void multiplyBigNums(BigNum n, BigNum m, BigNum *res){
    Stack num_array[10];
    int i, j;
    for(i=0;i<10;i++){
        multiplyBigNums_single_digit(n, i, (num_array+i));
    }



    Stack mys2;
    initStack(&mys2);
    int flag2 = 0;

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
    // printf("tep os %d\n",mys2.top);

    int k;
    int size = mys2.top;
    for(j=0;j<size;j++){
        char c2 = popStack(&mys2);
        BigNum temp6;
        int size2 = num_array[c2-'0'].top;
        initBigNum(&temp6,size2 + j);
        Stack s;
        initStack(&s);
        copy(&s,num_array[c2-'0']);

        for(k=0;k<size2;k++){
            char temp7 = popStack(&s);
            temp6.bytes[k] = (Byte) temp7;

        }
        for(k=size2;k<size2 + j;k++){
            temp6.bytes[k] = '0';
        }
        addBigNums(*res,temp6,res);
    }
    // showBigNum(*res);

}

void multiplyBigNums_single_digit(BigNum n,int a,Stack *s){

    Stack mys1;
    initStack(&mys1);
    initStack(s);
    int i;
    int flag = 0;

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

    int pre_val = 0;
    while(!isEmptyStack(mys1)){
        char temp = popStack(&mys1);
        int num = (temp-'0')*a + pre_val;
        if(num>=10){
            pre_val = (num - num%10)/10;
            num = num%10;
            pushStack(s,(Item)(num+'0'));

        }
        else{
            pre_val = 0;
            pushStack(s,(Item)(num+'0'));
        }
    }
    if(pre_val != 0){
        pushStack(s,(Item)(pre_val + '0'));
    }



}
