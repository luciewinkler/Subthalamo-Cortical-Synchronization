
%calculated granger causality (orgininal and reversed) for all conditions,
%events, channels (averages over neighboring cortical chans)
%makes plots for individual subjects 

freq_oi = 'gamma';
% freq_oi = 'beta';

alignedto = 'movaligned';

datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors/';
save_here = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/granger_elife/';
load /data/project/hirsch/reverse/analysis/Info/rev_info

subjects = fieldnames(rev_info);
conditions = {'pred','unpred'};
events = {'start','stop','reversals'};

for i = rev_info.all_subjects_in_use %go through subjects 
    
    subj = subjects{i};
    STN_contra = rev_info.(subj).bestcontact_contra;
    STN_ipsi = rev_info.(subj).bestcontact_ipsi;
    
    for j = 1:numel(conditions) %go through conditions

        current_condi = conditions{j};
        
        for h = 1:numel(events) %go through events 
            
            this_event = events{h};

            %load data
            file = [datadir,'chans_neighbors_LFP_',subj,current_condi,this_event,'beta.mat'];
            load(file)

            %post event time window 
            cfg = [];
            cfg.toilim = [0 2];
            all_data = ft_redefinetrial(cfg,all_data);
          
            if isfield(all_data,'sampleinfo')
                all_data = rmfield(all_data,'sampleinfo');
            end
            
            %segments of 1s
            cfg = [];
            cfg.length = 1;
            cfg.overlap = 0;
            all_data_seg = ft_redefinetrial(cfg,all_data);

            %make reversed data
            all_data_seg_rev = all_data_seg;

            for t = 1:length(all_data_seg_rev.trial)
                all_data_seg_rev.trial{t} = flip(all_data_seg_rev.trial{t},2);
            end
            
            hemispheres = {'contra','ipsi'};
            data_hemi = cell(1,length(hemispheres));

            for s = 1:length(hemispheres) %go through hemispheres 
                
                hemi = hemispheres{s};
                refchan = [hemi,'_STN'];
                cortchans = {[hemi,'_m1'],[hemi,'_sma']};
                ind_cort_neigh = {};

                %get indices for each group of neighbors
                for x = 1:numel(cortchans)

                    cortchan = cortchans{x};
                    con = startsWith(all_data.label,cortchan);
                    if any(con)
                        ind_cort_neigh = [ind_cort_neigh;{find(con)}];
                    end
                end
                
                %compute freq analysis for all chans of interest and neighbors
                for ch = 1:2 %go through M1 and SMA
                    for gr = 1:7 %go through neighbors
                        cfg = [];
                        cfg.channel = [all_data.label(ind_cort_neigh{ch}(gr));{refchan}];
                        cfg.output = 'fourier';
                        cfg.method = 'mtmfft';
                        cfg.taper = 'dpss';
                        cfg.tapsmofrq = 4;
                        cfg.keeptrials = 'yes';
                        if contains(freq_oi, 'gamma')
                            cfg.foilim = [0 95];
                        else
                            cfg.foilim = [0 48];
                        end
                        fou{ch}{gr} = ft_freqanalysis(cfg,all_data_seg);
                        fou_rev{ch}{gr} = ft_freqanalysis(cfg,all_data_seg_rev);
                    end
                end
              
                %spectral granger causality
                for ch = 1:2 %go through M1 and SMA
                    for gr = 1:7 %go through neighbors
                        cfg = [];
                        cfg.method = 'granger';
                        granger{ch}{gr} = ft_connectivityanalysis(cfg,fou{ch}{gr});
                        granger_rev{ch}{gr} = ft_connectivityanalysis(cfg,fou_rev{ch}{gr});
                    end
                end

                granger_new = [];
                granger_new_rev = [];

                %average granger estimates over neighbors 
                for ch = 1:2

                    %this is the chan of interest; then add neighbors to it
                    granger_new{ch} = granger{ch}{1}.grangerspctrm;
                    granger_new_rev{ch} = granger_rev{ch}{1}.grangerspctrm;

                    for gr = 2:7 % add them to the first one
                        granger_new{ch} = granger_new{ch} + granger{ch}{gr}.grangerspctrm;
                        granger_new_rev{ch} = granger_new_rev{ch} + granger_rev{ch}{gr}.grangerspctrm;
                    end

                    granger_new{ch} = granger_new{ch}/7;
                    granger_new_rev{ch} = granger_new_rev{ch}/7;

                    %plug into a struct
                    granger_final{ch} = granger{ch}{1};
                    granger_final{ch}.grangerspctrm = granger_new{ch};

                    granger_final_rev{ch} = granger_rev{ch}{1};
                    granger_final_rev{ch}.grangerspctrm = granger_new_rev{ch};

                end

                %plot
                for ch = 1:2
                    chan_save = cortchans{ch};
                    cfg = [];
                    cfg.parameter = 'grangerspctrm';
                    if contains(freq_oi,'gamma')
                        cfg.xlim = [55 90];
                        cfg.zlim = [0 0.05];
                    else
                        cfg.xlim = [5 40];
                        cfg.zlim = [0 0.02];
                    end
                    figure
                    ft_connectivityplot(cfg,granger_final{ch});
                    set(gcf, 'Position', get(0, 'Screensize'));
                    saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/granger/elife/granger_',(subj),'_',(current_condi),'_',(this_event),'_',(chan_save),'-',(refchan),'_',(freq_oi),'.jpeg']);
                    close all
                    figure
                    ft_connectivityplot(cfg,granger_final_rev{ch});
                    saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/granger/elife/granger_rev_',(subj),'_',(current_condi),'_',(this_event),'_',(chan_save),'-',(refchan),'_',(freq_oi),'.jpeg']);
                    close all 
                end

                %save
                grang = granger_final{1};
                save([save_here,'granger_',subj,'_',current_condi,'_',this_event,'_',hemi,'_M1-',refchan,'_',(freq_oi),'.mat'],'grang');

                grang_rev = granger_final_rev{1};
                save([save_here,'granger_rev_',subj,'_',current_condi,'_',this_event,'_',hemi,'_M1-',refchan,'_',(freq_oi),'.mat'],'grang_rev');

                grang = granger_final{2};
                save([save_here,'granger_',subj,'_',current_condi,'_',this_event,'_',hemi,'_SMA-',refchan,'_',(freq_oi),'.mat'],'grang');

                grang_rev = granger_final_rev{2};
                save([save_here,'granger_rev_',subj,'_',current_condi,'_',this_event,'_',hemi,'_SMA-',refchan,'_',(freq_oi),'.mat'],'grang_rev');
            end
        end
    end
end


                
