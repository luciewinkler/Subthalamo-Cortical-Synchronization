
%violin plots to show beta power with movement-avg BL for pre- and post reversal
%seperately for ipsilateral and contralateral 
%info on BL: whole recording average BL: it does not average over areas or
%ipsi and contra sites: just the average of area x in hemisphere x over
%events 
%also seperately for condis (but both appear in violin plots)

use_type = 'freqmean';
%'move_avg', 'pre' or 'rest'
bl = 'move_avg';
frequency = 'beta';
%pick an event to make the plot for 
t = 1; %reversals = 1,start = 2,stop = 3

%%%%%%%%%%%%%%%%%
%get field names from rev info structure
load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);

datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/';
figuredir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/lcmv/movaligned/tfrs_and_correlations/',use_type,'/',bl,'/'];
if ~exist(figuredir,'dir')
    mkdir(figuredir)
end

conditions = {'pred','unpred'};
events = {'reversals','start','stop'};

chans = {'STN','M1'};
hemis = {'contra','ipsi'};
Rs = zeros(length(rev_info.all_subjects_in_use),numel(conditions),2,2,4);
Rs_bl = Rs;

for s = rev_info.all_subjects_in_use %go through subjects 
    
    subj = subjects{s};
    
    for c = 1:numel(conditions) %go through conditions
        
        cond = conditions{c};
        
        for h = 1:2 %go through hemispheres
            
            hemi = hemis{h};
            
            for a = 1:2 %go through brain areas
                
                area = chans{a};
                
                freq_dat = cell(1,3); 
                
                tfrs = {};
                tfrs_bl = {};
                specs = {};
                % rest = load([datadir,subj,'_rest_',hemi,'_powandcoh.mat']);
                
                for e = 1:3 %go through movements

                    event = events{e};

                    %load the data
                    pow = load([datadir,subj,'_',cond,'_',event,'_',hemi,'_powandcoh_nolog.mat']);
                    tfrs{e} = pow.tfr;
                    
                    if strcmp(bl,'pre')
                        
                        %bl correction using the pre-event time window
                        cfg = [];
                        cfg.baselinetype = 'relchange';
                        cfg.baseline = [-1.6 0];
                        bl_tfr = ft_freqbaseline(cfg,tfrs{e});
                        tfrs_bl{e} = bl_tfr;
                        
                    elseif strcmp(bl,'rest')
                        
                        %bl correction with resting-state power
                        rest_pow = 10.^(rest.spec.powspctrm);
                        restpow_4bl = repmat(rest_pow,[1,1,size(tfrs{e}.powspctrm,3)]);
                        bl_tfr = tfrs{e};
                        bl_tfr.powspctrm = (pow.tfr.powspctrm-restpow_4bl)./restpow_4bl;
                        tfrs_bl{e} = bl_tfr;
                    end
                    
                    specs{e} = pow.spec;
                end
                
                if strcmp(bl,'move_avg')

                    %use as BL all 3 movements 
                    tfr_move_avg = ft_freqgrandaverage([],tfrs{1:3});
                    avgmov = nanmean(tfr_move_avg.powspctrm,3);
                    avgmov_4bl = repmat(avgmov,[1,1,size(tfr_move_avg.powspctrm,3)]);

                    %subtract the BL
                    for e = 1:numel(tfrs)

                        new_bl_tfr = tfrs{e};
                        new_bl_tfr.powspctrm = (tfrs{e}.powspctrm-avgmov_4bl)./avgmov_4bl;
                        tfrs_bl{e} = new_bl_tfr;
                    end
                end
               
                %it now picks the event of interest chosen above
                tfr = tfrs{t};
                bl_tfr = tfrs_bl{t};
                event = events{t};
                chan_oi = [area,' ',hemi];

                %take the average over frequencies and only the area
                %and hemisphere of interest
                cfg = [];
                cfg.avgoverfreq = 'yes';
                cfg.frequency = [13 30];
                cfg.channel = chan_oi;
                this_data = ft_selectdata(cfg,tfr);
                this_data_bl = ft_selectdata(cfg,bl_tfr);

                %get pre and the post event (1s)
                cfg = [];
                cfg.latency = [-1 0];
                pre_rev_tfr = ft_selectdata(cfg,this_data);
                pre_rev_tfr_bl = ft_selectdata(cfg,this_data_bl);
                cfg.latency = [0 1];
                post_rev_tfr = ft_selectdata(cfg,this_data);
                post_rev_tfr_bl = ft_selectdata(cfg,this_data_bl);

                %take the mean pow of the pre and post time windows
                mean_post_pow = nanmean(post_rev_tfr.powspctrm,3);
                mean_post_pow_bl = nanmean(post_rev_tfr_bl.powspctrm,3);
                mean_pre_pow = nanmean(pre_rev_tfr.powspctrm,3);
                mean_pre_pow_bl = nanmean(pre_rev_tfr_bl.powspctrm,3);

                newchan = strrep(chan_oi,' ','');

                %store
                all_pow_post_bl.(cond).(newchan).(subj) = mean_post_pow_bl;
                all_pow_post.(cond).(newchan).(subj) = mean_post_pow;

                all_pow_pre_bl.(cond).(newchan).(subj) = mean_pre_pow_bl;
                all_pow_pre.(cond).(newchan).(subj) = mean_pre_pow;
            end
        end
    end
