

#include "GPUPrimPlugin.h"

void GPUPrimPlugin::gpu(float* a, int Msize, edge* ptrEdges) {
	int numThreads = Msize;//1024;
	int numBlocks = Msize / 1024 + 1;

	cudaMemcpy(gpuA, a, Msize*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(gpuMatrix, cost, Msize*Msize*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(edgeArray, ptrEdges, Msize*sizeof(edge), cudaMemcpyHostToDevice);

	findEdgeOfRow<<<numBlocks, numThreads, Msize*sizeof(edge)>>>(gpuA, Msize, gpuMatrix, edgeArray);

	cudaMemcpy(edges, edgeArray, Msize*sizeof(edge), cudaMemcpyDeviceToHost);

	cudaFree(&gpuA);
	cudaFree(&gpuMatrix);
	cudaFree(&edgeArray);

}




void GPUPrimPlugin::input(std::string file) {
 inputfile = file;
 std::ifstream ifile(inputfile.c_str(), std::ios::in);
 while (!ifile.eof()) {
   std::string key, value;
   ifile >> key;
   ifile >> value;
   parameters[key] = value;
 }
 N = atoi(parameters["N"].c_str());
 visited = (int*) malloc(N*sizeof(int));
 int i;
 for (i = 0; i < N; i++) {
    visited[i] = 0;
 } 
 cost = (int*) malloc(N*N*sizeof(int));
 edges = (edge*) malloc(N*sizeof(edge));
 int M = N * N;
 std::ifstream myinput((std::string(PluginManager::prefix())+parameters["matrix"]).c_str(), std::ios::in);
 for (i = 0; i < M; ++i) {
	int k;
	myinput >> k;
        cost[i] = k;
 }
}

void GPUPrimPlugin::run() {
	float* r = (float*) malloc(N*sizeof(float));
	edge* ptrEdge;
	int k = N;
	int mx;
	int mincost = 0;
		printf("\n------------------%d x %d Matrix----------------------\n", k, k);
		ptrEdge = &edges[0];

		cudaMalloc(&gpuA, k*sizeof(float));
        	cudaMalloc(&gpuMatrix, ( k* k*sizeof(int)));
	        cudaMalloc(&edgeArray, ( k*sizeof(edge)));

		edge* edgeStart = ptrEdge;
	
		visited[0]=1;
	        printf("\n");
	        while(ne<k)
	        {	
			gpu(r,k,ptrEdge);
			ptrEdge = edgeStart;
	
	                for(j=0, mx = 0;j<k;j++)
	                {
	                        if(edges[j].edgeWeight>mx)
	                        {
	                                if(visited[edges[j].ownerVertex]!=0)
	                                {
	                                        mx=edges[j].edgeWeight;
	                                        a=u=j;
	                                        b=v=edges[j].pointVertex;
	                                }
	                        }
	                }	
	                if(visited[u]==0 || visited[v]==0)
	                {
//                             printf("\nEdge %d:(%d %d) cost:%d",ne++,a,b,mx);
				ne++;
	                        mincost+=mx;
	                        visited[b]=1;
	                }
	                cost[a*k+b]=cost[b*k+a]=(cost[a*k+b] * -1);
	        }
	        printf("\nMaximum cost = %d\n",mincost);

}

void GPUPrimPlugin::output(std::string file) {
	std::ofstream outfile(file.c_str(), std::ios::out);
        int i;
        for (i = 0; i < N; ++i){
		outfile << edges[i].ownerVertex;
		outfile << "\t";
		outfile << edges[i].pointVertex;
		outfile << "\t";
		outfile << edges[i].edgeWeight;
		outfile << "\n";//std::setprecision(0) << a[i*N+j];
	}
	

}

PluginProxy<GPUPrimPlugin> GPUPrimPluginProxy = PluginProxy<GPUPrimPlugin>("GPUPrim", PluginManager::getInstance());


