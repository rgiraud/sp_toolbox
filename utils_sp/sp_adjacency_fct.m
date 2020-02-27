% Computes the adjacency matrix and the superpixel borders of a 
% decomposition.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Input:   - lab_map: Label map of the superpixel decomposition
% Outputs: - adj_mat: Adjacency matrix. It is naturally symmetric and 
%                     contains 1 at positions (i,j) and (j,i) if 
%                     superpixels i and j are adjacent.
%          - borders: Superpixel borders for display


function [adj_mat, borders] = sp_adjacency_fct(lab_map)

[h,w]   = size(lab_map);
nbr_sp  = max(lab_map(:));
adj_mat = zeros(nbr_sp);
borders = zeros(size(lab_map));

for i=2:h-1
    for j=2:w-1
        
        label = lab_map(i,j);
        
        if (label ~= lab_map(i+1,j-1))
            adj_mat(label, lab_map(i+1,j-1)) = 1;
            borders(i,j)                     = 1;
        end
        if (label ~= lab_map(i,j+1))
            adj_mat(label, lab_map(i,j+1)) = 1;
            borders(i,j)                   = 1;
        end
        if (label ~= lab_map(i+1,j))
            adj_mat(label, lab_map(i+1,j)) = 1;
            borders(i,j)                   = 1;
        end
        if (label ~= lab_map(i+1,j+1))
            adj_mat(label, lab_map(i+1,j+1)) = 1;
            borders(i,j)                     = 1;
        end
        
    end
end

adj_mat = double((adj_mat + adj_mat')>0);
adj_mat = adj_mat + eye(nbr_sp);

borders(1:end,1)   = 1;
borders(1:end,end) = 1;
borders(1,1:end)   = 1;
borders(end,1:end) = 1;
borders            = double(repmat(~borders,[1 1 3]));



end

