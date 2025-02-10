
%calculates the dial speed for statistics
%plots the different types of events 

aligned_to = 'movaligned'; %movaligned or trigaligned

load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred'};

pre = 2;
post = 2;

%events
events = {'reversals','start','stop'};

%plot individual trials
plot_ind = false;

%size of median filter
nfilt = 70;

event_mean_plot = [];
event_mean = [];

for s = rev_info.all_subjects_in_use %go through subjects 
    
    subj = subjects{s};
    
    for c = 1:numel(conditions) %go through conditions 
        
        cond = conditions{c};
        
        cond_mean_dialspeed = [];
        
        for e = 1:numel(events) %go through movements 
            
            event = events{e};
            
            if contains(aligned_to,'movaligned')
                datapath = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(aligned_to),'/trialed/clean_meg_mov_',subj,cond,num2str(1),event,'.mat'];
            else
                datapath = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(aligned_to),'/trialed/clean_meg_mov_',subj,cond,event,'.mat'];
            end
            
            %load the data
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
            
            dial_speed_time = dial.time{2}(2:end-1);

            %this is the dial speed
            dial_speed = diff_vector_filt;
            
            %the absolute turns noise into positive bias
            %subtract min to remove bias
            dial_speed = dial_speed-nanmin(nanmin(dial_speed));
            
            %save for individual subject for power subject plots 
            time_new = [-1.424:0.002:1.424];
            avg_speed = nanmean(dial_speed);
            dial_speed_new = avg_speed(287:(numel(dial_speed_time)-288));
            save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',(aligned_to),'/',event,'/',cond,'/',subj,'_dialspeedToPlot.mat'],'dial_speed_new');

            % figure;
            % % plot(dial_speed_time,nanmean(dial_speed));
            % plot(time_new,dial_speed_new);
            % if contains(aligned_to,'movaligned') && contains(event,'start')
            % ylabel('Turning Speed [deg/s]');
            % xlabel('Time [s]');
            % end
            % title([subj,' ',event,' ',cond])
            % close all

            %get trial average speed for each time point
            dial_speed = nanmean(dial_speed);

            %for plotting with whole time window
            event_speed_plot = dial_speed;
            event_mean_plot.(subj).(cond).(event) = event_speed_plot;
            
            %for stats only use movement periods
            if contains(event,'start') %for start and stop only use actual movement
                dial_speed = dial_speed(1000:numel(dial_speed)); %thats where movement begins
            elseif contains(event,'stop')
                dial_speed = dial_speed(1:1000); %until movement ends
            elseif contains(event,'reversals')
                  %chose to keep entire reversal window
                  %dial_speed = horzcat(dial_speed(1:500),dial_speed(1500:numel(dial_speed)));
            end
            
            %one average value for each event and put in struct
            event_mean.(subj).(cond).(event) = nanmean(dial_speed);
            
            %3 events go in here for average across conditions
            cond_mean_dialspeed = [cond_mean_dialspeed,nanmean(nanmean(dial_speed))];
        end

        %one mean for each condi per subj; used in ANOVA as covariate
        cond_mean_dialspeed_struct.(subj).(cond) = mean(cond_mean_dialspeed);
    end
end

%save data 
save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',(aligned_to),'/condmean_dialspeed_nopause.mat','cond_mean_dialspeed_struct']);

%restructure for ANOVA 
all_speed = zeros(2,20)';

for f = rev_info.all_subjects_in_use %go throughvsubjects 

    subj = subjects{f};

    for p = 1:2 %go through conditions

        current_condi = conditions{p};

        %store for this subject
        all_speed(f,p) = cond_mean_dialspeed_struct.(subj).(current_condi);
    end
end

csvwrite('all_speed.csv',all_speed);
save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',(aligned_to),'/all_speed_anova.mat','all_speed']);

