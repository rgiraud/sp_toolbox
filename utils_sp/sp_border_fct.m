% Computes the borders of a given superpixel.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Inputs:  - lab_map: Label map of the superpixel decomposition
%          - lab:     Label of the superpixel to cut out        
% Output:  - borders: Borders image of the given superpixel


function [borders] = sp_border_fct(lab_map,lab)


[h, w] = size(lab_map);
borders = zeros(size(lab_map));

for i=2:h-1
    for j=2:w-1
        
        label = lab_map(i,j);
        if (label == lab)
            
            if (label ~= lab_map(i,j+1))
                borders(i,j) = 1;
            end
            if (label ~= lab_map(i+1,j))
                borders(i,j) = 1;
            end
            if (label ~= lab_map(i+1,j+1))
                borders(i,j) = 1;
            end
            if (label ~= lab_map(i+1,j-1))
                borders(i,j) = 1;
            end
        else
            if (lab == lab_map(i,j+1))
                borders(i,j) = 1;
            end
            if (lab == lab_map(i+1,j))
                borders(i,j) = 1;
            end
            if (lab == lab_map(i+1,j+1))
                borders(i,j) = 1;
            end
            if (lab == lab_map(i+1,j-1))
                borders(i,j) = 1;
            end
            
        end
    end
end




end