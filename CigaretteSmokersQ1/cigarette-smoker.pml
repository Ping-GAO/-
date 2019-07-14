#include "for.h"
#include "sem.h"


byte tobacco = 0, paper = 0, match = 0;
byte agent = 1, mutex = 1;
byte tobaccoSem = 0,paperSem=0, matchSem=0;
int isTobacco  = 0, isPaper =  0, isMatch = 0;



active proctype agentA() {
	wait(agent);
	signal(paper);
	signal(match);
}

active proctype agentB() {
	wait(agent);
	signal(tobacco);
	signal(match);
}

active proctype agentC() {
	wait(agent);
	signal(tobacco);
	signal(paper);
}

active proctype pusherA() {
	wait(tobacco);
	wait(mutex);
	if
	:: isPaper == 1 ->
		isPaper = 0;
		signal(matchSem);
	
	:: isMatch == 1 ->
		isMatch = 0;
		signal(paperSem);
	:: else ->
		isTobacco = 1;
	fi;
	signal(mutex);
}

active proctype pusherB() {
	wait(paper);
	wait(mutex);
	if
	:: isTobacco == 1 ->
		isTobacco = 0;
		signal(matchSem);
	
	:: isMatch == 1 ->
		isMatch = 0;
		signal(tobaccoSem);
	:: else ->
		isPaper = 1;
	fi;
	signal(mutex);
}

active proctype pusherC() {
	wait(match);
	wait(mutex);
	if
	:: isPaper == 1 ->
		isPaper = 0;
		signal(tobaccoSem);
	
	:: isTobacco == 1 ->
		isTobacco = 0;
		signal(paperSem);
	:: else ->
		isMatch = 1;
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
	signal(agent)
	smoke();
}

active proctype smokerB(){
	wait(paperSem);
	makeCigarette();
	signal(agent)
	smoke();
}
active proctype smokerC(){
	wait(matchSem);
	makeCigarette();
	signal(agent)
	smoke();
}







