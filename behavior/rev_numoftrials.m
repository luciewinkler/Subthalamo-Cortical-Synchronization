%get number of trials per subjects for each condition and movement

alignedto = 'movaligned';
path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'];
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/');

load /data/project/hirsch/reverse/analysis/Info/rev_info

subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred','rest'};
events = {'start','stop','reversals'};

for s = rev_info.all_subjects_in_use %go through subjects
    
    subj = subjects{s};

    %initialize
    trlnum_pred.(subj).start = [];
    trlnum_pred.(subj).stop = [];
    trlnum_pred.(subj).reversals = [];
    trlnum_unpred.(subj).start = [];
    trlnum_unpred.(subj).stop = [];
    trlnum_unpred.(subj).reversals = [];
    
    for j = 1:2 %go through conditions
        
        current_condi = conditions{j};
        numcond = [];
                        
        for f = 1:3 %go through events
            
            event = events{f};

            % load clean data
            file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(event)];
            load(file_oi);
                
            %store the number of trials 
            if j == 1
                trlnum_pred.(subj).(event) = [trlnum_pred.(subj).(event) numel(rev_trials.trial)];
            else
                trlnum_unpred.(subj).(event) = [trlnum_unpred.(subj).(event) numel(rev_trials.trial)];
            end
        end
    end
end

tr_start_pred = [];  
tr_stop_pred = [];      
tr_rev_pred = [];  
tr_start_unpred = [];  
tr_stop_unpred = [];      
tr_rev_unpred = [];  

%stores each subjects value to average
for s = rev_info.all_subjects_in_use
    
    subj = subjects{s};
    
    tr_start_pred = [tr_start_pred sum(trlnum_pred.(subj).start)];
    tr_stop_pred = [tr_stop_pred sum(trlnum_pred.(subj).stop)];
    tr_rev_pred = [tr_rev_pred sum(trlnum_pred.(subj).reversals)];
    
    tr_start_unpred = [tr_start_unpred sum(trlnum_unpred.(subj).start)];
    tr_stop_unpred = [tr_stop_unpred sum(trlnum_unpred.(subj).stop)];
    tr_rev_unpred = [tr_rev_unpred sum(trlnum_unpred.(subj).reversals)];

end

%calulate means and SDs
mean_start_pred = mean(tr_start_pred);
std_start_pred = std(tr_start_pred);
mean_start_unpred = mean(tr_start_unpred);
std_start_unpred = std(tr_start_unpred);

mean_stop_pred = mean(tr_stop_pred);
std_stop_pred = std(tr_stop_pred);
mean_stop_unpred = mean(tr_stop_unpred);
std_stop_unpred = std(tr_stop_unpred);

mean_rev_pred = mean(tr_rev_pred);
std_rev_pred = std(tr_rev_pred);   
mean_rev_unpred = mean(tr_rev_unpred);
std_rev_unpred = std(tr_rev_unpred);   

