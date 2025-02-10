
%makes a coh average over both hemispheres for each subject, condition
%and movement. 
%After that, predictability effect can be localized (also performs stat
%test)

addpath('/net/citta/storage/data_project/reverse/analysis/scripts/Final_analysis/cbrewer')
addpath('/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/')
path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/movaligned/trialed/'];
save_dat = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/coh_predvsunpred/';

load /data/project/hirsch/reverse/analysis/Info/rev_info
load '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid';

subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred'};

%events
events = {'reversals','start','stop'};

for i = rev_info.all_subjects_in_use %go through subjects 

    subj = subjects{i};

    % load subject headmodel and sourcemodel 
    headmodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/headmodels/headmodel_',(subj),'.mat'];
    load(headmodel_oi);
    sourcemodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/sourcemodel_',(subj),'.mat'];
    load(sourcemodel_oi);

    %find pre-selected LFP contacts 
    contact_contra = rev_info.(subj).bestcontact_contra;
    contact_ipsi = rev_info.(subj).bestcontact_ipsi;

    %check which hand was used for turning 
    hand = rev_info.(subj).used_hand;

    for j = 1:2 %go through conditions 

        current_condi = conditions{j}; 

        for h = 1:3 %go through events

            this_event = events{h}; 

            %load data
            file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(this_event)];
            load(file_oi)

            %select LFP channels and gradiometers 
            cfg = [];
            cfg.channel = {contact_ipsi,contact_contra,'MEG***2','MEG***3'};
            rev_trials = ft_selectdata(cfg,rev_trials);

            %select pre-event time window 
            cfg = [];
            cfg.toilim = [0 2];
            post = ft_redefinetrial(cfg,rev_trials);

            %select post-event time window 
            cfg = [];
            cfg.toilim = [-2 0];
            pre = ft_redefinetrial(cfg,rev_trials);

            if isfield(pre,'sampleinfo')
                pre = rmfield(pre,'sampleinfo');
            end

             if isfield(post,'sampleinfo')
                post = rmfield(post,'sampleinfo');
            end

            %cut data into 0.5 long segments
            seg_length = 0.5;
            cfg = [];
            cfg.length = seg_length;
            seg_pre = ft_redefinetrial(cfg,pre);
            seg_post = ft_redefinetrial(cfg,post);

            %Tag trials with NaNs
            is_nan = false(1,numel(seg_pre.trial));
            for tr=1:numel(seg_pre.trial)
                if any(any(isnan(seg_pre.trial{tr})))
                    is_nan(tr)=true;
                end
            end

            %only use as trials those that are not NaNs
            cfg = [];
            cfg.trials = find(~is_nan);
            seg_pre = ft_selectdata(cfg,seg_pre);

            %Tag trials with NaNs
            is_nan = false(1,numel(seg_post.trial));
            for tr=1:numel(seg_post.trial)
                if any(any(isnan(seg_post.trial{tr})))
                    is_nan(tr)=true;
                end
            end

            %only use as trials those that are not NaNs
            cfg = [];
            cfg.trials = find(~is_nan);
            seg_post = ft_selectdata(cfg,seg_post);

            hems = {'contra','ipsi'};

            for hem = 1:2 %go through hemispheres 

                %select ipsi or contra hemisphere
                if hem == 1 
                    this_contact = contact_contra;
                else
                    this_contact = contact_ipsi;
                end

                %freqanalysis with segmented pre and post data 
                cfg = [];
                cfg.method      = 'mtmfft';
                cfg.output      = 'powandcsd'; %gives power and cross-spectral density matrices
                cfg.foilim      = [13 30];
                cfg.pad         = 'nextpow2';
                cfg.channelcmb = {'MEG****' 'MEG****'; 'MEG****' this_contact};
                cfg.taper = 'hanning';
                cfg.keeptrials  = 'no'; 
                cfg.keeptapers  = 'no';
                freq_pre = ft_freqanalysis(cfg,seg_pre);
                freq_post = ft_freqanalysis(cfg,seg_post);

                %run source analysis
                cfg = [];
                cfg.method           = 'dics';
                cfg.headmodel        = headmodel;
                cfg.dics.reducerank  = 2;
                cfg.reducerank       = 2;
                cfg.sourcemodel      = sourcemodel;
                cfg.frequency        = [13 30];
                cfg.dics.projectnoise = 'yes';
                cfg.dics.lambda       = '5%';
                cfg.dics.keepfilter        = 'no';
                cfg.refchan          = this_contact;
                cfg.grad             = freq_pre.grad;
                source_pre{hem} = ft_sourceanalysis(cfg,freq_pre);
                cfg.grad             = freq_post.grad;
                source_post{hem} = ft_sourceanalysis(cfg,freq_post);

                source_pre{hem}.pos = template_grid.pos;
                source_post{hem}.pos = template_grid.pos;
                if contains(hand,'left')
                    source_pre{hem} = flip_hemispheres_coh(source_pre{hem});
                    source_post{hem} = flip_hemispheres_coh(source_post{hem});
                end
            end

            %average over hemispheres
            cfg = [];
            cfg.parameter = 'coh';
            grandavg_pre = ft_sourcegrandaverage(cfg,source_pre{1},source_pre{2});
            grandavg_post = ft_sourcegrandaverage(cfg,source_post{1},source_post{2});

            %compute contrast
            grandavg_blcorr = grandavg_post;
            grandavg_blcorr.coh = grandavg_post.coh - grandavg_pre.coh;
           
            %save the data 
            if j == 1
                grandavg_pred = grandavg_blcorr;
                save([save_dat,'coh_pred_hemAvg_abs_',(subj),'_',(this_event),'.mat'],'grandavg_pred');
            else
                grandavg_unpred = grandavg_blcorr;
                save([save_dat,'coh_unpred_hemAvg_abs_',(subj),'_',(this_event),'.mat'],'grandavg_unpred');
            end
        end
    end
