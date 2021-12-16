# GPUPrim
# Language: CUDA
# Input: TXT
# Output: TSV
# Tested with: PluMA 1.0, CUDA 10

Run Prim's algorithm on the GPU, to produce a minimum-spanning tree (MST)

Original authors: Nicolette Celli, Ricardo Maury, Elias Garcia

The plugin accepts as input a tab-delimited file of keyword-value pairs, as parameters
for the model:
matrix: TSV file of tab-delimited values for the network, as an adjacency matrix
N: The size of the matrix (assumed NXN)

The MST will be output as a TSV file, with each row containing an edge (two nodes and a weight, also tab-delimited).
