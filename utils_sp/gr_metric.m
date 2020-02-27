% This code is free to use for any non-commercial purposes.
% If you use this code, please cite:
%   Rémi Giraud, Vinh-Thong Ta and Nicolas Papadakis
%   Evaluation Framework of Superpixel Methods with a Global Regularity Measure
%   Journal of Electronic Imaging (JEI),
%   Special issue on Superpixels for Image Processing and Computer Vision, 2017
%
% (C) Rémi Giraud, 2017
% rgiraud@u-bordeaux.fr, remigiraud.fr/research/gr.php
% University of Bordeaux
%
% Input:    lab_map - Labeling decomposition map of a 2D image
% Outputs:  gr - Global Regularity measure that evaluates the global regularity 
%           src - Shape Regularity Criteria that evaluates the local shape regularity
%           smf - Smooth Matching Factor that evaluates the shape consistency over the decomposition


function [gr,smf,src] = gr_metric(lab_map)


[h,w]  = size(lab_map);
sp_ind = unique(lab_map(:))';
sp_nbr = length(sp_ind);


%% Local shape regularity evaluation

%Shape Regularity Criteria (SRC)
src = 0;
for k=sp_ind
    
    %S_k current superpixel
    S_k      = lab_map == k;
    [yk,xk]  = find(S_k);
    size_S_k = length(S_k);
    
    %Convex hull of S_k
    hull       = regionprops(S_k,'ConvexImage');
    hull       = hull.ConvexImage;
    perim_hull = regionprops(hull,'Perimeter');
    perim_hull = perim_hull.Perimeter;
    cc_hull    = perim_hull/sum(hull(:));
    
    perim_S_k = regionprops(S_k,'Perimeter');
    perim_S_k = perim_S_k.Perimeter;
    cc_S_k    = perim_S_k/sum(S_k(:));
    
    %Evaluates the convexity of S_k
    cr_k = cc_hull/cc_S_k; 
    
    %Evaluates the balanced repartition of S_k
    sigma_x = std(xk(:));
    sigma_y = std(yk(:));
    vxy_k   = sqrt(min(sigma_x,sigma_y)/max(sigma_x,sigma_y)); 
    
    
    %Shape Regularity Criteria (SRC)
    src_k = cr_k*vxy_k;
    src   = src + src_k*size_S_k;
    
    
end
src = src/(h*w);



%% Shape consistency evaluation

%To store the registered shapes
S_tab = zeros(2*h+1,2*w+1,sp_nbr);

%Average of superpixel shapes
c = 1;
for k=sp_ind
    
    [yk,xk] = find(lab_map == k);
    
    %Barycenter
    my = round(mean(yk(:)));
    mx = round(mean(xk(:)));

    
    for l=1:length(yk)
        %Registered position
        yk_r               = yk(l)+(h+1-my);
        xk_r               = xk(l)+(w+1-mx);
        S_tab(yk_r,xk_r,c) = S_tab(yk_r,xk_r,c) + 1;
    end
    c = c + 1;
    
end
S = sum(S_tab,3)/sp_nbr;
S = S/sum(S(:));

%Smooth Matching Factor (SMF)
smf = 0;
c = 1;
for k=sp_ind
    S_k      = S_tab(:,:,c);
    size_S_k = sum(S_k(:));
    S_k      = S_k/size_S_k;
    smf      = smf + size_S_k*sum(sum(abs(S-S_k)));
    c = c + 1;
end
smf = 1 - smf/(2*(h*w));



%% Global Regularity (GR) measure

gr = src*smf;


end

