% Computes simple average color and spatial features of a superpixel 
% decomposition.
%
% (C) Rémi Giraud, 2017
% rgiraud@labri.fr, www.labri.fr/~rgiraud/downloads
% University of Bordeaux
%
% Inputs:  - lab_map:       Label map of the superpixel decomposition
%          - img:           Initial image
% Outputs: - sp_center:     Vector of size sp_nbrX2 containing the average
%                           spatial positions (barycenter) of superpixels.
%          - sp_color:      Vector of size sp_nbrX3 containing the average
%                           RGB colors of superpixels.
%          - sp_center_img: Superpixel centers displayed on image domain.
%          - sp_color_img:  Average colors displayed within superpixels.



function [sp_center, sp_color, sp_center_img, sp_color_img] = sp_feat_fct(lab_map,img)

[h,w]  = size(lab_map);
sp_nbr = length(unique(lab_map));

sp_center     = zeros(sp_nbr,2);
sp_color      = zeros(sp_nbr,3);
sp_center_img = 255*ones(h,w,3);
sp_color_img  = zeros(h,w,3);


for k=unique(lab_map)'
    
    % Spatial barycenter
    [y,x]                    = find(lab_map == k);
    my                       = round(mean(y));
    mx                       = round(mean(x));
    sp_center(k,1)           = my;
    sp_center(k,2)           = mx;
    sp_center_img(my,mx,2:3) = 0;
    
    % Colors
    sp_pos                   = lab_map == k;
    % R
    sp_pos_img               = cat(3,sp_pos,sp_pos*0,sp_pos*0)>0;
    mr                       = mean(img(sp_pos_img));
    sp_color(k,1)            = mr;
    sp_color_img(sp_pos_img) = mr;
    % G
    sp_pos_img               = cat(3,sp_pos*0,sp_pos,sp_pos*0)>0;
    mg                       = mean(img(sp_pos_img));
    sp_color(k,2)            = mg;
    sp_color_img(sp_pos_img) = mg;
    % B
    sp_pos_img               = cat(3,sp_pos*0,sp_pos*0,sp_pos)>0;
    mb                       = mean(img(sp_pos_img));
    sp_color(k,3)            = mb;
    sp_color_img(sp_pos_img) = mb;
    
end

end