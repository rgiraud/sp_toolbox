% Re-ordering function that returns a label map with regions numbered from
% 1 to the number of regions. 
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Input:  - lab_map:   Label map of the superpixel decomposition
% Output: - lab_map_r: Re-order label map



function [lab_map_r] = sp_reorder_fct(lab_map)


min_S = min(lab_map(:));
if min_S <= 0
   lab_map = lab_map - min_S + 1; 
end


SP_nbr    = max(lab_map(:));
lab_vect  = zeros(SP_nbr,1);
[h,w]     = size(lab_map);
lab_map_r = zeros(size(lab_map));


c = 1;
for i=1:h
    for j=1:w
        label = lab_map(i,j);
        if (lab_vect(label,1) == 0) 
            SP_pos            = (lab_map == label);
            lab_map_r(SP_pos) = c;
            lab_vect(label,1) = 1;
            c                 = c + 1;
        end
    end
end



end