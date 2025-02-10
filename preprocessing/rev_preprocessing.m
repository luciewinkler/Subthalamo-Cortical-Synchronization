
%preprocessing of data & putting data into trials

alignedto = 'movaligned'; %trigaligned or movaligned
dial = 0; %if oonly the dial channel in needed put 1 
%Need to look at high freq oscillations? in that case no downsampling to 500 Hz, but 1000 Hz 
HFO = 0;

%%%%%%%%%%%%%%%%%%
% add paths
path_data = '/data/project/hirsch/reverse/analysis/intermediate_data/data/tSSS/';
% path_data = '/data/tmp/lucie/'; %tsss data is large, if needed put in tmp
path_save = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'];

if HFO == 1 
    %possibly cannot save it in the project folder due to space
    path_save = ['/data/tmp/data_lucie/'];
    path_data = ['/data/tmp/data_lucie/'];
end

path_mov = '/data/project/hirsch/reverse/analysis/scripts/Final_analysis/event_detection/matfiles/';
addpath '/data/project/hirsch/reverse/analysis/scripts/Final_analysis/';
path_artfct = '/data/project/hirsch/reverse/analysis/Info/arfctdef/';

load /data/project/hirsch/reverse/analysis/Info/rev_info

%get field names from rev info structure
subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred','rest'};

events = {'reversals','start','stop'};

pre = 2;
post = 2;

