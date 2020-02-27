% Implementation of the Explained Variation (EV) metric that evaluates 
% the color homogeneity of a superpixel decomposition.
% The original formulation was given in:
%   A. Moore, et al., Superpixel lattices, in Proc. of IEEE Conf.
%   on Computer Vision and Pattern Recognition (CVPR), 2008.
% and is computed according to the formulation in:
%   R. Giraud, et al., Evaluation Framework of Superpixel Methods with a
%   Global Regularity Measure, HAL preprint <hal-01519635>, 2017.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Inputs: - lab_map: Label map of the superpixel decomposition
%         - img:     Initial image
% Output: - ev:      Explained variation computed on the decomposition


function  [ev] = ev_metric(lab_map, img)

[h,w] = size(lab_map);
img   = double(img)/255;

img_r = img(:,:,1);
img_g = img(:,:,2);
img_b = img(:,:,3);

ev    = 0;

for k = unique(lab_map)'
    
    sp_k = (lab_map == k);
    l_k  = 1;
    rr   = img_r(sp_k)/l_k;
    gg   = img_g(sp_k)/l_k;
    bb   = img_b(sp_k)/l_k;
    
    tmp  = sum(sp_k(:))*((var(rr(:))+var(gg(:))+var(bb(:)))/3);
    ev   = ev + tmp;
    
end

var_img = (var(img_r(:))+var(img_g(:))+var(img_b(:)))/3;
ev      = 1 - ev/(var_img*(h*w));


end