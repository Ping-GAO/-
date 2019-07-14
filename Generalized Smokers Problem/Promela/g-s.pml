#include "for.h"
#include "sem.h"


byte tobacco = 5, paper = 10, match = 8;
byte mutex = 1;
byte tobaccoSem = 0,paperSem=0, matchSem=0;
byte  numTobacco  = 0, numPaper =  0, numMatch = 0;




active proctype pusherA() {
	wait(tobacco);
	wait(mutex);
	if
	:: numPaper > 0 ->
		numPaper = numPaper - 1;
		signal(matchSem);
	
	:: numMatch > 0 ->
		numMatch = numMatch - 1;
		signal(paperSem);
	:: else ->
		numTobacco = 1 + numTobacco;
	fi;
	signal(mutex);
}

active proctype pusherB() {
	wait(paper);
	wait(mutex);
	if
	:: numTobacco > 0 ->
		numTobacco = numTobacco - 1;
		signal(matchSem);
	
	:: numMatch > 0 ->
		numMatch = 0;
		signal(tobaccoSem);
	:: else ->
		numPaper = numPaper + 1;
	fi;
	signal(mutex);
}

active proctype pusherC() {
	wait(match);
	wait(mutex);
	if
	:: numPaper > 0 ->
		numPaper = numPaper - 1;
		signal(tobaccoSem);
	
	:: numTobacco > 0 ->
		numTobacco = numTobacco -1;
		signal(paperSem);
	:: else ->
		numMatch = numMatch +1;
	fi;
	signal(mutex);
}

inline smoke(){
	printf("smoke a cigarrete");
}
inline makeCigarette(){
	printf("make a cigarrete");
}


active proctype smokerA(){
	wait(tobaccoSem);
	makeCigarette();
	smoke();
}

active proctype smokerB(){
	wait(paperSem);
	makeCigarette();
	smoke();
}
active proctype smokerC(){
	wait(matchSem);
	makeCigarette();
	smoke();
}







