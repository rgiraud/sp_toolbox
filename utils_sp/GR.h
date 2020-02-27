// This code is free to use for any non-commercial purposes.
// If you use this code, please cite:
//   Rémi Giraud, Vinh-Thong Ta and Nicolas Papadakis
//   Evaluation Framework of Superpixel Methods with a Global Regularity Measure
//   Journal of Electronic Imaging (JEI),
//   Special issue on Superpixels for Image Processing and Computer Vision, 2017
//
// (C) Rémi Giraud, 2017
// rgiraud@u-bordeaux.fr, remigiraud.fr/research/gr.php
// University of Bordeaux
//
// Note that implementations of other superpixel metrics can be found here:
// https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/


#ifndef GR_H_INCLUDED
#define GR_H_INCLUDED

#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#endif

#ifndef MIN
#define MIN(a, b) ((a)<(b)?(a):(b))
#endif

#ifndef PI
#define PI 3.1415
#endif


int is_px_border (int px, const unsigned short lb[], int w, int h) {
    return
            px % w != 0 && px % w != w - 1 && px >= w && px < w * (h - 1)
            && (
            lb[px] != lb[px - 1]
            || lb[px] != lb[px + 1]
            || lb[px] != lb[px - w]
            || lb[px] != lb[px + w]
            );
}

int is_px_border_incl (int px, const unsigned short lb[], int w, int h) {
    return (px % w == 0 || px % w == w - 1 || px < w || px >= w * (h - 1))
    || is_px_border(px, lb, w, h);
}

double standard_deviation(double data[], int size) {
    double sum = 0;
    for (int i = 0; i < size; i++)
        sum += data[i];
    double mean = sum / size, sd = 0;
    for (int i = 0; i < size; i++)
        sd += (data[i] - mean) * (data[i] - mean);
    return sqrt(sd / size);
}

double vect(int p, int q, int r, int w) {
    return
            (q/w - p/w) * (r%w - q%w) - (q%w - p%w) * (r/w - q/w);
}

int convex_hull(int pt[], int nb_pts, int hull[], int w) {
    if (nb_pts == 0) return 0;
    else if (nb_pts == 1) { hull[0] = pt[0]; return 1; }
    else if (nb_pts == 2) { hull[0] = pt[0]; hull[1] = pt[1]; return 2; }
    else {
        int hull_size = 0, leftmost = 0;
        
        for (int i = 1; i < nb_pts; i++)
            if (pt[i]%w < pt[leftmost]%w)
                leftmost = i;
        int i = leftmost, j;
        do {
            hull[hull_size++] = pt[i];
            j = (i + 1) % nb_pts;
            for (int k = 0; k < nb_pts; k++) {
                if (vect(pt[i], pt[k], pt[j], w) < 0)
                    j = k;
            }
            i = j;
        } while (i != leftmost);
        return hull_size;
    }
}

int is_pt_inside_hull(int pt, int hull[], int hull_size, int w) {
    int inside = 0;
    
    for (int i = 0; i < hull_size; i++) {
        if (vect(hull[(i + 1) % hull_size], hull[i], pt, w) < 0) {
            inside = 1;
            break;
        }
    }
    return inside;
}

