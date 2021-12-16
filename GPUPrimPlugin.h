//cuvivlib.com/Reduction.pdf
#include "Plugin.h"
#include "PluginProxy.h"
#include <string>
#include <map>
#include <stdio.h> 
#include <stdbool.h> 
#include <stdlib.h> 
#include <time.h> 
#include <emmintrin.h>

#include <fstream>

typedef struct{
        int ownerVertex;
        int edgeWeight;
        int pointVertex;
        bool alreadyAccepted;
} edge;

class GPUPrimPlugin : public Plugin {

	public:
		void input(std::string file);
		void run();
		void output(std::string file);
		void gpu(float* a, int Msize, edge* ptrEdges);
	private:
                std::string inputfile;
		std::string outputfile;
		int N;
                std::map<std::string, std::string> parameters;
float* gpuA;
int *gpuMatrix;

int a,b,u,v,i,j,ne=1;
//int visited[N]={0},mx,mincost=0,cost[N*N], randomNumber;
int* visited;
int* cost;
edge* edges;

edge line;
//edge edges[N];
edge *edgeArray;
};

// GPU function to find the max edge in one row...
//Each thread will look through the row that its global index will point to
//and then keep a record of the edge with the max weight.
//It will then add it to the shared array to then give it to main.
__global__ void findEdgeOfRow(float* a, int x, int* matrix, edge* edgeArray) {
	
	extern __shared__ edge edgeArr[];
	int element = blockIdx.x*blockDim.x + threadIdx.x;
	edge lines;
	lines.ownerVertex = 0;
        lines.edgeWeight = 0;
        lines.pointVertex = 0;
	
	int* ptrMatrix = (matrix+(element*x));
	edge* ptrRow = edgeArray;
	edge*rowStart = ptrRow;

	//Searching through the row assigned to thread through Global Thread ID for maximum edge
	int ys;
	for(ys = 0; ys<x; ys++){
		if(lines.edgeWeight < *(ptrMatrix)){
		        lines.ownerVertex = element;
        		lines.edgeWeight = *(ptrMatrix);
	        	lines.pointVertex = ys;
		}
		ptrMatrix++;
	}

	edgeArr[element%x].ownerVertex = lines.ownerVertex;
        edgeArr[element%x].edgeWeight = lines.edgeWeight;
        edgeArr[element%x].pointVertex = lines.pointVertex;

	ptrRow = rowStart;
	//Will wait for all threads to finish.
	__syncthreads();
	int op;
	for(op = 0; op<x; op++){
		edgeArray[op] = *(edgeArr+op);
	}
}



