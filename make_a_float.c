// make_a_float ... read in bit strings to build a float value
// COMP1521 Lab03 exercises
// Written by John Shepherd, August 2017
// Completed by Ping GAO

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

typedef uint32_t Word;

typedef struct _float {
    // define bit_fields for sign, exp and frac
    // obviously they need to be larger than 1-bit each
    // and may need to be defined in a different order
    unsigned int frac: 23,
                 exp :8,
                 sign:1;
}Float32;

union _bits32 {
    float   fval;  // interpret the bits as a float
    Word    xval;  // interpret as a single 32-bit word
    Float32 bits;  // manipulate individual bits
};
typedef union _bits32 Union32;

void    checkArgs(int, char **);
Union32 getBits(char *, char *, char *);
char   *showBits(Word, char *);

int main(int argc, char **argv)
{
    union _bits32 u;
    char out[50];

    // here's a hint ...
    u.bits.sign = u.bits.exp = u.bits.frac = 0;

    // check command-line args (all strings of 0/1
    // kills program if args are bad
    checkArgs(argc, argv);

    // convert command-line args into components of
    // a Float32 inside a Union32, and return the union
    u = getBits(argv[1], argv[2], argv[3]);

    printf("bits : %s\n", showBits(u.xval,out));
    printf("float: %0.10f\n", u.fval);

    return 0;
}

// convert three bit-strings (already checked)
// into the components of a struct _float
Union32 getBits(char *sign, char *exp, char *frac)
{
    Union32 new;
    int i;
    // this line is just to keep gcc happy
    // delete it when you have implemented the function
    new.bits.sign = new.bits.exp = new.bits.frac = 0;

    // convert char *sign into a single bit in new.bits

    // convert char *exp into an 8-bit value in new.bits

    // convert char *frac into a 23-bit value in new.bits
    if(sign[0] == '0'){
        new.bits.sign = 0;
    }
    else{
        new.bits.sign = 1;
    }
    // printf("sign is %s\n",sign);



    int base = 1;
    unsigned int res1 = 0;
    for(i = 7;i>=0 ;i--){
        if(exp[i] == '1'){
            res1 += base;
        }
        base <<= 1;
    }
    new.bits.exp = res1;
    // printf("string1 is %s\n",exp);
    // printf("res1 is %d\n",res1);



    base = 1;
    unsigned int res2 = 0;
    for(i = 22;i>=0 ;i--){
        if(frac[i] == '1'){
            res2 += base;
        }
        base <<= 1;
    }
    new.bits.frac = res2;
    // printf("string 2 is %s\n",frac);
    // printf("res2 is %d\n",res2);


    return new;
}

// convert a 32-bit bit-string val into a sequence
// of '0' and '1' characters in an array buf
// assume that buf has size > 32
// return a pointer to buf
char *showBits(Word val, char *buf)
{
    // this line is just to keep gcc happy
    // delete it when you have implemented the function
    //printf("val is %u\n",val);
    // int convert(int dec);
    char temp[50];
    int c,k;
    int cnt = 0;
    for(c=31;c>=0;c--){
        k = val>>c;
        if(k&1){
            // printf("1");
            temp[cnt++] = '1';
        }
        else{
            // printf("0");
            temp[cnt++] = '0';
        }
    }
    temp[cnt] = '\0';
    buf[0] = temp[0];
    buf[1] = ' ';
    int counter = 2;
    for(c=1;c<=8;c++){
        buf[counter++] = temp[c];
    }
    buf[counter++] = ' ';
    //printf("counter is %d\n",counter);
    for(c=9;c<=31;c++){
        buf[counter++]  = temp[c];
    }
    buf[counter] = '\0';
    // printf("\n");




    return buf;
}

// checks command-line args
// need at least 3, and all must be strings of 0/1
// never returns if it finds a problem
void checkArgs(int argc, char **argv)
{
    int justBits(char *, int);

    if (argc < 3) {
        printf("Usage: %s Sign Exp Frac\n", argv[0]);
        exit(1);
    }
    if (!justBits(argv[1],1)) {
        printf("%s: invalid Sign\n", argv[0]);
        exit(1);
    }
    if (!justBits(argv[2],8)) {
        printf("%s: invalid Exp: %s\n", argv[0], argv[2]);
        exit(1);
    }
    if (!justBits(argv[3],23)) {
        printf("%s: invalid Frac: %s\n", argv[0], argv[3]);
        exit(1);
    }
}

// check whether a string is all 0/1 and of a given length
int justBits(char *str, int len)
{
    if (strlen(str) != len) return 0;

    while (*str != '\0') {
        if (*str != '0' && *str != '1') return 0;
        str++;
    }
    return 1;
}

