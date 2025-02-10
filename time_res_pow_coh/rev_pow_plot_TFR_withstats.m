
%makes grandaverages of time-resolved power as single pictures 
%conducts permutation tests
%significant clusters shown in pictures
%choose event, alignment and frequency 

alignedto = 'movaligned'; %movaligned or trigaligned

%choose event: start, stop, reversals
this_event = 'start';
%choose frequency: beta, gamma
frequency = 'gamma';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
addpath('/data/project/hirsch/reverse/analysis/fieldtrip-20201229/')
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/cbrewer/');
ft_defaults
load /data/project/hirsch/reverse/analysis/Info/rev_info
datadir = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_',alignedto,'/'];

subjects = fieldnames(rev_info);
conditions = {'pred','unpred'};
hemis = {'contra','ipsi'};

if contains(frequency,'beta')
    freqlim = [5 45];
else
    freqlim = [55 90];
end

TFRs = cell(1,2);

for s = rev_info.all_subjects_in_use %go through subjects

    subj = subjects{s};

    for h = 1:2 %go through hemispheres

        hemi = hemis{h};

        for c = 1:numel(conditions) %go through conditions

            current_condi = conditions{c};

            %load the data
            if contains(frequency,'gamma')
                load([datadir,subj,'_',current_condi,'_',this_event,'_',hemi,'_','powandcoh_gamma.mat']);
            else
                load([datadir,subj,'_',current_condi,'_',this_event,'_',hemi,'_','powandcoh.mat']);
            end

            %rename labels
            tfr_blcorr.label{3} = strrep(tfr_blcorr.label{3},'SMA','MSMC');
            tfr_blcorr.label{5} = strrep(tfr_blcorr.label{5},'SMA','MSMC');
            tfr.label{3} = strrep(tfr.label{3},'SMA','MSMC');
            tfr.label{5} = strrep(tfr.label{5},'SMA','MSMC');

            %removing the space in between labels because the permutation
            %test is messed up by it
            for l = 1:5
                tfr_blcorr.label{l} = strrep(tfr_blcorr.label{l},' ','_');
                tfr.label{l} = strrep(tfr.label{l},' ','_');
            end

            %take the BL time-window
            cfg = [];
            cfg.latency = [-1.6 0];
            this_bl{h}{c} = ft_selectdata(cfg,tfr);

            %take the activation time-window
            cfg = [];
            cfg.latency = [0 1.6];
            this_activation{h}{c} = ft_selectdata(cfg,tfr);

            %store entire BL-corrected data
            this_TFRs{h}{c}= tfr_blcorr;
        end

        %average bl data across predictability conditions
        this_bl_comb = this_bl{h}{1};
        this_bl_comb.powspctrm = (this_bl{h}{1}.powspctrm + this_bl{h}{2}.powspctrm) ./2;

        %average activation data actoss predictability conditions
        this_act_comb = this_activation{h}{1};
        this_act_comb.powspctrm = (this_activation{h}{1}.powspctrm + this_activation{h}{2}.powspctrm) ./2;

        %average entire window over predictability conditions
        this_tfr_comb = this_TFRs{h}{1};
        this_tfr_comb.powspctrm = (this_TFRs{h}{1}.powspctrm + this_TFRs{h}{2}.powspctrm) ./2;

        %store all data
        BLs{h}{s}= this_bl_comb;
        activations{h}{s}= this_act_comb;
        TFRs{h}{s}= this_tfr_comb;
    end
end

%find empty cells and take them out
notempty = find(~cellfun(@isempty,TFRs{h}));
BLs{1} = BLs{1}(notempty);
BLs{2} = BLs{2}(notempty);
activations{1} = activations{1}(notempty);
activations{2} = activations{2}(notempty);
TFRs{1} = TFRs{1}(notempty);
TFRs{2} = TFRs{2}(notempty);

plot_type = 'tfr';
figdir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/';

%titles: just power; coherence is in a seperate script (chans 4-5)
channels = {'STN','MC','MSMC'};
hemispheres = {'contra','ipsi'};

%testing and plotting

