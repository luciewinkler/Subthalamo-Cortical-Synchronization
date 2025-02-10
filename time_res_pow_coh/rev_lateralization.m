%compares degree of lateralization btw beta suppression and rebound
%makes violin plots and boxlots

%it's possible to do this with all channels or just M1 (in paper just M1)
%all_chans = 1 or all chans=0, latter case only compares M1 lateralization
all_chans = 1;

%%%%%%%%%%%%%%%%%

load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);
conditions = {'pred','unpred'};
events = {'start','stop'};
mod_types = {'MRBD','PMBR'};
datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/';
save_here = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/final_tables/lat_peakfreq/';
hemis = {'contra','ipsi'};

%initialise tables for data collection
tbl_headers = {'modtype','subject','predictability','area','lat'};
tbl = cell2table(cell(0,length(tbl_headers)),'VariableNames', tbl_headers);

for e = 1:numel(events) %go through events and modulation types

    this_event = events{e};
    mod_type = mod_types{e};
    
    F = cell(numel(rev_info.all_subjects_in_use));

    for c = 1:numel(conditions) %go through conditions 

        current_condi = conditions{c};
        si = 1;

        for s = rev_info.all_subjects_in_use %go through subjects

            subj = subjects{s};
            
            data_hemi = cell(1,numel(hemis));

            for h = 1:numel(hemis) %go through hemispheres

                %load the data
                hemi = hemis{h};
                load([datadir,subj,'_',current_condi,'_',this_event,'_',hemi,'_powandcoh.mat']);

                %if using all chans
                if all_chans == 1
                    data_hemi{h}=abs(mean(spec_blcorr.powspctrm(1:3,and(spec_blcorr.freq>13,spec_blcorr.freq<30)),2));
                else
                    %if using M1 only
                    data_hemi{h}=abs(mean(spec_blcorr.powspctrm(2,and(spec_blcorr.freq>13,spec_blcorr.freq<30)),2));
                end
            end

            %calculate lateralization index
            lat_ind= (data_hemi{1}-data_hemi{2})./(data_hemi{1}+data_hemi{2});
            
            %store in a table; if all channels
            if all_chans == 1
                pow_chans = spec_blcorr.label(1:3);
                this_table = table(repmat({mod_type},[length(lat_ind),1]),repmat({subj},[length(lat_ind),1]),repmat({current_condi},[length(lat_ind),1]),...
                    [{pow_chans{1}(1:3)};{pow_chans{2}(1:3)};{pow_chans{3}(1:3)}],lat_ind,...
                    'VariableNames', tbl_headers);
            else
                %m1 only
                pow_chans = spec_blcorr.label(2);
                this_table = table(repmat({mod_type},[length(lat_ind),1]),repmat({subj},[length(lat_ind),1]),repmat({current_condi},[length(lat_ind),1]),...
                    [{pow_chans{1}(1)}],lat_ind,...
                    'VariableNames', tbl_headers);
            end

            tbl = [tbl;this_table];
        end

        si = si+1;

    end
end

%save the table
save([save_here,'lateralization_final.mat'],'tbl');

addpath('/users/jan/matlab_toolboxes/violinplots/Violinplot-Matlab-master/')

%make violin plots
violinplot([table2array(tbl(contains(tbl.modtype,"MRBD"),5)),table2array(tbl(contains(tbl.modtype,"PMBR"),5))],{'MRBD','PMBR'})
ylim([-0.5 1])
ax = gca;
ax.FontSize = 60;
set(gca,'XTickLabels',[])
set(gca,'YTickLabels',[])
savedir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/sup_vs_rebound/';
if ~exist(savedir,'dir')
    mkdir(savedir)
end

set(gcf,'PaperOrientation','landscape')
fig_save = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/';
print(gcf,'-dpdf','-r300','-fillpage',[fig_save,'lat_m1new_check.pdf'])
close all

%make boxplots 
load([save_here,'tables/data_spss_lat_final.mat']);

%avg over pred condis 
lat_STN_MRBD = mean([data_spss_lat(:,1),data_spss_lat(:,3)],2);
lat_STN_PMBR = mean([data_spss_lat(:,2),data_spss_lat(:,4)],2);
lat_m1_MRBD = mean([data_spss_lat(:,5),data_spss_lat(:,7)],2);
lat_m1_PMBR = mean([data_spss_lat(:,6),data_spss_lat(:,8)],2);
lat_msmc_MRBD = mean([data_spss_lat(:,9),data_spss_lat(:,11)],2);
lat_msmc_PMBR = mean([data_spss_lat(:,10),data_spss_lat(:,12)],2);

%combine the data
dat_all = vertcat(lat_STN_MRBD,lat_STN_PMBR,lat_m1_MRBD,lat_m1_PMBR,lat_msmc_MRBD,lat_msmc_PMBR);

%plot
G = ones(size(lat_STN_MRBD));
G = [G;2*G;3*G;4*G;5*G;6*G];
x = ones(size(G,1),1),G(:);
h = boxchart(x(:),dat_all,'GroupByColor',G(:));
hold on
xticklabels({'',''})
ylim([-0.75 1.1])
set(h,'Linewidth',2)
set(gca,'FontSize',60);
h(1).SeriesIndex = 1;
h(2).SeriesIndex = 6;
h(3).SeriesIndex = 1;
h(4).SeriesIndex = 6;
h(5).SeriesIndex = 1;
h(6).SeriesIndex = 6;
h(3).SeriesIndex = 1;
h(4).SeriesIndex = 6;
lgd = legend('beta suppression','beta rebound','Location','southeast');
fontsize(lgd,40,'points')

savedir = ['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/follow_up_tests/'];
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
set(gcf,'PaperOrientation','landscape')
print(gcf,'-dpdf','-r300','-fillpage',[savedir,'lat_stn_m1_msmc','.pdf'])
close all
