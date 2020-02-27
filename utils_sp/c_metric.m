% Implementation of the Circularity (C) metric that evaluates the color
% homogeneity of a superpixel decomposition.
% The original formulation was given in:
%   A. Schick, et al., Measuring and evaluating the compactness of
%   superpixels, in Proc. of International Conference on Pattern 
%   Recognition (ICPR), 2012.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Input:  - lab_map: Label map of the superpixel decomposition
% Output: - c:       Circularity computed on the decomposition


function [c] = c_metric(lab_map)

[h,w] = size(lab_map);
c     = 0;

for k = unique(lab_map)'
    
    sp_k  = lab_map == k;
    
    perim = regionprops(sp_k,'Perimeter');
    perim = perim.Perimeter;
    
    c_k   =  4*pi*sum(sp_k(:)>0)/(sum(perim(:))^2);
    c     = c + c_k*sum(sp_k(:)>0);
    
end

c = c/(h*w);

end