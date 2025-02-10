
%run time freq analysis for LFP and MEG data
%Inspect to find best LFP chan in plots 
%plot MEG data as single and multi plot

% freq_oi = 'beta'; %choose beta, gamma, theta, betagamma
freq_lim_oi = 2:48;
freq_oi = 'beta'; 

%%%%%%%%%%%%%%%%%%%
load /data/project/hirsch/reverse/analysis/Info/rev_info
alignedto = 'movaligned';
path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'];

%get field names from rev info structure
subjects = fieldnames(rev_info);
%experimental conditions
conditions = {'pred','unpred','rest'};
events = {'reversals','start','stop'};

base = [-1.4 -0.4]; %because some activity may move to before onset when doing TFA
pre = 2;
post = 2;
step_size = 0.05;

for i = rev_info.all_subjects_in_use %go through subjects
    
    subj = subjects{i}; 

    for h = 1:3 %go through movements
        
        this_event = events{h};
        
        for j = 1:2 %go through conditions
            
            current_condi = conditions{j};
            
            %load data
            file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(this_event)];
            load(file_oi)
            
            %only take LFP and MEG data
            cfg = [];
            cfg.channel = {'MEG***2','MEG***3','LFP*'};
            rev_trials = ft_selectdata(cfg,rev_trials);

            %and run TFA
            cfg = [];
            cfg.method = 'mtmconvol';
            if contains(freq_oi, 'gamma')
                cfg.taper = 'dpss';
                cfg.tapsmofrq = 4;
            else
                cfg.taper = 'hanning';
            end
            cfg.pad = 'nextpow2';
            cfg.toi = rev_trials.time{1}(1)+0.5:step_size:rev_trials.time{1}(end)-0.5;
            if i == 8 && contains(this_event,'start') && j == 2
                cfg.toi = rev_trials.time{1}(1)+0.5:step_size:rev_trials.time{1}(end)-0.45;
            end
            cfg.foi = freq_lim_oi;
            cfg.t_ftimwin = 1*ones(1,length(cfg.foi));
            freq = ft_freqanalysis(cfg,rev_trials);
            if contains(freq_oi,'beta')
                freq.powspctrm = log10(freq.powspctrm);
            end
            
            %save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/tfa_meg_lfp/tfa_',(freq_oi),(subj),(current_condi),(this_event),'noBL_nolog.mat'],'freq');
            
            %select only lfp labels
            lfps = contains(freq.label,'LFP');
            labels = freq.label(lfps);
            
            %plot all LFP chans together to selecta contact
            figure
            for m = 1:numel(labels)
                this_label = labels{m};
                this_subplot = m;
                if contains(subj,'s12')
                    s = subplot(6,3,this_subplot);
                else
                    s = subplot(4,4,this_subplot);
                end
                cfg = [];
                cfg.figure = s;
                cfg.channel = this_label;
                cfg.parameter = 'powspctrm';
                cfg.xlim = [-1.4 1.4];
                cfg.masknans = 'yes';
                cfg.baseline = base;
                if contains(freq_oi,'gamma')
                    cfg.baselinetype = 'relchange';
                else
                    cfg.baselinetype = 'absolute';
                end
                ft_singleplotTFR(cfg,freq);
                set(gcf, 'Position', get(0, 'Screensize'));
            end

            % saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/LFPs/conditions/',(alignedto),'/',(this_event),'/LFP_',(freq_oi),'_',(subj),(current_condi),(this_event),'.jpeg']);
            % close all

            %select only meg channels
            megs = contains(freq.label,'MEG');
            labels = freq.label(megs);

            %plot them
            cfg = [];
            cfg.channel = labels;
            cfg.parameter = 'powspctrm';
            cfg.layout = 'neuromag306planar';
            cfg.xlim = [-1.4 1.4];
            cfg.masknans = 'yes';
            cfg.baseline = base;
            if contains(freq_oi,'gamma')
                cfg.baselinetype = 'relchange';
            else
                cfg.baselinetype = 'absolute';
            end
            cfg.title = this_event;
            ft_singleplotTFR(cfg,freq);
            set(gcf, 'Position', get(0, 'Screensize'));
            saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/tsss_MEG/conditions/',(alignedto),'/',(this_event),'/MEG_',(freq_oi),'_',(subj),(current_condi),(this_event),'.jpeg']);
            close all

            ft_multiplotTFR(cfg,freq);
            set(gcf, 'Position', get(0, 'Screensize'));
            saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/tsss_MEG/conditions/',(alignedto),'/',(this_event),'/MEG_multi_',(freq_oi),'_',(subj),(current_condi),(this_event),'.jpeg']);
            close all
        end
    end
end