%plotting seperately for pred and unpred for each event 
for e = 1:3
    
    %initialize
    event = events{e};
    spec_condis = [];
    gr_condis = [];
    spec_sems = [];
    
    for c = 1:numel(conditions) %go through conditions 
        
        cond = conditions{c};
        
        spec_avg = [];
        gr_avg = [];
        
        for s = rev_info.all_subjects_in_use %go through subjects 
            
            subj = subjects{s};
            
            %get this subject's trial-avg speed
            this_spec = event_mean_plot.(subj).(cond).(event);
            
            %slighely adjust length
            if length(this_spec) == 2000
                this_spec = this_spec(1:numel(this_spec)-2);
            elseif length(this_spec) == 1999
                this_spec = this_spec(1:numel(this_spec)-1);
            end

            spec_avg = [spec_avg;this_spec]; %get all subjects speed vectors
        end
        
        spec_gr = mean(spec_avg,1); %take grandaverage of all subjects speed vectors
        spec_sem = std(spec_avg,0,1) / sqrt(20); %take SEM 
        
        %put in struct
        spec_condis.(cond) = spec_gr;
        spec_sems.(cond) = spec_sem;
    end

    %plot for predictable condition 
    time = [-1.9970:0.002:1.9970];
    v = shadedErrorBar(time,spec_condis.unpred,spec_sems.unpred,'b');
    set(v.edge,'LineWidth',1,'LineStyle',':')
    v.mainLine.LineWidth = 3;
    set(v.patch,'FaceAlpha',0.6)
    ylim([0 600])
    hold on

    %plot for unpredictable condition 
    s = shadedErrorBar(time,spec_condis.pred,spec_sems.pred,'r');
    set(s.edge,'LineWidth',1,'LineStyle',':')
    s.mainLine.LineWidth = 3;
    set(s.patch,'FaceAlpha',0.6)
    ylim([0 600])
 
    %specifications for plots in paper
    if e == 1
        xlim([-1 2])
    elseif e == 3
        xlim([-2 1.5])
    else
        xlim([-0.5 2])
    end

    if ~contains(event,'start') %start with yticks 
        set(gca,'YTick',[])
    end

    if ~contains(aligned_to,'trigaligned') %only trigaligned with x-axis
        set(gca,'XTick',[])
    end

    if contains(aligned_to,'movaligned') && e == 3
        legend([s.mainLine v.mainLine],{'pred','unpred'},'Location',[0.72,0.65,0.1,0.1])
        h = legend([s.mainLine v.mainLine],{'pred','unpred'});
        set(h,'FontSize',60);
        set(h.EntryContainer.Children,'Linewidth',7);
        legend('boxoff')
    end

    %add title 
    if contains(aligned_to,'movaligned')
        if contains(event,'reversals')
            event = 'Reversal';
        elseif contains(event,'start')
            event = 'Start';
        else
            event = 'Stop';
        end
        title(event,'FontWeight','normal')
    end

    ax = gca;
    ax.FontSize = 60;
    hold off

    %save 
    savedir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/dialspeed/',(aligned_to),'/grandavg/'];
    saveas(gcf,[savedir,'dialspeed_grandavg_',(event),'.jpeg']);
    saveas(gcf,[savedir,'dialspeed_grandavg_',(event),'.fig']);
    set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'PaperOrientation','landscape')
    print(gcf,'-dpdf','-r300','-fillpage',[savedir,'dialspeed_grandavg_pdf_',event,'.pdf'])
    close all

    % for adding condition-average dial speed to TFR plots
    spec_pred_unpred = (spec_condis.pred+spec_condis.unpred) ./2;
    spec_condis_new = spec_pred_unpred(287:(numel(time)-287)); %in average plots I am not using the entire window
    save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',(aligned_to),'/spec_pred_unpred_plot_',(event),'.mat'],'spec_condis_new');

    %seperately for pred 
    spec_pred = spec_condis.pred;
    spec_new = spec_pred(287:(numel(time)-287));
    save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',(aligned_to),'/spec_pred_plot_',(event),'.mat'],'spec_new');

    %Seperately for unpred
    spec_unpred = spec_condis.unpred;
    spec_new = spec_unpred(287:(numel(time)-287));
    save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',(aligned_to),'/spec_unpred_plot_',(event),'.mat'],'spec_new');
end

