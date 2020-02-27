% Computes a label map from closed contours.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Inputs: - borders:     Superpixel borders, images with holes to fill.
%                        The borders must be set to 1.
%         - fill_border: Option setting the filling of borders. Can be set
%                        to 1 to obtain a label map from superpixels
%                        borders.
% Output: - label_map:   Each closed region is filled with a label.


function label_map = sp_from_closed_contours_fct(borders_init,fill_border)

borders   = borders_init>0;

[h,w]     = size(borders);
label_map = zeros(size(borders));


c = 1;
for i=1:h-1
    for j=1:w-1
        if ((label_map(i,j) == 0) &&  (borders(i,j) ~= 1))
            BW2       = imfill(borders, [i,j], 4);
            label_map = label_map + (BW2 - borders)*c;
            c         = c + 1;
        end
        
    end
end

label_map_tmp = label_map;

if (fill_border)
    for i=1:h
        for j=1:w
            if (borders(i,j) == 1)
                win = label_map_tmp(max(i-2,1):min(i+2,h), max(j-2,1):min(j+2,w));
                win = win(win>0);
                %Median value that exists
                if (~isempty(win))
                    [~, index]     = min(abs(win(:) - median(win(:))));
                    label_map(i,j) = win(index);
                end
            end
        end
    end
end





end

