
%The tables for the ANOVAS (coh, pow, and lateralization) have to be
%restructured to be plugged into SPSS 

%choose what to do: coherence and power tables or lateralization tables 
cohpow = 1;
lateralization = 0;

%%%%%%%%%%%%%
load /data/project/hirsch/reverse/analysis/Info/rev_info

alignedto = 'movaligned';
datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/final_tables/';
load /data/project/hirsch/reverse/analysis/Info/rev_info

gamma = 0; 

%here tables for coherence and power are restructered 
if cohpow == 1

    %%%%%coherence

    %load tables with coherence and power data
    if gamma == 1
        load([datadir,'gamma/tables_for_stats_movaligned_gamma.mat']);
    else
        load([datadir,'beta_pow_coh/tables_for_stats_movaligned_final.mat']);
    end

    %easier to work with 
    coh_table = table2cell(coh_tbl);
    data_to_anova = string(coh_table);

    subjects = fieldnames(rev_info);
    areas = {'STN-M1 contra' 'STN-SMA contra' 'STN-M1 ipsi' 'STN-SMA ipsi'};

    subj_id = table2cell(coh_tbl(:,1));
    speed = nan(1,numel(subj_id))';

    data_to_anova(:,7) = speed;
    
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
        data_to_anova(pr,7) = pred_speed;
        %add this subject's unpred Speed
        unpr = [this_subj(numel(this_subj)/2+1):this_subj(end)]';
        data_to_anova(unpr,7) = unpred_speed;
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
        data_spss_coh_bl{a} = [pred_start(:,6) pred_stop(:,6) pred_reversal(:,6) unpred_start(:,6) unpred_stop(:,6) unpred_reversal(:,6)];
        data_spss_coh_nobl{a} = [pred_start(:,5) pred_stop(:,5) pred_reversal(:,5) unpred_start(:,5) unpred_stop(:,5) unpred_reversal(:,5)];
    end

    %add the speed by just adding one event for pred and unpred (doesnt matter which one because speed doesnt vary with event)
    data_spss_coh_bl = horzcat(data_spss_coh_bl{1},data_spss_coh_bl{2},data_spss_coh_bl{3},data_spss_coh_bl{4},pred_start(:,7),unpred_start(:,7));
    data_spss_coh_nobl = horzcat(data_spss_coh_nobl{1},data_spss_coh_nobl{2},data_spss_coh_nobl{3},data_spss_coh_nobl{4},pred_start(:,7),unpred_start(:,7));
    
    %save the data
    data_spss_coh_bl = str2double(data_spss_coh_bl);
    tab = array2table(data_spss_coh_bl);
    if gamma == 1
        writetable(tab,[datadir,'beta_pow_coh/coh_bl_gamma.xls'])
    else
        writetable(tab,[datadir,'beta_pow_coh/coh_bl_beta.xls'])
    end
    
    save([datadir,'beta_pow_coh/data_to_spss_coh_bl_final.mat'],'data_spss_coh_bl');
    save([datadir,'beta_pow_coh/data_to_spss_coh_nobl_final.mat'],'data_spss_coh_nobl');
    
    %%%%%%%%%%%%%%%%%  power
    
    pow_table = table2cell(pow_tbl);
    data_to_anova = string(pow_table);
    
    subj_id = table2cell(pow_tbl(:,1));   
    
    areas = {'STN contra' 'M1 contra' 'SMA contra' 'STN ipsi' 'M1 ipsi' 'SMA ipsi'};
    speed = nan(1,numel(subj_id))';

    data_to_anova(:,7) = speed;
        
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
        data_to_anova(pr,7) = pred_speed;
        %add this suebjct's unpred Speed
        unpr = this_subj(numel(this_subj)/2+1):this_subj(end);
        unpr = unpr';
        data_to_anova(unpr,7) = unpred_speed;
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
        data_spss_pow_bl{a} = [pred_start(:,6) pred_stop(:,6) pred_reversal(:,6) unpred_start(:,6) unpred_stop(:,6) unpred_reversal(:,6)];
        data_spss_pow_nobl{a} = [pred_start(:,5) pred_stop(:,5) pred_reversal(:,5) unpred_start(:,5) unpred_stop(:,5) unpred_reversal(:,5)];
    end
    
    %add the speed by just adding one event for pred and unpred (doesnt matter which one because speed doesnt vary with event)
    data_spss_pow_bl = horzcat(data_spss_pow_bl{1},data_spss_pow_bl{2},data_spss_pow_bl{3},data_spss_pow_bl{4}, data_spss_pow_bl{5}, data_spss_pow_bl{6},pred_start(:,7),unpred_start(:,7));
    data_spss_pow_nobl = horzcat(data_spss_pow_nobl{1},data_spss_pow_nobl{2},data_spss_pow_nobl{3},data_spss_pow_nobl{4},data_spss_pow_nobl{5},data_spss_pow_nobl{6},pred_start(:,7),unpred_start(:,7));
    
    %save data
    data_spss_pow_bl = str2double(data_spss_pow_bl);
    tab = array2table(data_spss_pow_bl);
    if gamma == 1
        writetable(tab,[datadir,'beta_pow_coh/pow_bl_gamma.xls'])
    else
        writetable(tab,[datadir,'beta_pow_coh/pow_bl_beta.xls'])
    end  

    save([datadir,'beta_pow_coh/data_spss_pow_bl_final.mat'],'data_spss_pow_bl');
    save([datadir,'beta_pow_coh/data_to_spss_pow_nobl_final.mat'],'data_spss_pow_nobl');
 
else

    %load the data
    load([datadir,'lat_peakfreq/lateralization_final.mat']);
    
    table = table2cell(tbl);
    data_to_anova = string(table);

    subjects = fieldnames(rev_info);
    
    subj_id = table2cell(tbl(:,2));
    
    areas = {'STN','M1 ','SMA'};
    
    %first find area of interest, then MRBD and PMBR and corresponding lateralization values
    for a = 1:numel(areas) 

        %only choose rows with area of interest
        pick_area_oi = areas{a};
        
        [row,column] = find(strcmp(table,pick_area_oi));
        area_oi = data_to_anova(row,:);
        
        %within area of interest find MRBD and PMBR
        %MRBD
        [row,column] = find(strcmp(area_oi,'MRBD'));
        MRBD = area_oi(row,:);
        [row,column] = find(strcmp(MRBD,'unpred'));
        unpred_MRBD = MRBD(row,:);
        [row,column] = find(strcmp(MRBD,'pred'));
        pred_MRBD = MRBD(row,:);
        
        %make pmbr
        [row,column] = find(strcmp(area_oi,'PMBR'));
        PMBR = area_oi(row,:);
        [row,column] = find(strcmp(PMBR,'unpred'));
        unpred_PMBR = PMBR(row,:);
        [row,column] = find(strcmp(PMBR,'pred'));
        pred_PMBR = PMBR(row,:);
        
        %combine the data
        data_lat{a} = [pred_MRBD(:,5) pred_PMBR(:,5) unpred_MRBD(:,5) unpred_PMBR(:,5)];
        
    end

    %save the data
    data_spss_lat = horzcat(data_lat{1},data_lat{2},data_lat{3});
    data_spss_lat = str2double(data_spss_lat);
    tab = array2table(data_spss_lat);
    writetable(tab,[datadir,'lat_peakfreq/lat.xls'])

    save([datadir,'lat_peak/data_spss_lat_final.mat'],'data_spss_lat');
end

    
    