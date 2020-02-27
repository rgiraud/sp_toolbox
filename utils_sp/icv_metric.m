% Implementation of the Intra-cluster variation (ICV) metric that
% evaluates the color homogeneity of a superpixel decomposition.
% The original formulation was given in:
%   W. Benesova and M. Kottman, Fast superpixel segmentation using
%   morphological processing, in the Proc. of the Int. Conf. on Machine 
%   Vision and Machine Learning (MVML), 2014.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Inputs: - lab_map: Label map of the superpixel decomposition
%         - img:     Initial image
% Output: - icv:     Intra-cluster variation computed on the decomposition


function  [icv] = icv_metric(lab_map, img)


sp_nbr = length(unique(lab_map));

img_r  = img(:,:,1);
img_g  = img(:,:,2);
img_b  = img(:,:,3);


icv    = 0;

for k = unique(lab_map)'
    
    sp_k = (lab_map == k);
    
    rr   = img_r(sp_k);
    gg   = img_g(sp_k);
    bb   = img_b(sp_k);
    mr   = mean(rr(:));
    mg   = mean(gg(:));
    mb   = mean(bb(:));
    
    c_k  = sqrt((sum((rr(:) - mr).^2) + sum((gg(:) - mg).^2) + sum((bb(:) - mb).^2))/3);
    icv  = icv + c_k/sum(sp_k(:));
    
end

icv = icv / sp_nbr;


end