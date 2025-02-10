
%Plot individual subjects with pre or movavg BL or no Bl; 
% trig or mov aligned

alignedto = 'movaligned'; %trigaligned or movaligned 
bl = 'pre'; %pre, moveavg, no_bl

%%%%%%%%%%%%%%%%%%%%%%
zlims = [-0.3 0.3];
zlims = [-3 3];

%for no_bl these are the zlims for the individual subjects in past version
%of the paper 
%s = [13 5 17 10 8 11];
%13([0 0.0000000006])
%5 [0 0.00000000009])
%17([0 0.000000000015])
%10 ([0 0.0000000012])
%8 caxis([0 0.00000000025])
%11 stop und rev:([0 0.00000000025]);start:([0 0.00000000015])

%get field names from rev info structure
load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);
frequency = 'beta';
use_type = 'freqmean';

datadir = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_',alignedto,'/'];
conditions = {'pred','unpred'};
events = {'reversals','start','stop'};
plot_col_labels = {'start','stop','reverse'};
plot_row_labels = {'STN','M1','SMA'}; 

chans = {'M1','STN'};
hemis = {'contra','ipsi'};

for s =  rev_info.all_subjects_in_use %go through subjects 

    subj = subjects{s};

    for h = 1:2 %go through hemispheres 

        hemi = hemis{h};

        for c = 1:numel(conditions) %go through conditions 

            cond = conditions{c};

            for a = 1:numel(chans) %go through areas of interest

                area = chans{a};

                tfrs = {};

                for e = 1:3 %go through events 

                    event = events{e};
                    
                    %load the data 
                    if contains(bl,'no_bl')
                        pow = load([datadir,subj,'_',cond,'_',event,'_',hemi,'_powandcoh_nolog.mat']);
                    else
                        pow = load([datadir,subj,'_',cond,'_',event,'_',hemi,'_','powandcoh.mat']);
                    end

                    if strcmp(bl,'pre')

                        %choose data with bl-correction
                        tfrs_condis{e} = pow.tfr_blcorr;

                    else

                        tfrs_condis{e} = pow.tfr;
                    end
                end

                %perform movement-average Baselining
                if strcmp(bl,'move_avg')

                    tfr_move_avg = ft_freqgrandaverage([],tfrs_condis{1:3});
                    avgmov = nanmean(tfr_move_avg.powspctrm,3);
                    avgmov_4bl = repmat(avgmov,[1,1,size(tfr_move_avg.powspctrm,3)]);

                    for ev = 1:3
                        new_bl_tfr = tfrs_condis{ev};
                        new_bl_tfr.powspctrm = tfrs_condis{ev}.powspctrm-avgmov_4bl;
                        tfrs_new_condis{ev} = new_bl_tfr;
                    end

                    tfrs_condis = tfrs_new_condis;
                end
              
                tfrs = tfrs_condis;

                for t = 1:numel(tfrs) %go through events 

                    %choose TFR and corresponding event 
                    tfr = tfrs{t};
                    event = events{t};

                    channel = [area,' ',hemi];

                    %load subject dial speed
                    load(['/data/project/hirsch/reverse/analysis/intermediate_data/data/dialspeed/',alignedto,'/',event,'/',cond,'/',subj,'_dialspeedToPlot.mat']);

                    %plot
                    cfg = [];
                    cfg.channel = [area,' ',hemi];
                    cfg.title = ' ';
                    cfg.parameter = 'powspctrm';
                    cfg.ylim = [5 45];
                    cfg.xlim = [-1.4 1.4];
                    cfg.masknans = 'yes';
                    cfg.colorbar = 'no';
                    ft_singleplotTFR(cfg,tfr);

                    addpath('/net/citta/storage/data_project/reverse/analysis/scripts/Final_analysis/cbrewer/')
                    %keep regular color scheme for no bl data
                    if ~contains(bl,'no_bl')
                        cm = cbrewer('div','RdBu',80);
                        colormap(flipud(cm));
                    end

                    caxis(zlims)

                    set(gca,'XTickLabels',[])
                    set(gca,'YTickLabels',[])

                    if length(dial_speed_new) == 1425
                        time = [-1.424:0.002:1.424];
                    elseif length(dial_speed_new) == 1426
                        time = [-1.425:0.002:1.425];
                    elseif length(dial_speed_new) == 1424
                        time = [-1.423:0.002:1.423];
                    end
                    
                    yyaxis right
                    hold on
                    ax = gca;
                    ax.YAxis(2).Color = 'k';
                    s = line(time,dial_speed_new,'color','k');
                    set(s,'LineWidth',6)
                    ylim([0 600])
                    if contains(subj,'s21')
                        ylim([0 750])
                    end

                    set(gca,'YTickLabels',[])
                    XLims = get(gca,'XLim');
                    xline(0,'r-','LineWidth',4)
                    xlim(XLims)

                    ax = gca;
                    ax.FontSize = 60;

                    figuredir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/tfr_',alignedto,'/',bl,'_bl/'];
                
                    saveas(gcf,[figuredir,'tfr_',(subj),'_',event,'_',channel,'_',cond,'_new.png'])
                    set(gcf,'DefaultAxesTitleFontWeight','normal')
                    set(gcf,'PaperOrientation','landscape')
                    print(gcf,'-dpdf','-r300','-fillpage',[figuredir,'tfr_',(subj),'_',event,'_',channel,'_',cond,'_new.pdf'])
                    close all
                end
            end
        end
    end
end

   