end

%make violin plots with pred and unpred in there and seperately for contra
%and ipsi M1 (and contra and ipsi STN) 

areas = {'M1contra','M1ipsi','STNcontra','STNipsi'};

for ar = 1:2 %go through areas of interest

    this_area = areas{ar};

    %initialize 
    this_dat_pred_bl_pre = [];
    this_dat_unpred_bl_pre = [];

    this_dat_pred_bl_post = [];
    this_dat_unpred_bl_post = [];

    for s = rev_info.all_subjects_in_use %go through subjects

        subj = subjects{s};

        %select the data
        this_dat_pred_bl_pre = [this_dat_pred_bl_pre all_pow_pre_bl.pred.(this_area).(subj)];
        this_dat_unpred_bl_pre = [this_dat_unpred_bl_pre all_pow_pre_bl.unpred.(this_area).(subj)];

        this_dat_pred_bl_post = [this_dat_pred_bl_post all_pow_post_bl.pred.(this_area).(subj)];
        this_dat_unpred_bl_post = [this_dat_unpred_bl_post all_pow_post_bl.unpred.(this_area).(subj)];
    end

    %combine pred and unpred
    all_dat_pre_bl = [this_dat_pred_bl_pre this_dat_unpred_bl_pre];
    all_dat_post_bl = [this_dat_pred_bl_post this_dat_unpred_bl_post];

    pre_and_post = [all_dat_pre_bl' all_dat_post_bl'];

    %plot
    figure 
    f = violinplot(pre_and_post,{'pre','post'});
    f(1,1).ViolinColor{1} = [0,0.8470,0.8410];
    f(1,2).ViolinColor{1} = [0,0.4470,0.4410];
    ylim([-0.6 0.6])
    set(gca,'XTickLabels',[])
    set(gca,'YTickLabels',[])
    ax = gca;
    ax.FontSize = 60;

    %save
    saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/lcmv/movaligned/tfrs_and_correlations/pre_vs_post_rev/reversals_1s_prepost_',this_area,'_',bl,'.jpeg']);
    set(gcf,'DefaultAxesTitleFontWeight','normal')
    set(gcf,'PaperOrientation','landscape')
    print(gcf,'-dpdf','-r300','-fillpage',['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/lcmv/movaligned/tfrs_and_correlations/pre_vs_post_rev/reversals_1s_prepost_',this_area,'_',bl,'.pdf'])
    close all 
end
                 