double compute_perim(unsigned short shape[], int w, int h, int topmost, int leftmost) {
    
    int start_x=0, start_y=0;
    
    // get the leftmost then topmost border pixel
    bool found = false;
    for (int i = leftmost; i < w; i++) {
        for (int j = topmost; j < h; j++) {
            if (shape[j * w + i]) {
                start_x = i;
                start_y = j;
                found = true;
                break;
            }
        }
        if (found) break;
    }
    
    // directions from 0° up to 315° by step of 45° (2 by 2)
    int directions_x[8] = { 1, 1, 0, -1, -1, -1, 0, 1 };
    int directions_y[8] = { 0, -1, -1, -1, 0, 1, 1, 1 };
    int dir = 1;
    
    int nb_even = 0;
    int nb_uneven = 0;
    int nb_corner = 0;
    int old_dir = 1;
    
    // generate chain code
    
    int current_x, current_y;
    int new_x, new_y;
    
    current_x = start_x;
    current_y = start_y;
    
    while (1) {
        new_x = current_x + directions_x[dir];
        new_y = current_y + directions_y[dir];
        int new_i = new_y * w + new_x;
        
        if (new_x >= 0 && new_y >= 0 && new_x < w && new_y < h // next pixel in direction dir is in image
                && shape[new_i] // and is in shape
                && is_px_border_incl(new_i, shape, w, h)) // and is in shape border
        {
            // move in that direction
            if (dir % 2)
                nb_uneven++;
            else
                nb_even++;
            if (dir != old_dir)
                nb_corner++;
            old_dir = dir;
            current_x = new_x;
            current_y = new_y;
            dir = (dir + 2) % 8;
        }
        else {
            dir = (dir + 7) % 8;
        }
        if (current_x == start_x && current_y == start_y && dir == 1) // back to start
            break;
    }
    
    return nb_even * 0.980 + nb_uneven * 1.406 - nb_corner * 0.091;
}

double compute_cr (int *spx, int spx_size, int n_cols, int n_rows) {
    
    int i, j, pt;
    
    unsigned short *shape = (unsigned short *) calloc(n_cols * n_rows, sizeof(unsigned short));
    for (i = 0; i < spx_size; i++)
        shape[spx[i]] = 1;
    
    // compute superpixel borders
    
    int *spx_border = (int *)malloc(spx_size * sizeof(int));
    int spx_border_size = 0;
    for (i = 0; i < spx_size; i++) {
        if (is_px_border_incl(i, shape, n_cols, n_rows))
            spx_border[spx_border_size++] = i;
    }
    
    // compute superpixel convex hull
    
    int *hull = (int *)malloc(spx_size * sizeof(int));
    int hull_size = convex_hull(spx, spx_size, hull, n_cols);
    
    int t = n_rows - 1, r = 0, b = 0, l = n_cols - 1;
    for (i = 0; i < hull_size; i++) {
        t = MIN(t, hull[i] / n_cols);
        r = MAX(r, hull[i] % n_cols);
        b = MAX(b, hull[i] / n_cols);
        l = MIN(l, hull[i] % n_cols);
    }
    
    // compute convex hull area
    
    unsigned short *hull_shape = (unsigned short *) calloc(n_cols * n_rows, sizeof(unsigned short));
    int hull_area = 0;
    for (i = l; i <= r; i++)
        for (j = t; j <= b; j++) {
            pt = j * n_cols + i;
            if (shape[pt] || is_pt_inside_hull(pt, hull, hull_size, n_cols)) {
                hull_shape[pt] = 1;
                hull_area++;
            }
        }
    
    // compute cr
    
    double spx_perim = compute_perim(shape, n_cols, n_rows, t, l);
    double hull_perim = compute_perim(hull_shape, n_cols, n_rows, t, l);
    
    double cr = spx_size * hull_perim / (spx_perim * hull_area)*0.925;
    
    
    free(shape);
    free(hull);
    free(hull_shape);
    free(spx_border);
    
    return cr;
}

double compute_vxy (int *shape, int size, int n_cols) {
    double *x_list = (double *) malloc(size * sizeof(double));
    double *y_list = (double *) malloc(size * sizeof(double));
    
    for (int j = 0; j < size; j++) {
        x_list[j] = shape[j] % n_cols;
        y_list[j] = shape[j] / n_cols;
    }
    
    double sig_x = standard_deviation(x_list, size);
    double sig_y = standard_deviation(y_list, size);
    
    free(x_list);
    free(y_list);
    
    return fmin(sig_x, sig_y) / fmax(sig_x, sig_y);
}

