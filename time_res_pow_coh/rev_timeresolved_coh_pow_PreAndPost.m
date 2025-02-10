
%compute power and coherence and store results in a table for statistics
%can do for trigger-or movement aligned data, and beta or gamma

%pick movaligned or trigaligned
alignedto = 'movaligned';
%if want to look at gamma put 1
gamma = 0;

%%%%%%%%%%%

%path for saving data
save_here = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_',alignedto,'/'];

%path for loading data
if contains(alignedto,'trig')
    datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors_trigaligned/';
else
    datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors/';
end

load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);
conditions = {'pred','unpred'};
events = {'start','stop','reversals'};

%epoch of interest
t_start = -2;
t_stop = 2;

%frequency ranges of interest
if gamma == 1
    band_start = 55;
    band_stop = 90;
else
    band_start = 13;
    band_stop = 30;
end

%window size and stepsize for TFR
ws = 0.8;
stepsize = 0.05;

%initialise tables for data collection
pow_tbl_headers = {'subject','predictability','movement','area','power','powerBlCorr','tfr_post','tfr_pre'};
pow_tbl = cell2table(cell(0,length(pow_tbl_headers)),'VariableNames', pow_tbl_headers);
coh_tbl_headers = {'subject','predictability','movement','area','coh','cohBlCorr','tfr_post','tfr_pre'};
coh_tbl = cell2table(cell(0,length(coh_tbl_headers)),'VariableNames', coh_tbl_headers);
% g_tbl_headers = {'subject','predictability','movement','area','granger','grangerBlCorr'};
% g_tbl = cell2table(cell(0,length(coh_tbl_headers)),'VariableNames', g_tbl_headers);

