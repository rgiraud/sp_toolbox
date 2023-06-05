% This code is free to use for any non-commercial purposes.
%
% It contains very simple implementations of basic superpixel functions:
%    Label map re-ordering (from 1 to sp_nbr),
%    Superpixel adjacency map computation,
%    Superpixel borders display,
%    Average features computation (barycenters and colors),
%    Interactive display of superpixel neighborhood,
%    Label map computation from closed contours.
%
% It also contains implementations of metrics to evaluates the color
% homogeneity (explained variation, intra-cluster variation), regularity
% (circularity, global regularity) and respect of image objects according
% to a ground truth segmentation (achievable segmentation accuracy).
%
% Note that implementations of other superpixel metrics that compare to a
% groud truth decomposition can be found here:
% https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/
%
% Run main.m to have an overview of the contained functions.
%
% (C) Rémi Giraud, 2017
% rgiraud@u-bordeaux.fr, https://remi-giraud.enseirb-matmeca.fr/
% Bordeaux-INP, IMS Laboratory


function main_fct_sp(varargin)

addpath('utils_sp');

%% Get inputs
% Image loading
if nargin >= 1
    img = double(varargin{1});
else
    img = double(imread('./data/test_img.jpg'));
end

% Get segmentation ground truth to compare with
if nargin >= 2
    gt = varargin{2};
else
    gt = imread('./data/test_img_gt.png');
end

% Decomposition into superpixels
if nargin >= 3
    lab_map = varargin{3};
else
    lab_map = superpixels(uint8(img),300,'Compactness',10);
end

%% Processing
% Reordering
lab_map = sp_reorder_fct(lab_map);

% Adjacency
[mat_adj,borders] = sp_adjacency_fct(lab_map);

% Display
figure,
subplot 221
imagesc(uint8(img))
title('image');
subplot 222
imagesc(uint8(img.*borders))
title('Superpixel decomposition')


%% Features and evaluation

% Mean color and superpixel center
[sp_center,sp_color,sp_center_img,sp_color_img] = sp_feat_fct(lab_map,img);

% Shape regularity evaluation
[c] = c_metric(lab_map);

[gr] = gr_metric(lab_map); %(see the 'Global Regularity' metric at remigiraud.fr/research/gr.php)
mex -O CFLAGS="\$CFLAGS -Wall -Wextra -W -std=c99" ./utils_sp/gr_metric_mex.c -outdir ./utils_sp
[gr] = gr_metric_mex(int32(lab_map));

% Color homogeneity evaluation
[icv] = icv_metric(lab_map,img);
[ev] = ev_metric(lab_map,img);

subplot 223
imagesc(uint8(sp_color_img.*borders));
title(sprintf('Mean colors | EV = %1.3f',ev));
subplot 224
imagesc(uint8(sp_center_img.*borders))
if (exist('gr'))
    title(sprintf('Superpixel borders | GR = %1.3f',gr));
else
    title(sprintf('Superpixel borders | C = %1.3f',c));
end
drawnow;


%% ASA (Achievable Segmentation Accuracy vs GT)

if (~isempty(gt)) %gt is provided
    
    [asa] = asa_metric(lab_map,gt);
    
    mex -O CFLAGS="\$CFLAGS -Wall -Wextra -W -std=c99" ./utils_sp/asa_metric_mex.c -outdir ./utils_sp
    [asa] = asa_metric_mex(int32(lab_map),int32(gt));
    
    figure,
    subplot 221
    imagesc(uint8(img))
    title('Image')
    subplot 222
    imagesc(uint8(img.*borders))
    title('Superpixel decomposition')
    subplot 223
    imagesc(lab_map)
    title(sprintf('Superpixel map ASA = %1.3f', asa))
    subplot 224
    imagesc(gt)
    title('Ground truth')
end


%% Superpixel neighborhood display

figure,
imagesc(uint8(img.*borders))
title('Selection of a superpixel')
drawnow;

[x,y] = ginput(1);
lab = lab_map(round(y),round(x));
close(2)

% Neighborhood radius
R = 75;

% Selection of neighboring superpixels according to their barycenters
tmp = double(lab_map*0);
for i=1:max(lab_map(:))
    if ((sp_center(lab,1) - sp_center(i,1))^2 + (sp_center(lab,2) - sp_center(i,2))^2 < R^2)
        [tmp_i] = sp_border_fct(lab_map,i);
        tmp = tmp + tmp_i;
    end
end
tmp = repmat(tmp,[1 1 3]);
borders_lab = img;
borders_lab(lab_map == lab) = 200;
borders_lab((~borders ~= 0) & (tmp == 0)) = 0;
borders_lab(tmp ~= 0) = 255;

% Add centers
borders_lab = min(borders_lab+(255-sp_center_img),255);

close
figure,
imagesc(uint8(borders_lab))
title('Superpixel neighborhood display')



%% Region filling

% Image loading
img2 = imread('coins.png');

% Get binary image
img_th = 1-im2bw(img2);

% Get image with holes to fill
holes = logical(1 - imfill(1-img_th, 'holes'));

% Get region labels from closed contours
lab_map = sp_from_closed_contours_fct(holes,0);

figure,
subplot 221
imagesc(img2)
title('Image')
subplot 222
imagesc(img_th)
title('Thresholded image')
subplot 223
imagesc(holes)
title('Global fill')
subplot 224
imagesc(lab_map)
title('Independent region labeling')


% %% Label map from closed contours
% 
% %Get binary borders
% borders_b = sum(~borders,3);
% 
% %Fill regions froms borders
% label_map = sp_from_closed_contours_fct(borders_b,1);
% 
% figure,
% subplot 121
% imagesc(borders_b)
% title('Image')
% subplot 122
% imagesc(label_map)
% title('Independent Region Labeling')



