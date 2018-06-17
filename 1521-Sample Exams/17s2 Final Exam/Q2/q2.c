// COMP1521 Final Exam
// Read points and determine bounding box

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

// Data type definitions

// all values are in the range 0..255
typedef unsigned char Byte;

// an (x,y) coordinate
typedef struct {
	Byte x;
	Byte y;
} Coord;

// a colour, given as 3 bytes (r,g,b)
typedef struct {
	Byte r;
	Byte g;
	Byte b;
} Color;

// a Point has a location and a colour
typedef struct {
	Coord coord;  // (x,y) location of Point
	Color color;  // colour of Point
} Point;

void boundingBox(int, Coord *, Coord *);

int main(int argc, char **argv)
{
	// check command-line arguments
	if (argc < 2) {
		fprintf(stderr, "Usage: %s PointsFile\n", argv[0]);
		exit(1);
	}

	// attempt to open specified file
	int in = open(argv[1],O_RDONLY);
	if (in < 0) {
		fprintf(stderr, "Can't read %s\n", argv[1]);
		exit(1);
	}

	// collect coordinates for bounding box
	Coord topLeft, bottomRight;
	boundingBox(in, &topLeft, &bottomRight);

	printf("TL=(%d,%d)  BR=(%d,%d)\n",
		 topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);

	// clean up
	close(in);
	return 0;
}

void boundingBox(int in, Coord *TL, Coord *BR)
{
	int size = lseek(in, 0, SEEK_END);
	int cnt = size/sizeof(Point);
	Point temp;
	int i;
	
	int hr_mini = 999;
	int vt_mini = 999;
	int hr_max = -999;
	int vt_max = -999;
	for(i=0;i<cnt;i++){
	    lseek(in, sizeof(Point)*i, SEEK_SET);
	    read(in, &temp, sizeof(Point));
	    // printf("x is %d, y is %d\n",temp.coord.x,temp.coord.y);
	    if(temp.coord.x > vt_max){
	        vt_max = temp.coord.x;
	    }
	    if(temp.coord.x < vt_mini){
	        vt_mini = temp.coord.x;
	    }
	    if(temp.coord.y > hr_max){
	        hr_max = temp.coord.y;
	    }
	    if(temp.coord.y < hr_mini){
	        hr_mini = temp.coord.y;
	    }
	    
	}
	
	(*TL).x = vt_mini;
	(*TL).y = hr_max;
	(*BR).x = vt_max;
	(*BR).y = hr_mini;
	
	
	
}
