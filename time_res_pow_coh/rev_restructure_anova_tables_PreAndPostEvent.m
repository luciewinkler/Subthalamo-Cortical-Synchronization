%The tables for the ANOVAS (coh, pow, and lateralization) have to be
%restructured to be plugged into SPSS

%%%%%%%%%%%%%
load /data/project/hirsch/reverse/analysis/Info/rev_info

alignedto = 'movaligned';
datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/';
load /data/project/hirsch/reverse/analysis/Info/rev_info

%here tables for coherence and power are restructered

%%%%%coherence

%load tables with coherence and power data
load([datadir,'/tables_for_stats_movaligned_final_pre_and_post.mat']);

%easier to work with
coh_table = table2cell(coh_tbl);
data_to_anova = string(coh_table);

subjects = fieldnames(rev_info);
areas = {'STN-M1 contra' 'STN-SMA contra' 'STN-M1 ipsi' 'STN-SMA ipsi'};

subj_id = table2cell(coh_tbl(:,1));
speed = nan(1,numel(subj_id))';

data_to_anova(:,9) = speed;

%load each subject's dial speed (seperate for pred and unpred)
load(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/movaligned/condmean_dialspeed.mat']);

for i = rev_info.all_subjects_in_use

    subj = subjects{i};

    %get subject's dial speed
    pred_speed = [cond_mean_dialspeed_struct.(subj).pred];
    unpred_speed = [cond_mean_dialspeed_struct.(subj).unpred];

    %find that subject in table
    s = contains(data_to_anova(:,1),subj);
    this_subj = find(s==1);
    %add this suebjct's pred Speed
    pr = [this_subj(1):this_subj(numel(this_subj)/2)]';
    data_to_anova(pr,9) = pred_speed;
    %add this subject's unpred Speed
    unpr = [this_subj(numel(this_subj)/2+1):this_subj(end)]';
    data_to_anova(unpr,9) = unpred_speed;
end

%first find area of interest, then events and corresponding coherence value
for a = 1:numel(areas)

    pick_area_oi = areas{a};

    %only choose rows with area of interest
    [row,column] = find(strcmp(coh_table,pick_area_oi));
    area_oi = data_to_anova(row,:);

    %within area of interest find reversals, start and stop, pred and unpred
    %reversals
    [row,column] = find(strcmp(area_oi,'reversals'));
    revs = area_oi(row,:);
    [row,column] = find(strcmp(revs,'unpred'));
    unpred_reversal = revs(row,:);
    [row,column] = find(strcmp(revs,'pred'));
    pred_reversal = revs(row,:);

    %start
    [row,column] = find(strcmp(area_oi,'start'));
    starts = area_oi(row,:);
    [row,column] = find(strcmp(starts,'unpred'));
    unpred_start = starts(row,:);
    [row,column] = find(strcmp(starts,'pred'));
    pred_start = starts(row,:);

    %stop
    [row,column] = find(strcmp(area_oi,'stop'));
    stops = area_oi(row,:);
    [row,column] = find(strcmp(stops,'unpred'));
    unpred_stop = stops(row,:);
    [row,column] = find(strcmp(stops,'pred'));
    pred_stop = stops(row,:);

    %combine all data for that area
    data_spss_coh_post{a} = [pred_start(:,7) pred_stop(:,7) pred_reversal(:,7) unpred_start(:,7) unpred_stop(:,7) unpred_reversal(:,7)];
    data_spss_coh_pre{a} = [pred_start(:,8) pred_stop(:,8) pred_reversal(:,8) unpred_start(:,8) unpred_stop(:,8) unpred_reversal(:,8)];
end

%add the speed by just adding one event for pred and unpred (doesnt matter which one because speed doesnt vary with event)
data_spss_coh_post = horzcat(data_spss_coh_post{1},data_spss_coh_post{2},data_spss_coh_post{3},data_spss_coh_post{4},pred_start(:,9),unpred_start(:,9));
data_spss_coh_pre = horzcat(data_spss_coh_pre{1},data_spss_coh_pre{2},data_spss_coh_pre{3},data_spss_coh_pre{4},pred_start(:,9),unpred_start(:,9));

%save the data
data_spss_coh_pre = str2double(data_spss_coh_pre);
tab = array2table(data_spss_coh_pre);
writetable(tab,[datadir,'final_tables/beta_pow_coh/data_spss_coh_pre.xls'])

data_spss_coh_post = str2double(data_spss_coh_post);
tab = array2table(data_spss_coh_post);
writetable(tab,[datadir,'final_tables/beta_pow_coh/data_spss_coh_post.xls'])

%%%%%%%%%%%%%%%%%  power

pow_table = table2cell(pow_tbl);
data_to_anova = string(pow_table);

subj_id = table2cell(pow_tbl(:,1));

areas = {'STN contra' 'M1 contra' 'SMA contra' 'STN ipsi' 'M1 ipsi' 'SMA ipsi'};
speed = nan(1,numel(subj_id))';

data_to_anova(:,9) = speed;

%load each subject's dial speed (seperate for pred and unpred)
for i = rev_info.all_subjects_in_use

    subj = subjects{i};

    %get subject's dial speed
    pred_speed = [cond_mean_dialspeed_struct.(subj).pred];
    unpred_speed = [cond_mean_dialspeed_struct.(subj).unpred];

    %find that subject in table
    s = contains(data_to_anova(:,1),subj);
    this_subj = find(s==1);

    %add this suebjct's pred Speed
    pr = this_subj(1):this_subj(numel(this_subj)/2);
    pr = pr';
    data_to_anova(pr,9) = pred_speed;
    %add this suebjct's unpred Speed
    unpr = this_subj(numel(this_subj)/2+1):this_subj(end);
    unpr = unpr';
    data_to_anova(unpr,9) = unpred_speed;
end

%first find area of interest, then events and corresponding coherence value
for a = 1:numel(areas)

    %only choose rows with area of interest
    pick_area_oi = areas{a};

    [row,column] = find(strcmp(pow_table,pick_area_oi));
    area_oi = data_to_anova(row,:);

    %within area of interest find reversals, start and stop, pred and unpred reversals
    %reversals
    [row,column] = find(strcmp(area_oi,'reversals'));
    revs = area_oi(row,:);
    [row,column] = find(strcmp(revs,'unpred'));
    unpred_reversal = revs(row,:);
    [row,column] = find(strcmp(revs,'pred'));
    pred_reversal = revs(row,:);

    %starts
    [row,column] = find(strcmp(area_oi,'start'));
    starts = area_oi(row,:);
    [row,column] = find(strcmp(starts,'unpred'));
    unpred_start = starts(row,:);
    [row,column] = find(strcmp(starts,'pred'));
    pred_start = starts(row,:);

    %stops
    [row,column] = find(strcmp(area_oi,'stop'));
    stops = area_oi(row,:);
    [row,column] = find(strcmp(stops,'unpred'));
    unpred_stop = stops(row,:);
    [row,column] = find(strcmp(stops,'pred'));
    pred_stop = stops(row,:);

    %combine all data for that area
    data_spss_pow_post{a} = [pred_start(:,7) pred_stop(:,7) pred_reversal(:,7) unpred_start(:,7) unpred_stop(:,7) unpred_reversal(:,7)];
    data_spss_pow_pre{a} = [pred_start(:,8) pred_stop(:,8) pred_reversal(:,8) unpred_start(:,8) unpred_stop(:,8) unpred_reversal(:,8)];
end

%add the speed by just adding one event for pred and unpred (doesnt matter which one because speed doesnt vary with event)
data_spss_pow_post = horzcat(data_spss_pow_post{1},data_spss_pow_post{2},data_spss_pow_post{3},data_spss_pow_post{4}, data_spss_pow_post{5}, data_spss_pow_post{6},pred_start(:,9),unpred_start(:,9));
data_spss_pow_pre = horzcat(data_spss_pow_pre{1},data_spss_pow_pre{2},data_spss_pow_pre{3},data_spss_pow_pre{4},data_spss_pow_pre{5},data_spss_pow_pre{6},pred_start(:,9),unpred_start(:,9));

%save data
data_spss_pow_pre = str2double(data_spss_pow_pre);
tab = array2table(data_spss_pow_pre);
writetable(tab,[datadir,'final_tables/beta_pow_coh/data_spss_pow_pre.xls'])

data_spss_pow_post = str2double(data_spss_pow_post);
tab = array2table(data_spss_pow_post);
writetable(tab,[datadir,'final_tables/beta_pow_coh/data_spss_pow_post.xls'])

