
%runs source analysis with DICS beamformer for each subject, condition and
%event (and frequency)
%saves sources and contrasts and makes plots 

alignedto = 'movaligned';

addpath('/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/')
addpath(['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'])
load /data/project/hirsch/reverse/analysis/Info/rev_info

%load standard template grid
load '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid';

%load standard template mri
template_mri = ['/data/apps/fieldtrip/latest/template/anatomy/single_subj_T1.nii'];
template_mri = ft_read_mri(template_mri);

subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred','rest'};
%events
events = {'reversals','start','stop'};

frequencies = {'theta','lowbeta','beta','highbeta','gamma'};
freqois = {[3 8],[13 20],[13 30],[21 35],[60 90]};

for fr = 1:numel(frequencies) %go through frequencies (just beta for paper)

    freq_oi = freqois{fr};
    frequency = frequencies{fr};

    for i = rev_info.all_subjects_in_use %go through subjects 

        subj = subjects{i};

        %determine handedness
        hand = rev_info.(subj).used_hand;

        for j = 1:2 %go through conditions

            current_condi = conditions{j};

            for h = 1:3 %go through all events

                event = events{h};

                %load clean data for all events 
                file_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/movaligned/trialed/clean_meg_mov_',(subj),(current_condi),num2str(1),(event)];
                load(file_oi)

                if contains('reversals',event)
                    rev = rev_trials;
                elseif contains('start',event)
                    start = rev_trials;
                else
                    stop = rev_trials;
                end
            end

            %select gradiometers only
            cfg = [];
            cfg.channel = {'MEG***2','MEG***3'};
            rev = ft_selectdata(cfg,rev);
            start = ft_selectdata(cfg,start);
            stop = ft_selectdata(cfg,stop);

            %divide up trials into pre and post event for each event
            %pre
            cfg = [];
            cfg.toilim = [-2 0];
            rev_pre = ft_redefinetrial(cfg,rev);
            start_pre = ft_redefinetrial(cfg,start);
            stop_pre = ft_redefinetrial(cfg,stop);

            %post
            cfg = [];
            cfg.toilim = [0 2];
            rev_post = ft_redefinetrial(cfg,rev);
            start_post = ft_redefinetrial(cfg,start);
            stop_post = ft_redefinetrial(cfg,stop);

            %append all
            cfg = [];
            cfg.keepsampleinfo = 'no';
            all_data = ft_appenddata(cfg,rev_pre,start_pre,stop_pre,rev_post,start_post,stop_post);

            %cutting trials to remove data with segments with NaNs

            %each one associated with a number so that can later retrieve them
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

            %determine how many segments per trial and round down to whole number
            e = floor(trial_dur/seg_length); %floor: round towards neg
            design = repmat(design,[e,1]); %4 copies of design matrix
            design = design(:); %then make it one long vector

            %Tag trials with nan
            %create is_nan: vector with all 0's with as many elements as trials
            %then go through all trials and find nans, tag them with 1's
            is_nan = false(1,numel(seg.trial)); %makes all 0
            for tr=1:numel(seg.trial) %goes through all trials
                if any(any(isnan(seg.trial{tr})))
                    is_nan(tr)=true;
                end
            end

            %only use as trials those that are not nans; i.e. find those that are not 1's
            cfg = [];
            cfg.trials = find(~is_nan);
            seg = ft_selectdata(cfg,seg);
            design = design(~is_nan); %only use non-nans for designmatrix

            %freqanalysis with all segmented data
            cfg = [];
            cfg.method      = 'mtmfft';
            cfg.output      = 'powandcsd'; %gives power and cross-spectral density matrices
            cfg.foilim      = freq_oi;
            cfg.taper       = 'hanning';
            if contains(frequency,'gamma')
                cfg.taper       = 'dpss';
                cfg.tapsmofrq = 4;
            end
            cfg.keeptrials  = 'yes'; %so that we can later seperate trials again
            cfg.keeptapers  = 'no';
            freq = ft_freqanalysis(cfg,seg);

            %freq_data for each trial type 
            cfg = [];
            for n = 1:6
                cfg.trials = design == n;
                freqs{n} = ft_selectdata(cfg,freq);
            end

            %load subject headmodel 
            headmodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/headmodels/headmodel_',(subj),'.mat'];
            load(headmodel_oi);

            %load subject sourcemodel 
            sourcemodel_oi = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/sourcemodel_',(subj),'.mat'];
            load(sourcemodel_oi);

            %compute common spatial filter
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

            %project all conditions through common spatial filter
            cfg = [];
            cfg.method          = 'dics';
            cfg.sourcemodel     = sourcemodel;
            cfg.headmodel       = headmodel;
            cfg.sourcemodel.filter = source.avg.filter; %use the common filter computed before
            cfg.frequency       = freq_oi;

            save_event = {'pre_reversals','pre_start','pre_stop','post_reversals','post_start','post_stop'};
            
            for l = 1:6

                ev = save_event{l};

                %appy filter 
                sources{l} = ft_sourceanalysis(cfg,freqs{l});
                sources{l}.pos = template_grid.pos;
                
                if contains(hand,'left')
                    sources{l} = flip_hemispheres(sources{l});
                end

                this_source = sources{l};
                save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/dics/sources/pre_post/',(frequency),'/source_',(subj),'_',(current_condi),'_',(ev),'.mat'],'this_source');

            end

            % first 3 pre, second 3 for post according to design matrix
            event_oi = {'reversals','start','stop','reversals','start','stop'};

            %compute contrasts
            for g = 4:6
                contrast = sources{g};
                this_event = event_oi{g};
                contrast.avg.pow = (sources{g}.avg.pow - sources{g-3}.avg.pow) ./ sources{g-3}.avg.pow;

                save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/dics/contrasts/pre_post_contrast/',(frequency),'/contrast_',(subj),'_',(current_condi),'_',(this_event),'.mat'],'contrast');
                
                %plot
                cfg            = [];
                cfg.downsample = 2;
                cfg.parameter  = 'pow';
                source_diff_int  = ft_sourceinterpolate(cfg, contrast, template_mri);

                %find min and max
                maxval = max(source_diff_int.pow);
                minval = min(source_diff_int.pow);

                %plot with method slice
                 cfg = [];
                 cfg.method        = 'slice';
                 cfg.funparameter = 'pow';
                 cfg.projmethods = 'nearest';
                 cfg.funcolormap   = 'default';
                 cfg.funcolorlim   = [minval maxval];
                 ft_sourceplot(cfg, source_diff_int);
                 set(gcf, 'Position', get(0, 'Screensize'));
                 saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/',(alignedto),'/pre_post_contrast','/',(frequency),'/source_mri_',(subj),'_',(current_condi),'_',(this_event),'.jpeg']);
                 close all

                %load mesh
                load(['/data/apps/fieldtrip/latest/template/anatomy/surface_pial_both.mat']);
                mesh = ft_convert_units(mesh,'m');

                %interpolate on mesh
                cfg = [];
                cfg.parameter = 'pow';
                cfg.downsample = 2;
                cfg.method = 'surface';
                source_diff_int = ft_sourceinterpolate(cfg,contrast,mesh);
               
                restoredefaultpath
                fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip_2023/';
                addpath(fiedtrippath)
                addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
                ft_defaults
            
                %surface plot
                cfg = [];
                cfg.method        = 'surface';
                cfg.funparameter  = 'pow';
                cfg.projmethods = 'nearest';
                cfg.funcolormap   = 'default';
                cfg.camlight = 'yes';
                cfg.interactive = 'yes';
                ft_sourceplot(cfg, source_diff_int);
                set(gcf, 'Position', get(0, 'Screensize'));
                saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/',(alignedto),'/pre_post_contrast','/',(frequency),'/source_surface_',(subj),'_',(current_condi),'_',(this_event),'.jpeg']);

                close all

                restoredefaultpath
                fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip-20201229/';
                addpath(fiedtrippath)
                addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
                ft_defaults
            end
        end
    end
end
