#include<mex.h>
#include<matrix.h>
#include "./ASA.h"



void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    
    int * S = (int*)mxGetPr(prhs[0]);
    int nRows=mxGetM(prhs[0]);
    int nCols=mxGetN(prhs[0]);
    
    int * gt = (int*) mxGetPr(prhs[1]);
    
    //Reprocessing
    int max_sp = 0;
    for (int i = 0; i < nCols*nRows; i++) {
        if (S[i] > max_sp)
            max_sp = S[i];
    }
    
    max_sp = max_sp +1;
    int *spx_sizes = (int *)calloc(max_sp, sizeof(int));
    for (int i = 0; i < nCols*nRows; i++)
        spx_sizes[S[i]]++;
    
    int **spx = (int **) malloc(max_sp * sizeof(int *));
    
    for (int i = 0; i < max_sp; i++) {
        spx[i] = (int *) malloc(spx_sizes[i] * sizeof(int));
        spx_sizes[i] = 0;
    }
    
    for (int i = 0; i < nCols*nRows; i++)
        spx[ S[i] ][ spx_sizes[S[i]] ++ ] = i;
    
    double asa = asa_metric(spx, spx_sizes, max_sp, nCols, nRows, gt);
    
    int dims[1];
    dims[0] = 1;
    plhs[0] = mxCreateNumericArray(1, dims, mxSINGLE_CLASS, mxREAL);
    float *asa_ptr = (float*) mxGetPr(plhs[0]);
    *asa_ptr = (float) asa;
    
}