for ch = 1:3 %go through the channels

    for h = 1:2 %go through hemispheres 

        hemisphere = hemispheres{h};

        %pick only the data (whole time win) for the current hemisphere 
        cfg = [];
        cfg.parameter = 'powspctrm';
        grandavg = ft_freqgrandaverage(cfg,TFRs{h}{:});

        this_activation = activations{h};
        this_bl = BLs{h};

        %choose frequencies to plot and to calculate stat on
        cfg = [];
        cfg.frequency = freqlim;
        grandavg = ft_selectdata(cfg,grandavg);

        %load average wheel speed
        load(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',alignedto,'/spec_pred_unpred_plot_',(this_event),'.mat']);
        dial_spec = spec_condis_new;

        chan = this_activation{1}.label{ch};
        neighbours.label = chan;
        neighbours.neighblabel = {};

        %BL and activation must have the same time field for the stat test!
        %and pick the channel 
        for l = 1:20
            this_bl{l}.time = this_activation{1}.time;
            cfg = [];
            cfg.channel = chan;
            this_bl{l} = ft_selectdata(cfg,this_bl{l});
            this_activation{l} = ft_selectdata(cfg,this_activation{l});
            grandavg = ft_selectdata(cfg,grandavg);
        end

        if isfile(['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',(alignedto),'/with_stats/clusterstats_pow.mat'])
            load(['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',(alignedto),'/with_stats/clusterstats_pow.mat']);
        end

        %run the permutation test activation vs. BL
        nsubj=20;
        cfg = [];
        cfg.method = 'montecarlo';
        cfg.numrandomization = 1000;
        cfg.tail        = 0;
        cfg.statistic   = 'ft_statfun_actvsblT';
        cfg.design(1,:) = [1:nsubj 1:nsubj];
        cfg.design(2,:) = [ones(1,nsubj)*1 ones(1,nsubj)*2];
        cfg.uvar        = 1;
        cfg.ivar        = 2;
        cfg.correctm = 'cluster';
        cfg.clusteralpha = 0.05; %this is unrealted to false alarm rate
        cfg.correcttail = 'alpha';
        cfg.alpha = 0.025;
        cfg.frequency = freqlim;
        cfg.neighbours = neighbours;
        cfg.channel     = chan;
        stat = ft_freqstatistics(cfg, this_activation{:}, this_bl{:}); 

        event_time_range = [0 1.6];
       
        %in some cases when there is neither pos nor neg clusters it doesnt
        %have those fields at all; set it to 1 just so code can run
        if numel(stat.negclusters)==0
            stat.negclusters(1).prob = 1;
        end

        if numel(stat.posclusters)==0
            stat.posclusters(1).prob = 1;
        end

        %extract neg clusters
        cluster_pow_neg = [];
        matrix_pow_neg = [];
        if stat.negclusters(1).prob < 0.025
            cluster_pow_neg = stat.negclusterslabelmat==1;
            matrix_pow_neg = intention_tval_for_plot(...
                grandavg,cluster_pow_neg,freqlim,event_time_range);
            stats.(alignedto).(frequency).(this_event).(chan) = stat.negclusters(1);
        end

        %extract pos clusters
        cluster_pow_pos = [];
        matrix_pow_pos = [];
        if stat.posclusters(1).prob < 0.025
            cluster_pow_pos = stat.posclusterslabelmat==1;
            matrix_pow_pos = intention_tval_for_plot(...
                grandavg,cluster_pow_pos,freqlim,event_time_range);
            stats.(alignedto).(frequency).(this_event).(chan) = stat.posclusters(1);
        end
       
        if exist('stats','var')
            save(['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',(alignedto),'/with_stats/clusterstats.mat'],'stats');
        end

        if stat.negclusters(1).prob < 0.025
            tvals = matrix_pow_neg;
        end

        if stat.posclusters(1).prob < 0.025
            tvals = matrix_pow_pos;
        end

        %create the boundaries for sign. clusters
        if stat.negclusters(1).prob < 0.025 || stat.posclusters(1).prob < 0.025
            tval_new = [];
            tval_new(1,:,:) = tvals;

            tval_new(tval_new>1)=1;
            grandavg.tval = tval_new;

            t = squeeze(grandavg.tval(1,:,:));

            B = bwboundaries(t, 'noholes');
        end

        %plot with sign. clusters
        ti = grandavg.label;
        Fontsize = 60;
        Cstat = flip(cbrewer('div','RdBu',80)); % Colorscheme to use

        plot_type = 'tfr';
        figdir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/';
        savedir = [figdir,plot_type,'_',alignedto,'/with_stats/',this_event,'/'];

        %plot
        figure
        contourf(grandavg.time,grandavg.freq,squeeze(grandavg.powspctrm(1,:,:)),200,'linecolor','none')
        hold on
        %plot red line at 0 point
        plot([0 0],freqlim,'Color','r','LineWidth',4,'LineStyle','-')
        hold on;
        if contains(frequency,'beta')
            if ~contains(this_event,'reversals')
                caxis([-4 4]);
            else
                caxis([-1.5 1.5]);
            end
        else
            if ~contains(this_event,'reversals')
                caxis([-0.5 0.5]);
            else
                caxis([-0.3 0.3]);
            end
        end
        colormap(Cstat);
        ax = gca;
        ax.FontSize = Fontsize;
        set(gca,'XTickLabels',[])
        set(gca,'YTickLabels',[])
        xlim([-1.4 1.4])
        hold on

        %add the dial speed
        time = [-1.424:0.002:1.424];
        yyaxis right
        hold on
        ax = gca;
        ax.YAxis(2).Color = 'k';
        s = line(time,dial_spec,'color','k');
        set(s,'LineWidth',6)
        ylim([0 600])
        set(gca,'YTickLabels',[])
        hold off

        %add the significant clusters
        if stat.negclusters(1).prob < 0.025 || stat.posclusters(1).prob < 0.025
            yyaxis left
            ax = gca;
            boundary = B{1};
            b1 = boundary(:,1)';
            %use positions to find freqs and timepoints in data
            b1_final = grandavg.freq(b1);
            b2 = boundary(:,2)';
            b2final = grandavg.time(b2);
            newboundary = [b1_final' b2final'];
            h = patch(newboundary(:, 2),newboundary(:, 1), 'k', 'LineWidth', 4,'FaceColor','none');
            
            %fill the signficant cluster with hatching
            H = hatchfill2(h,'HatchLineWidth',3,'HatchAngle',45,'HatchDensity',20);
            hold off
        end

        %save
        set(gcf,'DefaultAxesTitleFontWeight','normal')
        set(gcf,'PaperOrientation','landscape')
        print(gcf,'-dpdf','-r300','-fillpage',[savedir,'grandavg_',this_event,'_comb_',(frequency),'_',(chan),'_cluster.pdf'])
        close all
    end
end

