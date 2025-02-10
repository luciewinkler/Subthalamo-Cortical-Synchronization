
%Calculate reaction times
%prepare data for anova with factors event and condition
%makes boxplots for RTs

load /data/project/hirsch/reverse/analysis/Info/rev_info
path_mov = '/data/project/hirsch/reverse/analysis/scripts/Final_analysis/event_detection/matfiles/';
path_save = '/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/beh/';
subjects = fieldnames(rev_info);
aligned_to = 'movaligned';

%experimental conditions
conditions = {'pred','unpred'};
events = {'reversals','start','stop'};

for s = rev_info.all_subjects_in_use %go through subjects 
    
    subj = subjects{s};
    
    for c = 1:numel(conditions) %go though conditions 
        
        current_condi = conditions{c};
        
        %for some subjects the pred conditions were recorded twice 
        files = {rev_info.(subj).(current_condi).file};
        
        for k = 1:numel(files) %go through files of pred conditions
            
            if k == 1
                run = 'run_1';
            else
                run = 'run_2';
            end
            
            for m = 1:3 %go through events 
                
                this_event = events{m};
                
                %load information on movements
                mov_file = [path_mov,'all_behav_dialtrigdatasubj',subj(end-1:end),(current_condi),num2str(k),'_clean'];
                load(mov_file);
                
                %find trig timings
                if m == 1
                    thistrigs = trigs.time(trigs.type == 0);
                elseif m == 2
                    thistrigs = trigs.time(trigs.type == 1);
                else
                    thistrigs = trigs.time(trigs.type == -1);
                end
                
                %find movement timings for the current event
                currMvmts = allMvmt.(this_event);
                
                cnt = 1;
                RTs.reversals_RT = [];
                RTs.start_RT = [];
                RTs.stop_RT = [];

                %go through each movement event time and find trigger
                %calculate RT
                for iMvmt = 1:numel(currMvmts)
                    
                    this_mov = currMvmts(iMvmt);

                    %find trig that belongs to movement
                    this_trig = find(thistrigs > this_mov-3 & thistrigs < this_mov+3);
                    
                    %
                    if ~isempty(this_trig)

                        %find the timing of that trigger
                        tr = thistrigs(this_trig);

                        %find RT
                        diffs = this_mov - tr; 

                        %if biger than 0, save it
                        if diffs>0

                            %add RTs in here
                            RTs.([this_event, '_RT'])(cnt)   = diffs;
                            
                            cnt = cnt + 1;
                        end
                    end
                end
                
                %save into struct
                all_RTs.(subj).(current_condi).(run).(this_event) = nanmean(RTs.([this_event, '_RT']));

                %take mean between the 2 runs 
                if numel(files) == 2 && k == 2
                    mean1 = all_RTs.(subj).(current_condi).run_1.(this_event);
                    mean2 = all_RTs.(subj).(current_condi).run_2.(this_event);
                    all_RTs.(subj).(current_condi).run_1.(this_event) = (mean1+mean2)/2; %store all of them in here finally
                end
            end
        end

        %delete run 2 because averaged data in run 1 
        if numel(files) == 2
            all_RTs.(subj).(current_condi) = rmfield([all_RTs.(subj).(current_condi)],'run_2');
        end
    end
end

data_stats = cell(20,6);
events = {'start','stop','reversals'};

%put them in the right format for ANOVA
for s = rev_info.all_subjects_in_use %go through subjects
    
    subj = subjects{s};
    
    for c = 1:numel(conditions) %go through conditions
        
        cond = conditions{c};
        
        for e = 1:numel(events) %go through events
            
            event = events{e};
            
            this_RT = all_RTs.(subj).(cond).run_1.(event);
            
            if c == 1
                data_stats{s,e} = this_RT;
            elseif c == 2
                data_stats{s,e+3} = this_RT;
            end
        end
    end
end

%save
data_RT = cell2mat(data_stats);
csvwrite('/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/RT_anova.csv',data_RT);

%make boxplots for RTs

%pred start vs unpred start 
dat_pred_start = data_RT(:,1);
dat_unpred_start = data_RT(:,4);
dat_all = horzcat(dat_pred_start,dat_unpred_start);
G = ones(size(dat_unpred_start));
G = [G;2*G];
x = ones(size(G,1),1),G(:);
h = boxchart(x(:),dat_all(:),'GroupByColor',G(:));
hold on
xticklabels({'',''})
ylim([0.4 1.3])
set(h,'Linewidth',2)
set(gca,'FontSize',60);
h(1).SeriesIndex = 7;
h(2).SeriesIndex = 1;
% legend('pred','unpred','Location','northwest')

savedir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/follow_up_tests/'];
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
set(gcf,'PaperOrientation','landscape')
print(gcf,'-dpdf','-r300','-fillpage',[savedir,'predvsunpred_start_RT','.pdf'])
close all

%pred stop vs unpred stop 
dat_pred_stop = data_RT(:,2);
dat_unpred_stop = data_RT(:,5);
dat_all = horzcat(dat_pred_stop,dat_unpred_stop);
G = ones(size(dat_unpred_stop));
G = [G;2*G];
x = ones(size(G,1),1),G(:);
h = boxchart(x(:),dat_all(:),'GroupByColor',G(:));
hold on
xticklabels({'',''})
ylim([0.4 1.3])
set(h,'Linewidth',2)
set(gca,'FontSize',60);
h(1).SeriesIndex = 7;
h(2).SeriesIndex = 1;
% legend('pred','unpred','Location','northwest')

savedir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/follow_up_tests/'];
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
set(gcf,'PaperOrientation','landscape')
print(gcf,'-dpdf','-r300','-fillpage',[savedir,'predvsunpred_stop_RT','.pdf'])
close all

%stop and start pred vs unpred in one plot
dat_pred_start = data_RT(:,1);
dat_unpred_start = data_RT(:,4);
dat_pred_stop = data_RT(:,2);
dat_unpred_stop = data_RT(:,5);
dat_all = vertcat(dat_pred_start,dat_unpred_start,dat_pred_stop,dat_unpred_stop);
G = ones(size(dat_unpred_stop));
G = [G;2*G;3*G;4*G];
x = ones(size(G,1),1),G(:);
h = boxchart(x(:),dat_all,'GroupByColor',G(:));
hold on
xticklabels({'',''})
ylim([0.4 1.3])
set(h,'Linewidth',2)
set(gca,'FontSize',60);
h(1).SeriesIndex = 3;
h(2).SeriesIndex = 2;
h(3).SeriesIndex = 3;
h(4).SeriesIndex = 2;
lgd = legend('pred','unpred','Location','northwest');
fontsize(lgd,40,'points');

savedir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/follow_up_tests/'];
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
set(gcf,'PaperOrientation','landscape')
print(gcf,'-dpdf','-r300','-fillpage',[savedir,'predvsunpred_stopandstart_RT','.pdf'])
close all

