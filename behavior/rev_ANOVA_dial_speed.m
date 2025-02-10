
%prepare data for anova with factors event and condition for dial speed 

aligned_to = 'movaligned'; %movaligned or trigaligned

load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred'};

pre = 2;
post = 2;

%pick event before
events = {'reversals','start','stop'};

%plot individual trials
plot_ind = false;

%size of median filter
nfilt = 70;

event_mean = [];

for s = rev_info.all_subjects_in_use %go through subjects
    
    subj = subjects{s};
    
    for c = 1:numel(conditions) %go through conditions
        
        cond = conditions{c};
        
        cond_mean_dialspeed = [];
        
        for e = 1:numel(events) %go through events
            
            event = events{e};
            
            if contains(aligned_to,'movaligned')
                datapath = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(aligned_to),'/trialed/clean_meg_mov_',subj,cond,num2str(1),event,'.mat'];
            else
                datapath = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(aligned_to),'/trialed/clean_meg_mov_',subj,cond,event,'.mat'];
            end
            
            %load the wheel data
            load(datapath);
            
            %select wheel signal
            cfg = [];
            cfg.dataset = datapath;
            cfg.channel = 'MISC*';
            dial = ft_selectdata(cfg,rev_trials);
            
            diff_vector_filt = nan(numel(dial.trial),length(dial.time{2}(2:end-1)));
            
            %calculate turnign speed for each trial over time
            for i = 1:numel(dial.trial)
                
                raw_angle_vector = dial.trial{i};
                
                %360 degress correspond to 10V
                %signal ranges between -5 and 5
                %shift to 0 - 10
                angle_vector = raw_angle_vector+5;
                %change from V to deg
                angle_vector = angle_vector*36;
                
                %unwrap angle
                uw_angle_vector = unwrap(angle_vector);
                
                %angle difference
                a = uw_angle_vector(2:end);
                b = uw_angle_vector(1:end-1);
                this_dial_speed = abs(diff([a;b],1,1))*dial.fsample;
                this_dial_speed_filt = medfilt1(this_dial_speed,nfilt,'truncate');
                
                %this is necessary due to minute differences in trial
                %length
                while length(this_dial_speed_filt)>length(diff_vector_filt)
                    this_dial_speed_filt = this_dial_speed_filt(:,1:end-1);
                end
                
                diff_vector_filt(i,:) = this_dial_speed_filt;
            end
            
            %this is the dial speed
            dial_speed = diff_vector_filt;
            
            %the absolute turns noise into positive bias
            %subtract min to remove bias
            dial_speed = dial_speed-nanmin(nanmin(dial_speed));
            
            %get trial average speed for each time point (1x1999)
            dial_speed = nanmean(dial_speed);
            
            %for all events plot whole window but only use movement periods
            if contains(event,'start') %for start and stop only use actual movement
                dial_speed = dial_speed(1000:numel(dial_speed)); %thats where movement begins
            elseif contains(event,'stop')
                dial_speed = dial_speed(1:1000); %thats where stop begins
            elseif contains(event,'reversals')
                %for reversals, we used the whole time window in the paper
                %dial_speed = horzcat(dial_speed(1:500),dial_speed(1500:numel(dial_speed)));
            end
            
            %one average value for each event and put in struct
            event_mean.(subj).(cond).(event) = nanmean(dial_speed);
        end
    end
end

%restructure the data for ANOVA 
data_stats = cell(20,6);
events = {'start','stop','reversals'};

for s = rev_info.all_subjects_in_use %go through subjects 
    
    subj = subjects{s};
    
    for c = 1:numel(conditions) %go through conditions
        
        cond = conditions{c};
        
        for e = 1:numel(events) %go through events
            
            event = events{e};
            
            this_speed = event_mean.(subj).(cond).(event);
            
            if c == 1
                data_stats{s,e} = this_speed;
            elseif c == 2
                data_stats{s,e+3} = this_speed;
            end
        end
    end
end

%save data
data_dial = cell2mat(data_stats);

if contains(aligned_to,'movaligned')
    csvwrite('/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/dial_anova.csv',data_dial);
else
    csvwrite('/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/dial_anova_trigaligned.csv',data_dial);
end