for i = rev_info.all_subjects_in_use
    
    %select current subject
    subj = subjects{i};
    
    %loop through all conditions of current subject
    for j = 1:2
       
        %select current condition 
        current_condi = conditions{j};
        
        %chek how many datasets there are for this condition
        files = {rev_info.(subj).(current_condi).file};
        
        %can only use some of the data of subj 18 due to mistake while measuring
        if contains(subj,'s18')
            files_new = cell(1,1);
            files_new{1,1} = files{1};
            files = files_new;
        end
        
        % go through all files of subject
        for k = 1:length(files)
            
            art = 0;

            %get relevant file of current condition
            if contains(current_condi,'rest') && contains(subj,'s23') %in this case rest is contained in pred 
                rawfile = [path_data,subj,'_pred_',num2str(k),'_tSSS','.fif'];
            else
                rawfile = [path_data,subj,'_',current_condi,'_',num2str(k),'_tSSS','.fif'];
            end
            
            if contains(subj,'s05') && contains(current_condi,'unpred') && k == 1
                addpath('/data/project/hirsch/reverse/dacq/raw/sub-05/ses-01/meg/200604/')
                rawfile = 'revs05_unpred1.fif';
            end
            
            %load all data
            cfg = [];
            cfg.dataset = rawfile;
            cfg.demean = 'yes';
            data = ft_preprocessing(cfg);
            
            %Downsample data
            cfg = [];
            cfg.resamplefs = 500;
            if HFO == 1
                cfg.resamplefs = 1000;
            end
            data = ft_resampledata(cfg,data);
            
            if j == 3 && contains(subj,'s23')
                cfg = [];
                cfg.latency = [0 234]; %this is where patient rests
                data = ft_selectdata(cfg,data);
                %switch it from rest to pred1 so that it loads the right
                %artifact file
                current_condi = 'pred';
            end
                        
            %get meg and lfp artifacts (identified before)
            artifacts_file_meg = [path_artfct,'artifacts_tsss_',(subj),(current_condi),num2str(k),'.mat'];
            artifacts_file_lfp = [path_artfct,'artifacts_EEG_',(subj),current_condi,num2str(k),'.mat'];
            
            %load lfp artifacts, if any
            if isfile(artifacts_file_lfp)
                load(artifacts_file_lfp)
                artfct_lfp = artifacts_eeg.artfctdef.visual.artifact;
                art = 1;
            end
            
            %load meg artifacts, if any
            if isfile(artifacts_file_meg)
                load(artifacts_file_meg)
                artfct_meg = artifacts_tsss.artfctdef.visual.artifact;
                art = 1;
            end
            
            %combine them
            if isfile(artifacts_file_lfp) && isfile(artifacts_file_meg)
                all_artfct = vertcat(artfct_meg,artfct_lfp);
                all_artfct = sort(all_artfct,1);
            elseif isfile(artifacts_file_meg)
                all_artfct = artfct_meg;
            elseif isfile(artifacts_file_lfp)
                all_artfct = artfct_lfp;
            end 
            
            %partial artifact rejection (with NaNs)
            if art == 1
                cfg = [];
                cfg.artfctdef.visual.artifact = all_artfct;
                cfg.artfctdef.reject = 'partial';
                data = ft_rejectartifact(cfg,data);
            end
 
            if j == 3 && contains(subj,'s23')
                current_condi = 'rest'; %change back for correctly saving it under "rest"
            end

            if dial == 0

                % Get MEG data and apply HP filter 
                cfg = [];
                cfg.channel = {'MEG***2','MEG***3'};
                cfg.hpfilter = 'yes';
                cfg.hpfreq = 1;
                cfg.hpfilttype = 'fir';
                meg = ft_selectdata(cfg,data);

                %bad lfp channels 
                bad_chan = rev_info.(subj).(current_condi)(k).bad_lfp;

                % Get LFP Data
                cfg = [];
                cfg.channel = {'EEG***'};
                lfp = ft_selectdata(cfg,data);

                %rereferencing LFP data 
                cfg = [];
                if contains(rev_info.(subj).dbs_system,'medtronic')
                    cfg.montage = rev_medtronic_montage_wo_badchans(bad_chan);
                    lfp = ft_preprocessing(cfg,lfp);
                else
                    cfg.montage = rev_abbot_montage_wo_badchans(bad_chan);
                    lfp = ft_preprocessing(cfg,lfp);
                end

                %apply HP filter to LFP data
                cfg = [];
                cfg.hpfilter = 'yes';
                cfg.hpfreq = 1;
                cfg.hpfilttype = 'fir';
                lfp = ft_preprocessing(cfg,lfp);

                %take the other channels
                cfg = [];
                cfg.channel = {'MISC***','EMG***','STI101','EOG*'};
                other_chans = ft_preprocessing(cfg,data);

                %now combine all
                cfg = [];
                cfg.keepsampleinfo = 'no';
                all_data_clean = ft_appenddata(cfg,meg,lfp,other_chans);

            else

                %select dial channel
                cfg = [];
                cfg.channel = 'MISC***';
                all_data_clean = ft_preprocessing(cfg,data);

            end
            
            %save without putting into trials if rest data
            if contains(current_condi, 'rest')

                save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/rest/clean_meg_mov_',(subj),(current_condi),'.mat'],'all_data_clean');
            
            else
                
                for h = 1:3
                    
                    %create each event (start, stop, reversal)
                    event = events{h};
                    
                    % load movement file, contains events
                    mov_file = [path_mov,'all_behav_dialtrigdatasubj',subj(end-1:end),(current_condi),num2str(k),'_clean'];
                    load(mov_file);
                    
                    %if want datato be trigger-aligned find trigger
                    %time-points
                    if contains(alignedto,'trigaligned')
                        if contains(event,'reversals')
                            triggers = trigs.time(trigs.type==0);
                        elseif contains(event,'start')
                            triggers = trigs.time(trigs.type==1);
                        else
                            triggers = trigs.time(trigs.type==-1);
                        end
                        %create trials around trigger
                        rev_trl = round([triggers'-pre, triggers'+post, zeros(size(triggers',1),1)]*all_data_clean.fsample);
                    else
                        % load event and create trials around movement
                        rev_trl = round([allMvmt.(event)'-pre, allMvmt.(event)'+post, zeros(size(allMvmt.(event)',1),1)]*all_data_clean.fsample);
                        %take only instructed events
                        rev_trl = rev_trl(allMvmt.([event,'_cued']),:);
                    end
                    
                    %define trials from clean data
                    cfg = [];
                    cfg.trl = rev_trl;
                    rev_trials = ft_redefinetrial(cfg,all_data_clean);
                    
                    %redefine time 0
                    cfg = [];
                    cfg.offset = -pre*rev_trials.fsample;
                    rev_trials = ft_redefinetrial(cfg,rev_trials);
                    
                    %some conditions were recorded twice, combine them or
                    %else save
                    if numel(files) > 1
                        comb_trial{h}{k} = rev_trials;
                    else
                        save([path_save,'clean_meg_mov_',(subj),(current_condi),(event),'.mat'],'rev_trials');
                    end
                end
            end
        end
        
        %combine if 2 files exist
        if numel(files) > 1

            %in case theydont have the same LFPs only choose the ones they
            %have in common 
            [C,a,b] = intersect(comb_trial{1}{1}.label,comb_trial{1}{2}.label,'stable');

            %go through events to combine data
            for e = 1:3 

                cfg = [];
                event = events{e};
                cfg.channel = C;
                comb_trial{e}{1} = ft_selectdata(cfg,comb_trial{e}{1});
                comb_trial{e}{2} = ft_selectdata(cfg,comb_trial{e}{2});
                
                cfg = [];
                cfg.keepsampleinfo = 'no';
                rev_trials = ft_appenddata(cfg,comb_trial{e}{1},comb_trial{e}{2});
                rev_trials.hdr = comb_trial{1}{1}.hdr;
                rev_trials.grad = comb_trial{1}{1}.grad;

                %save combined data
                save([path_save,'clean_meg_mov_',(subj),(current_condi),(event),'.mat'],'rev_trials');
            end
        end
    end
end
