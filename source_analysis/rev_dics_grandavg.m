
%computes grandavgerages over subjects of source reconstructions
%choose which BL: movement-avg or pre-event, and in case of movement-avg
%whether to use the pre-event or post-event time window 
%choose frequency band 

alignedto = 'movaligned';

%for paper? if yes, always choose beta. Only beta plots are in the paper
%and they are automatically saved to a beta folder 
paper = 1; 

% time_windows
time = 'pre_event'; %'pre_event' or 'post_event'

%Baselines: 'mov_avg' or 'pre_post'
bl = 'pre_post';

%frequencies (paper: beta)
freq_oi = 'beta'; %choose beta, gamma, lowbeta, highbeta, theta 

%%%%%%%%%%%%%%%%%%%%%%%%%
load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);

%load standard template mri
template_mri = ['/data/apps/fieldtrip/latest/template/anatomy/single_subj_T1.nii'];
mri = ft_read_mri(template_mri);

%events
events = {'start','stop','reversals'};

%conditions
conditions = {'pred','unpred'};

for e = 1:3 %go through events

    this_event = events{e};

    for i = rev_info.all_subjects_in_use %go through subjects 

        subj = subjects{i};

        for j = 1:2 %go through conditions

            current_condi = conditions{j};

            %load the data 
            if contains(bl,'mov')
                file_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/dics/contrasts/',(bl),'_contrast/',(freq_oi),'/contrast_',(time),'_',(subj),'_',(current_condi),'_',(this_event),'.mat'];
            else
                file_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/dics/contrasts/',(bl),'_contrast/',(freq_oi),'/contrast_',(subj),'_',(current_condi),'_',(this_event),'.mat'];
                %set time to be post (in the post-pre contrast, we always look at post)
                time = 'post_event';
            end

            load(file_oi)

            if contains (current_condi,'unpred')
                contrasts_unpred{i} = contrast;
            else
                contrasts_pred{i} = contrast;
            end

        end
    end

    %find empty cells
    contrasts_notempt = find(~cellfun(@isempty,contrasts_pred));

    % now calculate grand average for pred, unpred and average over conditions
    cfg = [];
    cfg.parameter = 'pow';
    cfg.keepindividual = 'no';
    grandavg_pred = ft_sourcegrandaverage(cfg,contrasts_pred{contrasts_notempt});
    grandavg_unpred = ft_sourcegrandaverage(cfg,contrasts_unpred{contrasts_notempt});
    grandavg_comb = ft_sourcegrandaverage(cfg,contrasts_pred{contrasts_notempt},contrasts_unpred{contrasts_notempt});
 
    restoredefaultpath
    fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip_2023/';
    addpath(fiedtrippath)
    addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
    ft_defaults

    %make surface plots 
    cfg = [];
    cfg.method        = 'surface';
    cfg.funparameter  = 'pow';
    cfg.maskparameter = cfg.funparameter;
    cfg.funcolormap   = 'default';
    cfg.projmethod = 'nearest';
    cfg.camlight = 'yes';
    cfg.colorbar = 'no';

    if contains(freq_oi,'beta')
        if e == 3
            cfg.funcolorlim = [-0.1 0.1];
        elseif e == 2
            cfg.funcolorlim = [0 1];
        elseif e == 1
            cfg.funcolorlim = [-0.4 0.4];
        end
    end

    if contains(bl,'mov_avg')
        cfg.funcolorlim = [-0.2 0.2];
    end

    %if these plots are for the paper, there are some specifics 
    if contains(freq_oi,'beta') && paper == 1

        cfg.surffile = 'surface_pial_both.mat';
        ft_sourceplot(cfg,grandavg_comb)
        hold on
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        lgt = light('Position',[-0.3,-0.7,1]);
        brightness = 0.5;
        lightcol = [1,1,1]*brightness;
        set(lgt,'Color',lightcol)
        material shiny

        %save
        set(gcf,'PaperOrientation','landscape')
        savedir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/movaligned/';
        if contains(bl,'mov_avg')
            print(gcf,'-dpdf','-r300','-fillpage',[savedir,'/mov_avg/beta/paper/grandavg_surface_final_',(time),'_',(freq_oi),'_comb_',(this_event),'.pdf'])
        else
            print(gcf,'-dpdf','-r300','-fillpage',[savedir,'/pre_post/beta/paper/grandavg_surface_',(time),'_',(freq_oi),'_comb_',(this_event),'.pdf'])
        end
        close all

    else %if the plots are not specifically for the paper 

        cfg.colorbar = 'yes';
        ft_sourceplot(cfg, grandavg_comb);
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/',(alignedto),'/',(bl),'/',(freq_oi),'/grandavg_surface_',(time),'_comb_',(this_event),'.jpeg']);
        close all
        ft_sourceplot(cfg, grandavg_pred);
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/',(alignedto),'/',(bl),'/',(freq_oi),'/grandavg_surface_',(time),'_pred_',(this_event),'.jpeg']);
        close all
        ft_sourceplot(cfg, grandavg_unpred);
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/',(alignedto),'/',(bl),'/',(freq_oi),'/grandavg_surface_',(time),'_unpred_',(this_event),'.jpeg']);
        close all

        template_mri = ['/data/apps/fieldtrip/latest/template/anatomy/single_subj_T1.nii'];
        mri = ft_read_mri(template_mri);

        cfg            = [];
        cfg.downsample = 2;
        cfg.parameter  = 'pow';
        grandavg_comb_interp  = ft_sourceinterpolate(cfg, grandavg_comb, mri);
        grandavg_pred_interp  = ft_sourceinterpolate(cfg, grandavg_pred, mri);
        grandavg_unpred_interp  = ft_sourceinterpolate(cfg, grandavg_unpred, mri);

        cfg = [];
        cfg.method        = 'ortho';
        cfg.funparameter  = 'pow';
        cfg.projmethods = 'nearest';
        cfg.funcolormap   = 'default';
        ft_sourceplot(cfg, grandavg_comb_interp);
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/',(alignedto),'/',(bl),'/',(freq_oi),'/grandavg_ortho_',(time),'_comb_',(this_event),'.jpeg']);
        close all
        ft_sourceplot(cfg, grandavg_pred_interp);
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/',(alignedto),'/',(bl),'/',(freq_oi),'/grandavg_ortho_',(time),'_pred_',(this_event),'.jpeg']);
        close all
        ft_sourceplot(cfg, grandavg_comb_interp);
        cm = cbrewer('div','RdBu',80);
        colormap(flipud(cm));
        saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/grandaverage/simplecontrast/',(alignedto),'/',(bl),'/',(freq_oi),'/grandavg_ortho_',(time),'_unpred_',(this_event),'.jpeg']);
        close all
    end
    
    restoredefaultpath
    fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip-20201229/';
    addpath(fiedtrippath)
    addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
    ft_defaults
end

 