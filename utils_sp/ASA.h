#ifndef ASA_H_INCLUDED
#define ASA_H_INCLUDED

#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#endif

//Achievable Segmentation Accuracy metric
double asa_metric(int *spx[], int *spx_sizes, int n_spx, int nRows, int nCols, int *ground_truth) {

  double asa = 0;
  int max_region = 32;
  int *regions = (int *) malloc(max_region * sizeof(int));

  int i, j, gt, max_overlap;

  for (i = 0; i < n_spx; i++) {

    // reset counts
    for (j = 0; j < max_region; j++)
      regions[j] = 0;

    // count number of pixels of spx[i] in each region
    for (j = 0; j < spx_sizes[i]; j++) {
      gt = ground_truth[ spx[i][j] ];

      if (gt >= max_region) {
        regions = (int *) realloc(regions, 2 * max_region * sizeof(int));
        for (int k = max_region; k < 2 * max_region; k++)
          regions[k] = 0;
        max_region *= 2;
      }

      regions[gt]++;

    }

    max_overlap = 0;
    for (j = 0; j < max_region; j++)
      max_overlap = MAX(max_overlap, regions[j]);

    asa += max_overlap;
  }

  return asa / (nRows * nCols);
}





#endif
