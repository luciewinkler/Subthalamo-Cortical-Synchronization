
%makes boxplots for granger causality in the beta band averaged over
%events, condis and hemispheres

%get field names from rev info structure
load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);
data_dir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/granger_elife/';

freq_oi = 'beta';%'beta','gamma'

%experimental conditions
conditions = {'pred','unpred'};

%pick event before
events = {'start','stop','reversals'};

hemis = {'contra','ipsi'};
hemispheres = {'contralateral','ipsilateral'};
chans = {'contra_M1-contra_STN','ipsi_M1-ipsi_STN','contra_SMA-contra_STN','ipsi_SMA-ipsi_STN'};

%collect data for all subjects to make boxplots 
for s = rev_info.all_subjects_in_use

    subj = subjects{s};

    for ch = 1:4

        this_chan = chans{ch};
        beta_granger_all{s}{ch} = [];

        for c = 1:2

            current_condi = conditions{c};

            for e = 1:3

                event = events{e};

                %load data
                load([data_dir,'granger_',(subj),'_',(current_condi),'_',(event),'_',(this_chan),'_',(freq_oi),'.mat']);
                load([data_dir,'granger_rev_',(subj),'_',(current_condi),'_',(event),'_',(this_chan),'_',(freq_oi),'.mat']);
             
                %freq envelope
                cfg = [];
                if contains(freq_oi, 'gamma')
                    cfg.frequency = [55 90];
                else
                    cfg.frequency = [13 30];
                end
                cfg.avgoverfreq = 'yes';
                this_grang = ft_selectdata(cfg,grang);
                this_grang_rev = ft_selectdata(cfg,grang_rev);

                %subtract the reversed granger spectrum
                this_grang.grangerspctrm = this_grang.grangerspctrm-this_grang_rev.grangerspctrm;

                %store them all (for each subject and channel: pools condis and
                %events; 3events x 2condis and each for ctx to stn and stn
                %to ctx)
                beta_granger_all{s}{ch} = [beta_granger_all{s}{ch} this_grang.grangerspctrm];
            end
        end
    end
end

beta_granger_all_comb = [];

%pool ipsi and contra 
for s = rev_info.all_subjects_in_use

    %pool contra and ipsi M1
    beta_granger_all_comb{s}{1} = horzcat(beta_granger_all{s}{1},beta_granger_all{s}{2});

    %pool contra and ipsi MSMC
    beta_granger_all_comb{s}{2} = horzcat(beta_granger_all{s}{3},beta_granger_all{s}{4});
end

chans_new = {'M1','MSMC'};
beta_granger = [];

%take means of all events, hemispheres and conditions for each subject 
for s = rev_info.all_subjects_in_use

    for ch = 1:numel(chans_new)

        %take mean of first row for cortex to stn, second row for stn to
        %cotex
        beta_granger{s}{ch} = vertcat([0 mean(beta_granger_all_comb{s}{ch}(1,2:2:24))],[mean(beta_granger_all_comb{s}{ch}(2,1:2:23)) 0]);
    end
end

bxplt1 = []; %cortex to stn
bxplt2 = []; %stn to cortex

%puts subject means into vectors for each channel 
for ch = 1:2

    for s = rev_info.all_subjects_in_use

        if s == 1
            bxplt1{ch}  = [beta_granger{s}{ch}(1,2)]; %cortex to stn
            bxplt2{ch}   = [beta_granger{s}{ch}(2,1)]; %stn to cortex
        else

            %other subjects 
            bxplt1{ch}  = [bxplt1{ch}  beta_granger{s}{ch}(1,2)];
            bxplt2{ch}  = [bxplt2{ch}  beta_granger{s}{ch}(2,1)];
        end
    end
end

%prepares data for plotting: puts cortex to stn and stn to cortex next to
%each other
%this is the order:
%m1-stn contra, stn-m1 contra, sma-stn contra, stn-sma contra, same for
%ipsi

all_bxplt = [];
for ch = 1:2 %M1 and SMA

    all_bxplt = [all_bxplt vertcat(bxplt1{ch},bxplt2{ch})'];
end

%plot

%colors
or = vertcat([0.7993    0.6595    0.2725],[0.9323    0.4524    0.2839]);
bl =  vertcat([0.1846    0.7583    0.8047],[0.1342    0.3859    0.7021]);
cols = vertcat(or,bl);

%distance of boxplots
data = all_bxplt;
x=[0 0.11 0.3 0.41]; 

fig = figure();
ax = axes();
hold(ax);
for i = 1:4
bp=boxchart(x(i)*ones(size(data(:,i))),data(:,i),'BoxFaceColor',cols(i,:));
    set(bp,'LineWidth', 3);
    bp.BoxWidth = 0.1;
    set(bp,'MarkerColor',cols(i,:))
end
orient(fig,'portrait')

set(gca,'Xlim',[-0.1 0.5])
set(gca,'Ylim',[-0.05 0.03])
set(gca,'XTick',[])
set(gca,'YTicklabel',[])
lgd = legend({'M1->STN','STN->M1','MSMC->STN','STN->MSMC'});
set(lgd,'Location','southwest')
set(lgd,'Orientation','vertical')
yline(0,'k--')
lgd.String(end) = [];
set(gca,'FontSize',16)
exportgraphics(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/granger/elife/granger_boxplot_avgdata_ipsicontra.',(freq_oi),'.pdf'],'Resolution', 300')
close all

%make table for directionality (used SPSS for follow up tests and cohens d)
tab = array2table(all_bxplt);
writetable(tab,['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/granger_elife/directionality_',(freq_oi),'.xls'])

for ch = 1:2

    [h,p,ci,stats] = ttest(bxplt1{ch});
    stats_cortex2stn_all{ch} = p;

    [h,p,ci,stats] = ttest(bxplt2{ch});
    stats_stn2cortex_all{ch} = p;

end

