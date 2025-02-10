
%makes table for ANOVA for granger 
%can also plot for all the data (i.e. seperately for all channels, hemis,
%condis, movements)

%get field names from rev info structure
load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);
data_dir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/granger_elife/';

freq_oi = 'beta';%{'beta','gamma'};

%experimental conditions
conditions = {'pred','unpred'};

%pick event before
events = {'start','stop','reversals'};

chans = {'contra_M1-contra_STN','ipsi_M1-ipsi_STN','contra_SMA-contra_STN','ipsi_SMA-ipsi_STN'};

%collect data for all subjects to make boxplots 
for s = rev_info.all_subjects_in_use
    
    subj = subjects{s};
    
    for c = 1:2
        
        current_condi = conditions{c};
        
        for e = 1:3
            
            event = events{e};

            for ch = 1:4 

                this_chan = chans{ch};

                %load data
                load([data_dir,'granger_',(subj),'_',(current_condi),'_',(event),'_',(this_chan),'_',(freq_oi),'.mat']);
                load([data_dir,'granger_rev_',(subj),'_',(current_condi),'_',(event),'_',(this_chan),'_',(freq_oi),'.mat']);

                %freq envelope
                cfg = [];
                if contains(freq_oi,'gamma')
                    cfg.frequency = [55 90];
                else
                    cfg.frequency = [13 30];
                end
                cfg.avgoverfreq = 'yes';
                this_grang = ft_selectdata(cfg,grang);
                this_grang_rev = ft_selectdata(cfg,grang_rev);

                %subtract the reversed data 
                this_grang.grangerspctrm = this_grang.grangerspctrm-this_grang_rev.grangerspctrm;

                %store them all
                beta_granger{e}{c}{ch}{s} = this_grang.grangerspctrm;

            end
        end
    end
end

bxplt1 = [];
bxplt2 = [];

%for each event, condi and channel, puts the individual values of subjects 
%in a single vector
%bxplt1 = cortex to STN 
%bxplt2 = STN to cortex 
for c = 1:2

    for e = 1:3

        for ch = 1:4

            for s = rev_info.all_subjects_in_use

                %add first subj
                if s == 1 
                    bxplt1{e}{c}{ch}  = [beta_granger{e}{c}{ch}{s}(1,2)]; %cortex to stn
                    bxplt2{e}{c}{ch}   = [beta_granger{e}{c}{ch}{s}(2,1)]; %stn to cortex
                else

                %add rest of the subj    
                bxplt1{e}{c}{ch}  = [bxplt1{e}{c}{ch}  beta_granger{e}{c}{ch}{s}(1,2)];
                bxplt2{e}{c}{ch}  = [bxplt2{e}{c}{ch}  beta_granger{e}{c}{ch}{s}(2,1)];

                end
            end
        end
    end
end

%append all the data
%this is the order:
%start pred contra M1 to STN, start pred contra STN to M1; 
%start unpred contra M1 to STN, start unpred contra STN to M1;
%stop ...
%stop ...
%rev...
%rev...
%start pred ipsi M1 to STN, start pred ipsi STN to M1; 
%start unpred ipsi M1 to STN, start unpred ipsi STN to M1;
%stop ...
%stop ...
%rev...
%rev...
%start pred contra SMA to STN, start pred contra STN to SMA 
%...
%start pred ipsi SMA to STN, start pred ipsi STN to SMA 

all_bxplt = [];
for ch = 1:4 

    for e = 1:3

        for c = 1:2

         all_bxplt = [all_bxplt vertcat(bxplt1{e}{c}{ch},bxplt2{e}{c}{ch})'];

        end
    end
end

%make a table for ANOVA 
tab = array2table(all_bxplt);
writetable(tab,['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/granger_elife/grang_',(freq_oi),'.xls'])

%colors
or = vertcat([0.7993    0.6595    0.2725],[0.9323    0.4524    0.2839]);
or = repmat(or,12,1);

bl =  vertcat([0.1846    0.7583    0.8047],[0.1342    0.3859    0.7021]);
bl =  repmat(bl,12,1);

cols = vertcat(or,bl);

data = all_bxplt;
x=1:48;

figure();
ax = axes();
hold(ax);
for i = 1:48
    bp = boxchart(x(i)*ones(size(data(:,i))),data(:,i),'BoxFaceColor',cols(i,:));
    set(bp,'LineWidth', 3);
    set(bp,'MarkerColor',cols(i,:))
end
set(gca,'XTicklabel',[])
yline(0,'k--')
set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/granger/elife/granger_boxplot_alldata_',(freq_oi),'.pdf'],'Resolution', 300')
close all

%testing directionality = 0
stats_stn2cortex = [];
stats_cortex2stn = [];

for ch = 1:2
    for e = 1:3
        for c = 1:2

            [h,p] = ttest(bxplt_final_cortex2stn{e}{c}{ch});
            stats_cortex2stn = [stats_cortex2stn p];
            stats_cortex2stn_all{e}{c}{ch} = p;

            [h,p] = ttest(bxplt_final_stn2cortex{e}{c}{ch});
            stats_stn2cortex = [stats_stn2cortex p];
            stats_stn2cortex_all{e}{c}{ch} = p;

        end
    end
end
