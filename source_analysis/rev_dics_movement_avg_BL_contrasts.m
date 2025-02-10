
%conducts source analysis using DICS beamformer 
%takes as BL the average of the 3 events
%makes subject plots 

%if want to use the pre-event time, use 'pre_event', otherwise 'post_event'
time = 'post_event';
    
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

for fr = 1:numel(frequencies) %go through frequencies 

    freq_oi = freqois{fr};
    frequency = frequencies{fr};

    for i = rev_info.all_subjects_in_use %go through subjects 

        subj = subjects{i};

        %determine handedness
        hand = rev_info.(subj).used_hand;

        for j = 1:2 %go through conditions

            current_condi = conditions{j};

            for h = 1:3 %go through events

                event = events{h};

                % load clean data
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

            % select gradiometers only
            cfg = [];
            cfg.channel = {'MEG***2','MEG***3'};
            rev = ft_selectdata(cfg,rev);
            start = ft_selectdata(cfg,start);
            stop = ft_selectdata(cfg,stop);

            %this is for baseline (contains entire time-window)
            rev_bl = rev;
            start_bl = start;
            stop_bl = stop;

            %time windows of interest 
            cfg = [];
            if contains(time,'pre_event')
                cfg.toilim = [-1 0];
            else
                cfg.toilim = [0 1];
            end
            rev_post = ft_redefinetrial(cfg,rev);
            start_post = ft_redefinetrial(cfg,start);
            stop_post = ft_redefinetrial(cfg,stop);

            %append all
            cfg = [];
            cfg.keepsampleinfo = 'no';
            all_data = ft_appenddata(cfg,rev_post,start_post,stop_post);
            all_data_bl = ft_appenddata(cfg,rev,start,stop);

            %data may contain NaNs: following is to remove those segments 
            design_bl = [ones(1,length(rev.trial)) ones(1,length(start.trial))*2 ones(1,length(stop.trial))*3];
            design = [ones(1,length(rev_post.trial)) ones(1,length(start_post.trial))*2 ones(1,length(stop_post.trial))*3];

            %cut trials into 0.5 long segments
            seg_length = 0.5;
            trial_dur = length(all_data.time{1})/all_data.fsample;
            cfg = [];
            cfg.length = seg_length;
            cfg.overlap = 0;
            seg = ft_redefinetrial(cfg,all_data);

            trial_dur_bl = length(all_data_bl.time{1})/all_data_bl.fsample;
            cfg = [];
            cfg.length = seg_length;
            cfg.overlap = 0;
            seg_bl = ft_redefinetrial(cfg,all_data_bl);

            %determine how many segments per trial and round down to whole number
            e = floor(trial_dur/seg_length); %floor: round towards neg
            design = repmat(design,[e,1]); %copies of design matrix
            design = design(:); %then make it one long vector

            e_bl = floor(trial_dur_bl/seg_length); %floor: round towards neg
            design_bl = repmat(design_bl,[e_bl,1]); %4 copies of design matrix
            design_bl = design_bl(:); %then make it one long vector

            %Tag those trials with nan
            %create is_nan: vector with all 0's with as many elements as trials
            %then go thru all trials and find nans, tag them with 1's
            is_nan = false(1,numel(seg.trial)); % makes all 0
            for tr=1:numel(seg.trial) % goes thru all trials
                if any(any(isnan(seg.trial{tr})))
                    is_nan(tr)=true;
                end
            end

            %only use as trials those that are not nans; i.e. find those that are not 1's
            cfg = [];
            cfg.trials = find(~is_nan);
            seg = ft_selectdata(cfg,seg);
            design = design(~is_nan); %only use non-nans for designmatrix

            is_nan = false(1,numel(seg_bl.trial)); % makes all 0
            for tr=1:numel(seg_bl.trial) % goes thru all trials
                if any(any(isnan(seg_bl.trial{tr})))
                    is_nan(tr)=true;
                end
            end

            cfg = [];
            cfg.trials = find(~is_nan);
            seg_bl = ft_selectdata(cfg,seg_bl);
            design_bl = design_bl(~is_nan); %only use non-nans for designmatrix

            % freqanalysis with all segmented data
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
            freq_bl = ft_freqanalysis(cfg,seg_bl);

            %retrieve the different trial types
            cfg = [];
            for n = 1:3
                cfg.trials = design == n;
                freqs{n} = ft_selectdata(cfg,freq);
            end

            cfg = [];
            for n = 1:3
                cfg.trials = design_bl == n;
                freqs_bl{n} = ft_selectdata(cfg,freq_bl);
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
            cfg.headmodel        = headmodel;
            cfg.reducerank       = 2;
            cfg.channel          = freq.label;
            cfg.sourcemodel      = sourcemodel;
            cfg.frequency        = freq_oi;
            cfg.dics.keepfilter  = 'yes'; %remember the filter
            cfg.dics.projectnoise = 'yes';
            cfg.dics.lambda       = '5%';
            cfg.grad             = freq.grad;
            source = ft_sourceanalysis(cfg,freq);
            cfg.grad             = freq_bl.grad;
            source_bl = ft_sourceanalysis(cfg,freq_bl);

            %project all trial types through common spatial filter
            cfg = [];
            cfg.method          = 'dics';
            cfg.sourcemodel     = sourcemodel;
            cfg.headmodel       = headmodel;
            cfg.sourcemodel.filter = source.avg.filter; %use the common filter computed before
            cfg.frequency       = freq_oi;

            for l = 1:3
                sources{l} = ft_sourceanalysis(cfg,freqs{l});
                sources{l}.pos = template_grid.pos;
                if contains(hand,'left')
                    sources{l} = flip_hemispheres(sources{l});
                end
            end

            %same for BL
            cfg = [];
            cfg.method          = 'dics';
            cfg.sourcemodel     = sourcemodel;
            cfg.headmodel       = headmodel;
            cfg.sourcemodel.filter = source_bl.avg.filter; % use the common filter computed before
            cfg.frequency       = freq_oi;

            for l = 1:3
                sources_bl{l} = ft_sourceanalysis(cfg,freqs_bl{l});
                sources_bl{l}.pos = template_grid.pos;
                if contains(hand,'left')
                    sources_bl{l} = flip_hemispheres(sources_bl{l});
                end
            end

            % events according to design matrix
            event_oi = {'reversals','start','stop'};

            %make movement-average BL
            cfg = [];
            bl = ft_sourcegrandaverage(cfg,sources_bl{1},sources_bl{2},sources_bl{3});

            %compute contrasts
            for g = 1:3
                contrast = sources{g};
                this_event = event_oi{g};
                contrast.avg.pow = (sources{g}.avg.pow - bl.pow) ./ bl.pow;
                save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/dics/contrasts/mov_avg_contrast/',(frequency),'/contrast_',(time),'_',(subj),'_',(current_condi),'_',(this_event),'.mat'],'contrast');

                load(['/data/apps/fieldtrip/latest/template/anatomy/surface_white_both.mat']);
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

                %make surface plot
                cfg = [];
                cfg.method        = 'surface';
                cfg.funparameter  = 'pow';
                cfg.projmethods = 'nearest';
                cfg.funcolormap   = 'default';
                cfg.camlight = 'no';
                cfg.interactive = 'no';
                ft_sourceplot(cfg, source_diff_int);
                set(gcf, 'Position', get(0, 'Screensize'));
                saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/source_analysis/dics/',(alignedto),'/mov_avg_contrast','/',(frequency),'/source_surface_',(time),'_',(subj),'_',(current_condi),'_',(this_event),'.jpeg']);
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

 