for i = rev_info.all_subjects_in_use
    
    subj = subjects{i};
    %get pre-chosen STN contacts and moving hand
    STN_contra = rev_info.(subj).bestcontact_contra;
    STN_ipsi = rev_info.(subj).bestcontact_ipsi;
    hand = rev_info.(subj).used_hand;

    for j = 1:numel(conditions)

        %select predictability condition
        current_condi = conditions{j};

        for h = 1:numel(events)

            %select event 
            this_event = events{h};

            %load data
            file= [datadir,'chans_neighbors_LFP_',subj,current_condi,this_event,'beta.mat'];
            load(file)

            %subject 23 has a few trials with artifacts in the gamma range.
            %These are taken out here
            if gamma == 1
                if i == 23 && h == 1 && j == 1
                    cfg = [];
                    cfg.trials = [1:13,15:numel(all_data.trial)];
                    all_data = ft_selectdata(cfg,all_data);
                elseif i == 23 && h == 1 && j == 2 
                    cfg = [];
                    cfg.trials = [1:6,8:33,35:60,62:numel(all_data.trial)];
                    all_data = ft_selectdata(cfg,all_data);
                end
            end
             
            %check if there are any trials with nans
            ntrials = length(all_data.trial);
            trials_with_nans = cell(1,ntrials);
            for tr = 1:ntrials
                %if there are nans tag them with 1
                if sum(isnan(all_data.trial{tr}(:))) ~= 0
                    trials_with_nans{1,tr} = 1;
                end
            end

            %how many nan trials in total
            total_with_nan = numel(find(~cellfun(@isempty,trials_with_nans)));
            %Get all trials except for nan positions
            total_without_nan = find(cellfun(@isempty,trials_with_nans));
            %make new data struct without nans
            cfg = [];
            cfg.trials = total_without_nan;
            all_data = ft_selectdata(cfg,all_data);
            %ntrials is now different
            ntrials = length(all_data.trial);
            %if too many trials have nans let me know and can also check
            %later in toomanynans (if even necessary)
            if numel(total_with_nan) > 5
                disp(['more than 5 nans for ',(subj),' ',(current_condi),' ',(this_event),'!!!!!!!!!!!!']);
                toomanynans{i,j} = total_with_nan;
            end

            %specifiy times and frequency range for TFA
            times = [t_start:stepsize:t_stop-ws; t_start+ws:stepsize:t_stop];
            if gamma == 1
                foi = 1/ws:1/ws:90;
            else
                foi = 1/ws:1/ws:45;
            end
            timeaxis = mean(times);

            %run TFA
            cfg = [];
            cfg.output = 'fourier';
            cfg.method = 'mtmconvol';
            if gamma == 1
                cfg.tapsmofrq = 5;
            else
                cfg.tapsmofrq = 3;
            end
            cfg.pad = 'nextpow2';
            cfg.taper = 'dpss';
            cfg.keeptrials = 'yes';
            cfg.foi = foi;
            cfg.t_ftimwin = ws*ones(1,length(cfg.foi));
            cfg.toi = timeaxis;
            fou = ft_freqanalysis(cfg,all_data);

            %power and coherence should be calculated for each hemisphere
            hemispheres = {'contra','ipsi'};
            data_hemi = cell(1,length(hemispheres));

            for s = 1:length(hemispheres)

                %name each channel and channel combinations for coherence
                hemi = hemispheres{s};
                refchan = [hemi,'_STN'];
                cortchans = {[hemi,'_m1'],[hemi,'_sma']};
                new_chans = {['STN ',hemi],['M1 ',hemi],['SMA ',hemi],['STN-M1 ',hemi],['STN-SMA ',hemi]};

                %get indices for each group of neighboring channels
                ind_cort_neigh = {};
                for h = 1:numel(cortchans)
                    cortchan = cortchans{h};
                    con = startsWith(all_data.label,cortchan);
                    if any(con)
                        ind_cort_neigh = [ind_cort_neigh;{find(con)}];
                    end
                end

                %find index for STN contact for coherence
                refchan_ind = find(contains(all_data.label,refchan));

                %compute power and stn-cortex coherence (over repetitions)
                Freqtim_pow = zeros(size(fou.fourierspctrm,2:4));
                Freqtim_coh = Freqtim_pow;
                for fr = 1:size(fou.fourierspctrm,3)
                    for t = 1:size(fou.fourierspctrm,4)
                        freqtim_fou = squeeze(fou.fourierspctrm(:,:,fr,t));
                        freqtim_csd = freqtim_fou'*freqtim_fou;
                        freqtim_pow = diag(freqtim_csd);
                        Freqtim_pow(:,fr,t) = freqtim_pow;
                        freqtim_stnpow_r = ones(length(freqtim_pow),1)*freqtim_pow(refchan_ind);
                        freqtim_stncort_csd = freqtim_csd(refchan_ind,:)';
                        freqtim_coh = abs(freqtim_stncort_csd).^2./(freqtim_pow.*freqtim_stnpow_r);
                        Freqtim_coh(:,fr,t) = freqtim_coh;
                    end
                end

                %average over neighboring channels
                stn_power = Freqtim_pow(refchan_ind,:,:);
                m1_power = mean(Freqtim_pow(ind_cort_neigh{contains(cortchans,'m1')},:,:));
                sma_power = mean(Freqtim_pow(ind_cort_neigh{contains(cortchans,'sma')},:,:));
                stn_m1_coh = mean(Freqtim_coh(ind_cort_neigh{contains(cortchans,'m1')},:,:));
                stn_sma_coh = mean(Freqtim_coh(ind_cort_neigh{contains(cortchans,'sma')},:,:));

                %put into a dummy time-frequency structure
                load /data/project/hirsch/reverse/analysis/intermediate_data/data/dummy_tfr.mat

                tfr = dummy_tfr;
                tfr.freq = foi;
                tfr.time = timeaxis;
                tfr.label = new_chans';
                tfr.powspctrm = zeros([numel(new_chans),size(fou.fourierspctrm,3),size(fou.fourierspctrm,4)]);
               
                %stn power
                ind_stnpow = startsWith(new_chans,'STN ');
                tfr.powspctrm(ind_stnpow,:,:) = log10(stn_power);
                %decibel conversion 
                tfr.powspctrm(ind_stnpow,:,:) = tfr.powspctrm(ind_stnpow,:,:) *10;

                %m1 power
                ind_m1pow = startsWith(new_chans,'M1 ');
                tfr.powspctrm(ind_m1pow,:,:) = log10(m1_power);
                tfr.powspctrm(ind_m1pow,:,:) = tfr.powspctrm(ind_m1pow,:,:) *10;

                %sma power
                ind_smapow = startsWith(new_chans,'SMA ');
                tfr.powspctrm(ind_smapow,:,:) = log10(sma_power);
                tfr.powspctrm(ind_smapow,:,:) = tfr.powspctrm(ind_smapow,:,:) *10;

                %stn-m1 coh
                ind_stnm1 = startsWith(new_chans,'STN-M1');
                tfr.powspctrm(ind_stnm1,:,:) = stn_m1_coh;

                %added stn-sma coh
                ind_stnsma = startsWith(new_chans,'STN-SMA');
                tfr.powspctrm(ind_stnsma,:,:) = stn_sma_coh;

                data_hemi{s} = tfr;

                %spectrum
                cfg = [];
                cfg.avgovertime = 'yes';
                cfg.nanmean = 'yes';
                spec = ft_selectdata(cfg,tfr);

                %band-avg pow/coh
                cfg = [];
                cfg.frequency = [band_start band_stop];
                cfg.avgoverfreq = 'yes';
                band = ft_selectdata(cfg,spec);

                %post
                cfg = [];
                cfg.latency = [0 2];
                cfg.nanmean = 'yes';
                tfr_post = ft_selectdata(cfg,tfr);

                %pre
                cfg = [];
                cfg.latency = [-2 0];
                cfg.nanmean = 'yes';
                tfr_pre = ft_selectdata(cfg,tfr);

                cfg = [];
                cfg.avgovertime = 'yes';
                cfg.nanmean = 'yes';
                tfr_pre = ft_selectdata(cfg,tfr_pre);

                cfg = [];
                cfg.avgovertime = 'yes';
                cfg.nanmean = 'yes';
                tfr_post = ft_selectdata(cfg,tfr_post);

                cfg = [];
                cfg.frequency = [band_start band_stop];
                cfg.avgoverfreq = 'yes';
                tfr_pre = ft_selectdata(cfg,tfr_pre);

                cfg = [];
                cfg.frequency = [band_start band_stop];
                cfg.avgoverfreq = 'yes';
                tfr_post = ft_selectdata(cfg,tfr_post);

                %baseline correction
                cfg = [];
                cfg.baseline = [-2 0];
                cfg.baselinetype = 'absolute';
                tfr_blcorr = ft_freqbaseline(cfg,tfr);

                %keep only post times of bl corrected
                cfg = [];
                cfg.latency = [0 2];
                cfg.nanmean = 'yes';
                tfr_blcorr_post = ft_selectdata(cfg,tfr_blcorr);

                %spectrum blcorr
                cfg = [];
                cfg.avgovertime = 'yes';
                cfg.nanmean = 'yes';
                spec_blcorr = ft_selectdata(cfg,tfr_blcorr_post);

                %band-avg pow/coh bl corrected
                cfg = [];
                cfg.frequency = [band_start band_stop];
                cfg.avgoverfreq = 'yes';
                band_blcorr = ft_selectdata(cfg,spec_blcorr);

                %band-time
                cfg = [];
                cfg.avgoverfreq = 'yes';
                cfg.frequency = [band_start band_stop];
                band_time_blcorr = ft_selectdata(cfg,tfr_blcorr);

                %cross correlation
                cross_corr = struct();
                cross_corr.label = band_time_blcorr.label(4:5);
                nlags = length(band_time_blcorr.time)*2-3;
                cross_corr.lags = zeros(1,nlags);
                cross_corr.xcorr = zeros(2,nlags);

                chan_tuples = [{'STN ','M1 '};{'STN ','SMA '}];
                for ch = 1:size(chan_tuples,1)
                    chan_tuple = chan_tuples(ch,:);
                    [r,lags] = xcorr(band_time_blcorr.powspctrm(startsWith(band_time_blcorr.label,chan_tuple{1}),1:end-1),band_time_blcorr.powspctrm(startsWith(band_time_blcorr.label,chan_tuple{2}),1:end-1),'normalized');
                    cross_corr.lags = lags;
                    cross_corr.xcorr(ch,:) = r;
                end

                %pow table for stats
                pow_inds = any([ind_stnpow;ind_m1pow;ind_smapow]);
                band_pow = band.powspctrm(pow_inds);
                band_pow_blcorr = band_blcorr.powspctrm(pow_inds);
                band_pow_post = tfr_post.powspctrm(pow_inds);
                band_pow_pre = tfr_pre.powspctrm(pow_inds);

                band_pow_chans = band.label(pow_inds);
                this_pow_tbl = table(repmat({subj},[length(band_pow), 1]),repmat({current_condi},[length(band_pow), 1]),...
                    repmat({this_event},[length(band_pow),1]),band_pow_chans, band_pow, band_pow_blcorr,band_pow_post,band_pow_pre,...
                    'VariableNames',{'subject','predictability','movement','area','power','powerBlCorr','tfr_post','tfr_pre'});
                pow_tbl = [pow_tbl;this_pow_tbl];

                %coh table for stats
                coh_inds = any([ind_stnm1;ind_stnsma]);
                band_coh = band.powspctrm(coh_inds);
                band_coh_blcorr = band_blcorr.powspctrm(coh_inds);
                band_coh_post = tfr_post.powspctrm(coh_inds);
                band_coh_pre = tfr_pre.powspctrm(coh_inds);

                band_coh_chans = band.label(coh_inds);
                this_coh_tbl = table(repmat({subj},[length(band_coh), 1]),repmat({current_condi},[length(band_coh), 1]),...
                    repmat({this_event},[length(band_coh),1]),band_coh_chans, band_coh, band_coh_blcorr,band_coh_post,band_coh_pre,...
                    'VariableNames',{'subject','predictability','movement','area','coh','cohBlCorr','tfr_post','tfr_pre'});
                coh_tbl = [coh_tbl;this_coh_tbl];

            end
        end
    end
end

save([save_here,'tables_for_stats_',(alignedto),'_final_pre_and_post.mat'],'pow_tbl','coh_tbl');