double compute_src (int *spx[], int *spx_sizes, int n_spx, int n_cols, int n_rows) {
    double src = 0;
    
    double cr, vxy;
    
    for (int i = 0; i < n_spx; i++) {
        if (spx_sizes[i] > 1) {
            cr = compute_cr(spx[i], spx_sizes[i], n_cols, n_rows);
            vxy = compute_vxy(spx[i], spx_sizes[i], n_cols);
            
            src += spx_sizes[i] * cr * sqrt(vxy);
        }
        else
            src += spx_sizes[i];
    }
    
    src = src / (n_cols * n_rows);
    
    return src;
}


//Computes the Smooth Matching Factor (SMF) of a superpixel decomposition spx
double compute_smf (int *spx[], int *spx_sizes, int n_spx, int n_cols, int n_rows) {
    
    // compute maximum superpixel size and barycenters
    int max_spx_w = 0;
    int max_spx_h = 0;
    
    int i, j, x, y, topmost, rightmost, bottommost, leftmost;
    
    int *spx_centers = (int *) calloc(2 * n_spx, sizeof(double));
    
    for (i = 0; i < n_spx; i++) {
        
        if (spx_sizes[i] > 0) {
            topmost = n_rows - 1;
            rightmost = 0;
            bottommost = 0;
            leftmost = n_cols - 1;
            
            for (j = 0; j < spx_sizes[i]; j++) {
                x = spx[i][j] % n_cols;
                y = spx[i][j] / n_cols;
                
                topmost = MIN(topmost, y);
                rightmost = MAX(rightmost, x);
                bottommost = MAX(bottommost, y);
                leftmost = MIN(leftmost, x);
                
                spx_centers[2 * i] += x;
                spx_centers[2 * i + 1] += y;
            }
            
            spx_centers[2 * i] /= spx_sizes[i];
            spx_centers[2 * i + 1] /= spx_sizes[i];
            
            max_spx_w = MAX(max_spx_w, rightmost - leftmost + 1);
            max_spx_h = MAX(max_spx_h, bottommost - topmost + 1);
        }
    }
    
    // center and normalize superpixels, and compute average superpixels
    int width = 2 * max_spx_w + 1;
    int height = 2 * max_spx_h + 1;
    
    double **centered_spx = (double **) malloc(n_spx * sizeof(double *));
    double *mean_spx = (double *) calloc(width * height, sizeof(double));
    
    for (i = 0; i < n_spx; i++)
        centered_spx[i] = (double *) calloc(width * height, sizeof(double));
    
    int new_x, new_y, new_i;
    double norm_val;
    
    for (i = 0; i < n_spx; i++) {
        norm_val = 1.0 / spx_sizes[i];
        
        for (j = 0; j < spx_sizes[i]; j++) {
            new_x = spx[i][j] % n_cols - spx_centers[2 * i] + max_spx_w + 1;
            new_y = spx[i][j] / n_cols - spx_centers[2 * i + 1] + max_spx_h + 1;
            new_i = new_y * width + new_x;
            
            centered_spx[i][new_i] = norm_val;
            mean_spx[new_i] += 1;
        }
    }
    
    for (i = 0; i < width * height; i++)
        mean_spx[i] /= n_cols * n_rows;
    
    
    // compute smf
    double smf = 0;
    double sum_dif;
    
    for (i = 0; i < n_spx; i++) {
        if (spx_sizes[i] > 0) {
            
            sum_dif = 0;
            
            for (j = 0; j < width * height; j++)
                sum_dif += fabs(centered_spx[i][j] - mean_spx[j]);
            
            smf += spx_sizes[i] * sum_dif;
            
        }
    }
    
    smf = 1 - smf / (2 * n_cols * n_rows);
    
    // cleaning
    for (i = 0; i < n_spx; i++)
        free(centered_spx[i]);
    free(centered_spx);
    free(mean_spx);
    free(spx_centers);
    
    return smf;
}

//MAIN
double gr_metric(int *spx[], int *spx_sizes, int n_spx, int n_cols, int n_rows, double * smf, double * src) {
    *src = compute_src(spx, spx_sizes, n_spx, n_cols, n_rows);
    *smf = compute_smf(spx, spx_sizes, n_spx, n_cols, n_rows);
    
    return (*src) * (*smf);
}




#endif
