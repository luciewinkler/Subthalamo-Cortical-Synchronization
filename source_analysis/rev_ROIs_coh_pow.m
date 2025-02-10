
% ROIs identified from our coherence and power plots with conditions pooled and
% movements averaged. In coherence plots coh to ipsi and contra STN
% averaged
% that way locations identified in an unbiased manner 

%m1 
left_m1{1} = [-4 -2 5];
right_m1{1} = [4 -2 5];

left_m1{2} = [-5 -2 5];
right_m1{2} = [5 -2 5];

left_m1{3} = [-3 -2 5];
right_m1{3} = [3 -2 5];

left_m1{4} = [-4 -2 4];
right_m1{4} = [4 -2 4];

left_m1{5} = [-4 -2 6];
right_m1{5} = [4 -2 6];

left_m1{6} = [-4 -3 5];
right_m1{6} = [4 -3 5];

left_m1{7} = [-4 -1 5];
right_m1{7} = [4 -1 5];

%sma
left_sma{1} = [-1 -3 6];
right_sma{1} = [1 -3 6];

left_sma{2} = [-2 -3 6];
right_sma{2} = [2 -3 6];

left_sma{3} = [0 -3 6];
right_sma{3} = [0 -3 6];

left_sma{4} = [-1 -3 5];
right_sma{4} = [1 -3 5];

left_sma{5} = [-1 -3 7];
right_sma{5} = [1 -3 7];

left_sma{6} = [-1 -4 6];
right_sma{6} = [1 -4 6];

left_sma{7} = [-1 -2 6];
right_sma{7} = [1 -2 6];

coordis = {left_m1,right_m1,left_sma,right_sma};

save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/ROIs/coordis_coh_pow','.mat'],'coordis');

