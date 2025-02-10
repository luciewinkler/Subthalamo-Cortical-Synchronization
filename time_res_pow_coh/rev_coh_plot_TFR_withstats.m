
%makes grandaverages of time-resolved coherence as single pictures 
%conducts permutation tests
%significant clusters shown in pictures
%choose event, alignment and whether to compare pred and unpred coherence
%or to compare pre and post event 

addpath('/net/citta/storage/data_project/reverse/analysis/fieldtrip-20201229/')
ft_defaults
cd '/net/citta/storage/data_project/reverse/analysis/scripts/Final_analysis'

%want to compre pred and unpred? Otherwise it will do post vs pre-event 
comp_pred_unpred = 0; 

alignedto = 'movaligned'; %trigaligned or movaligned
this_event = 'start'; %start, stop, reversals

%%%%%%%%%
load /data/project/hirsch/reverse/analysis/Info/rev_info
datadir = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_',alignedto,'/'];
addpath('/net/citta/storage/data_project/reverse/analysis/scripts/Final_analysis/cbrewer')
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/permutation/');

subjects = fieldnames(rev_info);
conditions = {'pred','unpred'};
hemis = {'contra','ipsi'};
TFRs = cell(1,2);

this_event = events{e};
frequencies = {'beta','gamma'};
freqs = {[5 45],[55 90]};

