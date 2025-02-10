
%source analysis for each subject to check pow
%computes absolute contrast of post and pre movement source power

alignedto = 'movaligned';

addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/');
path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'];
load /data/project/hirsch/reverse/analysis/Info/rev_info

%load standard template grid
load '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid';

%load mesh
load(['/data/apps/fieldtrip/latest/template/anatomy/surface_white_both.mat']);
mesh = ft_convert_units(mesh,'m');
%path for saving the data
save_dat = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh/ROIs/';

subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred','rest'};
%events
events = {'reversals','start','stop'};

frequencies = {'gamma','beta','theta'};
freqois = {[50 90],[13 30],[3 8]};

for fr = 2 %only using beta for the present 
    
    freq_oi = freqois{fr};
    frequency = frequencies{fr};
    
    for i = rev_info.all_subjects_in_use
        
        subj = subjects{i};
        
        %determine handedness
        hand = rev_info.(subj).used_hand;
        
        for h = 1:3 %go through all events
            
            event = events{h};
            
            for j = 1:2 %go through condis
                
                current_condi = conditions{j};
                
                % load clean data
                file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(event)];
                load(file_oi)
                
                %select gradiometers only 
                cfg = [];
                cfg.channel = {'MEG***2','MEG***3'};
                rev_trials = ft_selectdata(cfg,rev_trials);
                
                %store for each of 2 conditions
                data{j} = rev_trials;
            end
            
            %append the 2 conditions
            cfg = [];
            cfg.keepsampleinfo = 'no';
            data_all = ft_appenddata(cfg,data{1},data{2});
            data_all.grad = data{1}.grad;
            
            %store for each of 3 events 
            if contains(event,'reversals')
                rev = data_all;
            elseif contains(event,'start')
                start = data_all;
            else
                stop = data_all;
            end
        end
        
        % divide up trials into pre and post event for each event
        % pre
        cfg = [];
        cfg.toilim = [-2 0];
        rev_pre = ft_redefinetrial(cfg,rev);
        start_pre = ft_redefinetrial(cfg,start);
        stop_pre = ft_redefinetrial(cfg,stop);
        
        % post
        cfg = [];
        cfg.toilim = [0 2];
        rev_post = ft_redefinetrial(cfg,rev);
        start_post = ft_redefinetrial(cfg,start);
        stop_post = ft_redefinetrial(cfg,stop);
        
        %append all
        cfg = [];
        cfg.keepsampleinfo = 'no';
        all_data = ft_appenddata(cfg,rev_pre,start_pre,stop_pre,rev_post,start_post,stop_post);
        
        %each one associated with a number so that they can be retrieved
        %later
        design = [ones(1,length(rev_pre.trial)) ones(1,length(start_pre.trial))*2 ...
            ones(1,length(stop_pre.trial))*3 ones(1,length(rev_post.trial))*4 ...
            ones(1,length(start_post.trial))*5 ones(1,length(stop_post.trial))*6];
        
        %cut trials into 0.5 long segments
        seg_length = 0.5;
        trial_dur = length(all_data.time{1})/all_data.fsample;
        cfg = [];
        cfg.length = seg_length;
        cfg.overlap = 0;
        seg = ft_redefinetrial(cfg,all_data);
        
        %next, find segments with NaNs and take them out (source analysis
        %doesn't work otherwise)
        e = floor(trial_dur/seg_length);
        design = repmat(design,[e,1]);
        design = design(:);
        
        %Tag trials with NaNs
        is_nan = false(1,numel(seg.trial));
        for tr=1:numel(seg.trial)
            if any(any(isnan(seg.trial{tr})))
                is_nan(tr)=true;
            end
        end
        
        %only use as trials those that are without any NaNs
        cfg = [];
        cfg.trials = find(~is_nan);
        seg = ft_selectdata(cfg,seg);
        design = design(~is_nan);
        
        %freqanalysis with all segmented data
        cfg = [];
        cfg.method      = 'mtmfft';
        cfg.output      = 'powandcsd'; %gives power and cross-spectral density matrices
        cfg.foilim      = freq_oi;
        cfg.pad         = 'nextpow2';
        cfg.taper       = 'hanning';
        if contains(frequency,'gamma')
            cfg.taper       = 'dpss';
            cfg.tapsmofrq   = 5;
        end
        cfg.keeptrials  = 'yes'; %so that trials can be seperated again
        cfg.keeptapers  = 'no';
        freq = ft_freqanalysis(cfg,seg);
        
        cfg = [];
        for n = 1:6
            cfg.trials = design == n;
            freqs{n} = ft_selectdata(cfg,freq);
        end
        
        % load subj headmodel 
        headmodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/headmodels/headmodel_',(subj),'.mat'];
        load(headmodel_oi);
        
        % load subj sourcemodel 
        sourcemodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/sourcemodel_',(subj),'.mat'];
        load(sourcemodel_oi);
        
        % compute common spatial filter
        cfg = [];
        cfg.method           = 'dics';
        cfg.grad             = freq.grad;
        cfg.headmodel        = headmodel;
        cfg.reducerank       = 2;
        cfg.channel          = freq.label;
        cfg.sourcemodel      = sourcemodel;
        cfg.frequency        = freq_oi;
        cfg.dics.keepfilter  = 'yes'; % remember the filter
        cfg.dics.projectnoise = 'yes';
        cfg.dics.lambda       = '5%';
        source = ft_sourceanalysis(cfg,freq);
        
        % project all trial types through common spatial filter
        cfg = [];
        cfg.method          = 'dics';
        cfg.sourcemodel     = sourcemodel;
        cfg.headmodel       = headmodel;
        cfg.sourcemodel.filter = source.avg.filter; % use the common filter computed before
        cfg.frequency       = freq_oi;
        
        for l = 1:6
            sources{l} = ft_sourceanalysis(cfg,freqs{l});
            sources{l}.pos = template_grid.pos;
            if contains(hand,'left')
                sources{l} = flip_hemispheres(sources{l});
            end
        end
        
        % first 3: pre, second 3: post (according to design matrix)
        event_oi = {'reversals','start','stop','reversals','start','stop'};
        
        %compute contrasts (post-pre/pre); abs: acitivty shouldn't cancel
        for g = 1:3
            
            this_event = event_oi{g};
            contrast = sources{g};
            contrast.avg.pow = (sources{g+3}.avg.pow - sources{g}.avg.pow) ./ sources{g}.avg.pow;
            contrasts{g}{i} = contrast;
            contrast_abs = contrast;
            contrast_abs.avg.pow = abs(contrast_abs.avg.pow);
            abs_contrasts{g}{i} = contrast_abs;

            % restoredefaultpath
            % fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip_2023/';
            % addpath(fiedtrippath)
            % addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
            % ft_defaults
            % 
            % %interpolate on mesh
            % cfg = [];
            % cfg.parameter = 'pow';
            % cfg.downsample = 2;
            % cfg.method = 'surface';
            % source_diff_int = ft_sourceinterpolate(cfg,contrast,mesh);
            % 
            % %surface plot
            % cfg = [];
            % cfg.method        = 'surface';
            % cfg.funparameter  = 'pow';
            % cfg.projmethods = 'nearest';
            % cfg.funcolormap   = 'default';
            % ft_sourceplot(cfg, source_diff_int);
            % set(gcf, 'Position', get(0, 'Screensize'));
            % saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/',(alignedto),'/-2-2/source_surface_',(frequency),(this_event),'_',(subj),'.jpeg']);
            % close all
        end
    end

    %save all contrasts 
    save([save_dat,'contrasts_pow_abs_rel_',(frequency),'.mat'],'abs_contrasts');
    save([save_dat,'contrasts_pow_rel_',(frequency),'.mat'],'contrasts');

end



 
 
        