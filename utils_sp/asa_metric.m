
function asa = asa_metric(S,gt)

sp_l = max(S(:));
sp_g = max(gt(:));
[h,w] = size(S);

res_tab = zeros(sp_l,sp_g);

for i=1:h
    for j=1:w
        lab = S(i,j);
        res_tab(lab,gt(i,j)) = res_tab(lab,gt(i,j)) + 1;
    end
end

asa = sum(max(res_tab,[],2))/(h*w);

end