for f = 1:2

    %select freqency
    frequency = frequencies{f};
    freqlim = freqs{f};

    TFRs = [];
    BLs = []; 
    activations = [];

    for c = 1:numel(conditions) %go through conditions

        current_condi = conditions{c};

        for s = rev_info.all_subjects_in_use %go through subjects

            subj = subjects{s};

            for h = 1:2 %go through hemispheres

                hemi = hemis{h};

                %load the data
                if contains(frequency,'gamma')
                    load([datadir,subj,'_',current_condi,'_',this_event,'_',hemi,'_','powandcoh_gamma.mat']);
                else
                    load([datadir,subj,'_',current_condi,'_',this_event,'_',hemi,'_','powandcoh.mat']);
                end

                %only select coherence labels
                cfg = [];
                cfg.channel = tfr.label(4:5);
                tfr = ft_selectdata(cfg,tfr);
                tfr_blcorr = ft_selectdata(cfg,tfr_blcorr);

                %average over M1 and SMA-STN coherence
                cfg = [];
                cfg.avgoverchan = 'yes';
                tfr = ft_selectdata(cfg,tfr);
                %so that hemispheres can be averaged later
                tfr_blcorr_hemis{h} = ft_selectdata(cfg,tfr_blcorr);
                %this can be used to plug in the spectrum averaged over
                %hemispheres later
                tfr_blcorr = ft_selectdata(cfg,tfr_blcorr);

                %rename label
                tfr.label{1} = 'mean_m1_sma';
                tfr_blcorr.label{1} = 'mean_m1_sma';
                tfr_blcorr_hemis{h}.label{1} = 'mean_m1_sma';

                %get the baseline (pre-event)
                cfg = [];
                cfg.latency = [-1.6 0];
                bl_hemis{h} = ft_selectdata(cfg,tfr);

                %get the activation (post-event)
                cfg = [];
                cfg.latency = [0 1.6];
                activation_hemis{h} = ft_selectdata(cfg,tfr);
            end

            %avgerage over hemispheres for each subject
            tfr_blcorr.powspctrm = (tfr_blcorr_hemis{1}.powspctrm + tfr_blcorr_hemis{2}.powspctrm) ./2;
            bl = bl_hemis{1};
            bl.powspctrm = (bl_hemis{1}.powspctrm + bl_hemis{2}.powspctrm) ./2;
            activation = activation_hemis{1};
            activation.powspctrm = (activation_hemis{1}.powspctrm + activation_hemis{2}.powspctrm) ./2;

            %this has the whole time window with BL correction
            TFRs{c}{s}= tfr_blcorr; %for plotting the actual grandaverage for the whole timewindow 
            BLs{c}{s}= bl; %for the test
            activations{c}{s}= activation; %for the test
        end
    end

    chan = TFRs{1}{1}.label;
    neighbours.label = chan;
    neighbours.neighblabel = {};

    %leave out empty cells
    notempt = find(~cellfun(@isempty, activations{1}));
    activations{1} = activations{1}(notempt);
    activations{2} = activations{2}(notempt);
    BLs{1} = BLs{1}(notempt);
    BLs{2} = BLs{2}(notempt);
    TFRs{1} = TFRs{1}(notempt);
    TFRs{2} = TFRs{2}(notempt);

    %here permutation test to compare pred and unpred 
    if comp_pred_unpred == 1

        %average over subjects 
        cfg = [];
        cfg.parameter = 'powspctrm';
        grandavg_pred =  ft_freqgrandaverage(cfg,TFRs{1}{:});
        grandavg_unpred =  ft_freqgrandaverage(cfg,TFRs{2}{:});

        %Use the absolute contrast for plotting 
        grandavg = grandavg_pred;
        grandavg.powspctrm = grandavg_unpred.powspctrm-grandavg_pred.powspctrm;

        %select only the frequency band of interest
        cfg = [];
        cfg.frequency = freqlim;
        grandavg = ft_selectdata(cfg,grandavg);

        %run cluster-based permutation test
        nsubj=20;
        cfg = [];
        cfg.method = 'montecarlo';
        cfg.numrandomization = 1000;
        cfg.tail        = 0;
        cfg.statistic   = 'ft_statfun_depsamplesT';
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
        % stat_pred_vs_unpred = ft_freqstatistics(cfg, TFRs{2}{:},TFRs{1}{:}); %this checks the whole time window
        %compare only activations
        stat_pred_vs_unpred = ft_freqstatistics(cfg, activations{2}{:}, activations{1}{:});

        event_time_range = [0 1.6];

        cluster_pow_neg = [];
        matrix_pow_neg = [];

        %in some cases when there is neither pos nor neg clusters it doesnt
        %have those fields at all; set it to 1 just so code can run
        if numel(stat_pred_vs_unpred.negclusters)==0
            stat_pred_vs_unpred.negclusters(1).prob = 1;
        end

        if numel(stat_pred_vs_unpred.posclusters)==0
            stat_pred_vs_unpred.posclusters(1).prob = 1;
        end

        cluster_pow_neg = [];
        matrix_pow_neg = [];

        %extract neg clusters for plotting
        if stat_pred_vs_unpred.negclusters(1).prob < 0.025
            cluster_pow_neg = stat_pred_vs_unpred.negclusterslabelmat==1;
            matrix_pow_neg = intention_tval_for_plot(...
                grandavg,cluster_pow_neg,freqlim,event_time_range);
        end

        cluster_pow_pos = [];
        matrix_pow_pos = [];

        %extract pos clusters for plotting
        if stat_pred_vs_unpred.posclusters(1).prob < 0.025
            cluster_pow_pos = stat_pred_vs_unpred.posclusterslabelmat==1;
            matrix_pow_pos = intention_tval_for_plot(...
                grandavg,cluster_pow_pos,freqlim,event_time_range);
        end

        if stat_pred_vs_unpred.negclusters(1).prob < 0.025
            tvals = matrix_pow_neg;
        end

        if stat_pred_vs_unpred.posclusters(1).prob < 0.025
            tvals = matrix_pow_pos;
        end

        %create the boundaries for sign. clusters
        if stat_pred_vs_unpred.negclusters(1).prob < 0.025 || stat_pred_vs_unpred.posclusters(1).prob < 0.025

            tval_new = [];
            tval_new(1,:,:) = tvals;

            tval_new(tval_new>1)=1;
            grandavg.tval = tval_new;

            t = squeeze(grandavg.tval(1,:,:));

            B = bwboundaries(t, 'noholes');
        end

        %plot with sign. clusters
        ti = grandavg.label{1};
        Fontsize = 60;
        Cstat = flip(cbrewer('div','RdBu',80)); % Color scheme to use

        %load average wheel speed (averaged across pred and unpred)
        load(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',alignedto,'/spec_pred_unpred_plot_',(this_event),'.mat']);
        dial_spec = spec_condis_new;
        plot_type = 'tfr';
        %path for saving
        figdir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/';
        savedir = [figdir,plot_type,'_',alignedto,'/with_stats/',this_event,'/'];

        %plot
        figure
        contourf(grandavg.time,grandavg.freq,squeeze(grandavg.powspctrm(1,:,:)),200,'linecolor','none')
        hold on
        %plot red line at 0 point
        plot([0 0],freqlim,'Color','r','LineWidth',4,'LineStyle','-')
        hold on;
        caxis([-0.005 0.005]);
        colormap(Cstat);
        ax = gca;
        ax.FontSize = Fontsize;
        set(gca,'XTickLabels',[])
        set(gca,'YTickLabels',[])
        xlim([-1.4 1.4])
        hold on;

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
        if stat_pred_vs_unpred.negclusters(1).prob < 0.025 || stat_pred_vs_unpred.posclusters(1).prob < 0.025

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

        %save image
        set(gcf,'DefaultAxesTitleFontWeight','normal')
        set(gcf,'PaperOrientation','landscape')
        print(gcf,'-dpdf','-r300','-fillpage',[savedir,'unpred_vs_pred_cluster_',this_event,'_coh_areasPooled_',(frequency),'.pdf'])
        close all

    else

        %%%%%%%%%%
        %plot pred and unpred condis seperately and test post vs pre-event 
        for pr = 1:2

            this_condi = conditions{pr};

            %grandaverage for plotting
            cfg = [];
            cfg.parameter = 'powspctrm';
            grandavg_pred_unpred{pr} =  ft_freqgrandaverage(cfg,TFRs{pr}{:});

            %BL and activation must have the same time field for the stat test!
            for l = 1:20
                BLs{pr}{l}.time = activations{1}{1}.time;
            end

            %only frequencies of interest to plot and to calculate stat on
            cfg = [];
            cfg.frequency = freqlim;
            grandavg_pred_unpred{pr} = ft_selectdata(cfg,grandavg_pred_unpred{pr});
    
            %save stats later
            if isfile(['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',(alignedto),'/with_stats/clusterstats_coh.mat'])
                load(['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',(alignedto),'/with_stats/clusterstats_coh.mat']);
            end

            %run cluster-based permutation test
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
            stat{pr} = ft_freqstatistics(cfg, activations{pr}{:}, BLs{pr}{:});

            event_time_range = [0 1.6];

            %in some cases when there is neither pos nor neg clusters it doesnt
            %have those fields at all; set it to 1 just so code can run
            if numel(stat{pr}.negclusters)==0
                stat{pr}.negclusters(1).prob = 1;
            end

            if numel(stat{pr}.posclusters)==0
                stat{pr}.posclusters(1).prob = 1;
            end

            cluster_pow_neg = [];
            matrix_pow_neg = [];

            %extract neg clusters
            if stat{pr}.negclusters(1).prob < 0.025
                cluster_pow_neg = stat{pr}.negclusterslabelmat==1;
                matrix_pow_neg = intention_tval_for_plot(...
                    grandavg_pred_unpred{pr},cluster_pow_neg,freqlim,event_time_range);
                stats.(alignedto).(frequency).(this_condi).(this_event) = stat{pr}.negclusters(1);
            end

            cluster_pow_pos = [];
            matrix_pow_pos = [];

            %extract pos clusters
            if stat{pr}.posclusters(1).prob < 0.025
                cluster_pow_pos = stat{pr}.posclusterslabelmat==1;
                matrix_pow_pos = intention_tval_for_plot(...
                    grandavg_pred_unpred{pr},cluster_pow_pos,freqlim,event_time_range);
                 stats.(alignedto).(frequency).(this_condi).(this_event) = stat{pr}.posclusters(1);
            end

            if stat{pr}.negclusters(1).prob < 0.025
                tvals = matrix_pow_neg;
            end

            if stat{pr}.posclusters(1).prob < 0.025
                tvals = matrix_pow_pos;
            end

            %create boundaries for cluster
            if stat{pr}.negclusters(1).prob < 0.025 || stat{pr}.posclusters(1).prob < 0.025

                tval_new = [];
                tval_new(1,:,:) = tvals;

                tval_new(tval_new>1)=1;
                grandavg_pred_unpred{pr}.tval = tval_new;

                t = squeeze(grandavg_pred_unpred{pr}.tval(1,:,:));

                B = bwboundaries(t, 'noholes');
            end

            %save stats
            if exist('stats','var')
                save(['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',(alignedto),'/with_stats/clusterstats_coh.mat'],'stats');
            end

            ti = grandavg_pred_unpred{pr}.label{1};
            Fontsize = 60;
            % zlabel = '\Delta coherence'; 
            Cstat = flip(cbrewer('div','RdBu',80)); % Colorscheme to use

            %load average wheel speed
            load(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',alignedto,'/spec_',(this_condi),'_plot_',(this_event),'.mat']);
            dial_spec = spec_new;

            %path for saving
            plot_type = 'tfr';
            figdir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/';
            savedir = [figdir,plot_type,'_',alignedto,'/with_stats/',this_event,'/'];

            %plot
            figure
            contourf(grandavg_pred_unpred{pr}.time,grandavg_pred_unpred{pr}.freq,squeeze(grandavg_pred_unpred{pr}.powspctrm(1,:,:)),200,'linecolor','none')
            hold on
            %red line at time point 0
            plot([0 0],freqlim,'Color','r','LineWidth',4,'LineStyle','-')
            hold on;
            if f==1
                caxis([-0.01 0.01]);
            else
                caxis([-0.002 0.002]);
            end
            colormap(Cstat);
            ax = gca;
            ax.FontSize = Fontsize;
            set(gca,'XTickLabels',[])
            set(gca,'YTickLabels',[])
            xlim([-1.4 1.4])
            hold on;
       
            %add wheel speed
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

            %add sign. clusters
            if stat{pr}.negclusters(1).prob < 0.025 || stat{pr}.posclusters(1).prob < 0.025
                yyaxis left
                ax = gca;
                boundary = B{1};
                b1 = boundary(:,1)';
                %use positions to find freqs and timepoints in data
                b1_final = grandavg_pred_unpred{pr}.freq(b1);
                b2 = boundary(:,2)';
                b2final = grandavg_pred_unpred{pr}.time(b2);
                newboundary = [b1_final' b2final'];
                h = patch(newboundary(:, 2),newboundary(:, 1), 'k', 'LineWidth', 4,'FaceColor','none');

                %fill the cluster with hatching
                H = hatchfill2(h,'HatchLineWidth',3,'HatchAngle',45,'HatchDensity',20);
                hold off
            end

            %save
            set(gcf,'DefaultAxesTitleFontWeight','normal')
            set(gcf,'PaperOrientation','landscape')
            print(gcf,'-dpdf','-r300','-fillpage',[savedir,'grandavg_',this_event,'_coh_areasPooled_',this_condi,'_',(frequency),'_cluster_002.pdf'])
            close all
        end
    end
end
