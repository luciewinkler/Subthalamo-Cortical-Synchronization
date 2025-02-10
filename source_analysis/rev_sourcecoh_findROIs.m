
%source analysis for each subject to check coherence
%computes absolute contrast of post and pre movement source coherence

addpath('/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/')
path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/movaligned/trialed/'];
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/');
save_dat = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh/ROIs/';
load /data/project/hirsch/reverse/analysis/Info/rev_info

%load standard template grid
load '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid';

%load mesh
% load(['/data/apps/fieldtrip/latest/template/anatomy/surface_white_both.mat']);
load(['/data/apps/fieldtrip/latest/template/anatomy/surface_pial_both.mat']);

subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred'};

events = {'reversals','start','stop'};

freqbands = {'gamma','beta','theta'};
freqois = {[50 90],[13 30],[3 8]};

for fr = 2 %using only beta presently
    
    freq_band = freqbands{fr};
    freqoi = freqois{fr};
    
    for hem = 1:2 %go through both hemispheres
        
        if hem == 1
            ipsi = 0;
            hemisphere = 'contra';
        else
            ipsi = 1;
            hemisphere = 'ipsi';
        end
        
        for i = rev_info.all_subjects_in_use %go through all subjects 
            
            subj = subjects{i};

            % load subj headmodel and sourcemodel 
            headmodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/headmodels/headmodel_',(subj),'.mat'];
            load(headmodel_oi);
            sourcemodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/sourcemodel_',(subj),'.mat'];
            load(sourcemodel_oi);
            
            %find LFP contact chosen for that subject
            if ipsi == 1
                contact = rev_info.(subj).bestcontact_ipsi;
            else
                contact = rev_info.(subj).bestcontact_contra;
            end
            
            hand = rev_info.(subj).used_hand;
            
            for h = 1:3
                
                this_event = events{h}; %select event
                
                data = cell(1,2);
                
                for j = 1:2
                    
                    current_condi = conditions{j}; %select condition
                    
                    file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(this_event)];
                    load(file_oi)
                    
                    % select onlygradiometers and LFP channel of interest
                    cfg = [];
                    cfg.channel = {contact,'MEG***2','MEG***3'};
                    rev_trials = ft_selectdata(cfg,rev_trials);
                    
                    data{j} = rev_trials;
                end
                
                %append data of predictability conditions
                cfg = [];
                cfg.keepsampleinfo = 'no';
                data_all = ft_appenddata(cfg,data{1},data{2});
                data_all.grad = data{1}.grad;
                
                %divide into pre and post event
                cfg = [];
                cfg.toilim = [0 2];
                data_post = ft_redefinetrial(cfg,data_all);
                cfg.toilim = [-2 0];
                data_pre = ft_redefinetrial(cfg,data_all);
                
                % cut data into 0.5 long segments
                seg_length = 0.5;
                cfg = [];
                cfg.length = seg_length;
                seg_post = ft_redefinetrial(cfg,data_post);
                seg_pre = ft_redefinetrial(cfg,data_pre);
                
                % Tag trials with NaNs
                is_nan = false(1,numel(seg_post.trial));
                for tr=1:numel(seg_post.trial)
                    if any(any(isnan(seg_post.trial{tr})))
                        is_nan(tr)=true;
                    end
                end
                
                % only use as trials those that are not NaNs
                cfg = [];
                cfg.trials = find(~is_nan);
                seg_post = ft_selectdata(cfg,seg_post);
                
                % Tag trials with NaNs
                is_nan = false(1,numel(seg_pre.trial));
                for tr=1:numel(seg_pre.trial)
                    if any(any(isnan(seg_pre.trial{tr})))
                        is_nan(tr)=true;
                    end
                end
                
                % only use as trials those that are not NaNs
                cfg = [];
                cfg.trials = find(~is_nan);
                seg_pre = ft_selectdata(cfg,seg_pre);
                
                % freqanalysis with all segmented data
                cfg = [];
                cfg.method      = 'mtmfft';
                cfg.output      = 'powandcsd'; % gives power and cross-spectral density matrices
                cfg.foilim      = freqoi;
                cfg.pad         = 'nextpow2';
                cfg.channelcmb = {'MEG****' 'MEG****'; 'MEG****' contact};
                cfg.taper = 'hanning';
                if contains(freq_band,'gamma')
                    cfg.taper       = 'dpss';
                    cfg.tapsmofrq   = 5;
                end
                cfg.keeptrials  = 'yes'; %not necessary
                cfg.keeptapers  = 'no';
                freq_post = ft_freqanalysis(cfg,seg_post);
                freq_pre = ft_freqanalysis(cfg,seg_pre);
               
                %compute spatial filter
                cfg = [];
                cfg.method           = 'dics';
                cfg.grad             = freq_post.grad;
                cfg.refchan          = contact;
                cfg.headmodel        = headmodel;
                cfg.dics.reducerank  = 2;
                cfg.reducerank       = 2;
                cfg.sourcemodel      = sourcemodel;
                cfg.frequency        = freqoi;
                cfg.dics.projectnoise = 'yes';
                cfg.dics.lambda       = '5%';
                cfg.dics.keepfilter        = 'no';
                source_post = ft_sourceanalysis(cfg,freq_post);
                source_pre = ft_sourceanalysis(cfg,freq_pre);
                source_pre.pos = template_grid.pos;
                source_post.pos = template_grid.pos;
                if contains(hand,'left')
                    source_post = flip_hemispheres_coh(source_post);
                    source_pre = flip_hemispheres_coh(source_pre);
                end
                
                %save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/source_coh_',(time),'_',(freqband),(subj),(current_condi),(this_event),'.mat'],'source');
                
                %compute contrasts
                contrast = source_post;
                contrast.avg.coh = source_post.avg.coh - source_pre.avg.coh;

                contrast_abs = contrast;
                contrast_abs.avg.coh = abs(contrast_abs.avg.coh);
                
                abs_contrasts{h}{i} = contrast_abs;
                contrasts{h}{i} = contrast;

                % restoredefaultpath
                % fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip_2023/';
                % addpath(fiedtrippath)
                % addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
                % ft_defaults
                % 
                % cfg = [];
                % cfg.parameter = 'coh';
                % cfg.downsample = 2;
                % cfg.method = 'cubic';
                % source_mesh = ft_sourceinterpolate(cfg,contrasts{h}{i},mesh);
                % 
                % cfg = [];
                % cfg.method        = 'surface';
                % cfg.funparameter  = 'coh';
                % cfg.projmethods = 'nearest';
                % cfg.funcolormap   = 'default';
                % ft_sourceplot(cfg, source_mesh);
                % saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/source_coh/events/source_coh_',(subj),(this_event),(freq_band),(hemisphere),'.jpeg']);
                % close all
            end
        end
        
        if ipsi == 1
            all_ipsi_abs = abs_contrasts;
            all_ipsi = contrasts;
        else
            all_contra_abs = abs_contrasts;
            all_contra = contrasts;
        end
    end

    %save all contrasts
    save([save_dat,'contrasts_all_ipsi_abs_absbl_',(freq_band),'.mat'],'all_ipsi_abs');
    save([save_dat,'contrasts_all_ipsi_absbl_',(freq_band),'.mat'],'all_ipsi');
    save([save_dat,'contrasts_all_contra_abs_absbl_',(freq_band),'.mat'],'all_contra_abs');
    save([save_dat,'contrasts_all_contra_absbl_',(freq_band),'.mat'],'all_contra');
end