end

restoredefaultpath
fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip_2023/';
addpath(fiedtrippath)
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
ft_defaults
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/cbrewer/')

%make stats and plots

for ev = 1:3 %go through events 

    this_event = events{ev};

    pred_sources = [];
    unpred_souces = [];

    for i = rev_info.all_subjects_in_use %go through subjects 

        subj = subjects{i};

        %load pred and unpred data
        file_oi = [save_dat,'coh_pred_hemAvg_abs_',(subj),'_',(this_event),'.mat'];
        load(file_oi)
        pred_sources{i} = grandavg_pred;

        file_oi = [save_dat,'coh_unpred_hemAvg_abs_',(subj),'_',(this_event),'.mat'];
        load(file_oi)
        unpred_sources{i} = grandavg_unpred;

    end

    %exclude empty cells
    notempt = find(~cellfun(@isempty, pred_sources));
    pred_sources = pred_sources(notempt);
    unpred_sources = unpred_sources(notempt);

    %perform permutation test (for coherence, we find no sign. clusters)
    cfg = [];
    cfg.dim = pred_sources{1}.dim;
    cfg.method = 'montecarlo';
    cfg.statistic = 'ft_statfun_depsamplesT';
    cfg.parameter = 'coh';
    cfg.correctm = 'cluster';
    cfg.numrandomization = 1000;
    cfg.alpha = 0.05;
    cfg.tail = 0;
    nsubjs = numel(pred_sources);
    cfg.design(1,:) = [1:nsubjs 1:nsubjs];
    cfg.design(2,:) = [ones(1,nsubjs)*1 ones(1,nsubjs)*2];
    cfg.uvar = 1;
    cfg.ivar = 2;
    stat = ft_sourcestatistics(cfg,pred_sources{:},unpred_sources{:});

    %perform grandaverges of pred and unpred coherence 
    cfg = [];
    cfg.parameter = 'coh';
    grandavg_pred = ft_sourcegrandaverage(cfg,pred_sources{:});
    grandavg_unpred = ft_sourcegrandaverage(cfg,unpred_sources{:});

    %plot pred coherence 
    cfg = [];
    cfg.method = 'surface';
    cfg.funparameter = 'coh';
    cfg.location = 'max';
    cfg.surffile = 'surface_white_both.mat';
    cfg.funcolormap   = 'default';
    cfg.projmethod = 'nearest';
    cfg.camlight = 'yes';
    cfg.funcolorlim = [-0.0025 0.0025];
    ft_sourceplot(cfg,grandavg_pred);
    hold on
    cm = cbrewer('div','RdBu',80);
    colormap(flipud(cm));
    lgt = light('Position',[-0.3,-0.7,1]);
    brightness = 0.5;
    lightcol = [1,1,1]*brightness;
    set(lgt,'Color',lightcol)
    material shiny
    saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/with_stats/sources/grandavg_events/pred_grandavg_abs_',this_event,'.png']);
    close all

    %plot unpred coherence 
    ft_sourceplot(cfg,grandavg_unpred);
    hold on
    cm = cbrewer('div','RdBu',80);
    colormap(flipud(cm));
    lgt = light('Position',[-0.3,-0.7,1]);
    brightness = 0.5;
    lightcol = [1,1,1]*brightness;
    set(lgt,'Color',lightcol)
    material shiny
    saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/with_stats/sources/grandavg_events/unpred_grandavg_abs_',this_event,'.png']);
    close all
    
    %perform contrast between unpred and pred coherence 
    pred_vs_unpred = grandavg_unpred;
    pred_vs_unpred.coh = grandavg_unpred.coh - grandavg_pred.coh;

    %plot the contrast (in paper)
    cfg = [];
    cfg.method = 'surface';
    cfg.funparameter = 'coh';
    cfg.location = 'max';
    cfg.surffile = 'surface_pial_both.mat';
    cfg.funcolormap   = 'default';
    cfg.projmethod = 'nearest';
    cfg.camlight = 'yes';
    cfg.colorbar = 'no';
    cfg.funcolorlim = [-0.0025 0.0025];
    ft_sourceplot(cfg,pred_vs_unpred);
    hold on
    cm = cbrewer('div','RdBu',80);
    colormap(flipud(cm));
    lgt = light('Position',[-0.3,-0.7,1]);
    brightness = 0.5;
    lightcol = [1,1,1]*brightness;
    set(lgt,'Color',lightcol)
    material shiny
    saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/with_stats/sources/grandavg_events/abscontrast_pred_vs_unpred_abs_',this_event,'.png']);
    set(gcf,'DefaultAxesTitleFontWeight','normal')
    set(gcf,'PaperOrientation','landscape')
    print(gcf,'-dpdf','-r300','-fillpage',['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_movaligned/with_stats/sources/pred_vs_unpred/abscontrast_pred_vs_unpred_abs_',this_event,'.pdf'])
    close all
end
