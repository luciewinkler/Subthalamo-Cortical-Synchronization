
%plots the absolute contrasts that were computed for post and pre movement
%power and coherence as grandaverages over subjects, movements and
%hemispheres (in case of coherence)
%from those plots, the coordinates for the ROIs were taken
%the surface plots are used in the paper. The ortho plots are commented
%out; they served to find the positions of max coherence and power but do
%not appear in the paper 

addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/');
path_data = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/ROIs/';

load /data/project/hirsch/reverse/analysis/Info/rev_info

%load standard template grid
load '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid';
%load standard template mri
template_mri = ['/data/apps/fieldtrip/latest/template/anatomy/single_subj_T1.nii'];
template_mri = ft_read_mri(template_mri);

subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred'};

freqbands = 'beta';
events = {'reversals','start','stop'};

%load contrasts 
%coh
load([path_data,'contrasts_all_ipsi_abs.mat']);
load([path_data,'contrasts_all_contra_abs.mat']);
%pow
load([path_data,'contrasts_pow_abs.mat']);

notempty = find(~cellfun(@isempty,abs_contrasts{1}));

%compute grandaverages
cfg = [];
cfg.parameter = 'coh';
%for coherence: over events and hemispheres
grandavg_coh_ipsi_contra = ft_sourcegrandaverage(cfg,all_contra_abs{1}{notempty},all_contra_abs{2}{notempty},all_contra_abs{3}{notempty},all_ipsi_abs{1}{notempty},all_ipsi_abs{2}{notempty},all_ipsi_abs{3}{notempty});
%for power: over events
cfg.parameter = 'pow';
grandavg_pow = ft_sourcegrandaverage(cfg,abs_contrasts{1}{notempty},abs_contrasts{2}{notempty},abs_contrasts{3}{notempty});

restoredefaultpath
fiedtrippath = '/data/project/hirsch/reverse/analysis/fieldtrip_2023/';
addpath(fiedtrippath)
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/')
ft_defaults

%plot Coherence on surface
cfg = [];
cfg.method        = 'surface';
cfg.funparameter  = 'coh';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim = [0 0.005];
cfg.funcolormap   = 'default';
cfg.opacitymap = 'rampup';
cfg.projmethod = 'nearest';
cfg.surffile = 'surface_pial_both.mat';
cfg.surfdownsample = 10;
cfg.camlight = 'yes';
ft_colorbar = 'no';
ft_sourceplot(cfg, grandavg_coh_ipsi_contra);

cm = cbrewer('div','RdBu',80);
colormap(flipud(cm));
caxis([-0.005 0.005])
colorbar('off')
alpha 0.6 % make surface transparent
hold on;
%plot ROI
scatter3(-1,-3,6,80,'MarkerFaceColor','b');
hold on;
scatter3(1,-3,6,80,'MarkerFaceColor','b');
savedir = '/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/ROIs/';
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
set(gcf,'PaperOrientation','landscape')
print(gcf,'-dpdf','-r300','-fillpage',[savedir,'coh_ROI_grandavg_abs.pdf'])
close all

%plot power on surface
cfg = [];
cfg.method        = 'surface';
cfg.funparameter  = 'pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim = [0 0.5];
cfg.funcolormap   = 'default';
cfg.opacitymap = 'rampup';
cfg.projmethod = 'nearest';
cfg.surffile = 'surface_pial_both.mat';
cfg.surfdownsample = 10;
cfg.camlight = 'yes';
ft_sourceplot(cfg, grandavg_pow);

cm = cbrewer('div','RdBu',80);
colormap(flipud(cm));
colorbar('off')
alpha 0.6 % make surface transparent
hold on
%Plot ROI
scatter3(-4,-2,5,80,'MarkerFaceColor','b');
hold on;
scatter3(4,-2,5,80,'MarkerFaceColor','b');
set(gcf,'Units','inches','Position',[0, 0, 8.5, 11])
set(gcf,'PaperPositionMode','auto')
set(gcf,'PaperOrientation','landscape')
print(gcf,'-dpdf','-r300','-fillpage',[savedir,'pow_ROI_grandavg_abs.pdf'])
close all

% %interpolate to template MRI
% cfg = [];
% cfg.downsample = 2;
% cfg.parameter = 'coh';
% source_coh_int = ft_sourceinterpolate(cfg,grandavg_coh_ipsi_contra,template_mri);
% cfg.parameter = 'pow';
% source_pow_int = ft_sourceinterpolate(cfg,grandavg_pow,template_mri);
% 
% %plot in MRI: Here the ROIs can be identified 
% cfg = [];
% cfg.funparameter = 'coh';
% cfg.maskstyle = 'opacity';
% cfg.opacitylim = 'maxabs';
% cfg.maskparameter = cfg.funparameter;
% cfg.interactive = 'yes';
% cfg.opacitymap = 'rampup';
% cfg.method = 'ortho';
% cfg.axis = 'off';
% cfg.title = 'max. coherence';
% ft_sourceplot(cfg,source_coh_int,template_mri);
% saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/coh_ROI_grandavg_abs_ortho','.jpeg']);
% close all
% 
% cfg.funparameter = 'pow';
% ft_sourceplot(cfg,source_pow_int,template_mri);
% saveas(gcf,['/data/project/hirsch/reverse/analysis/intermediate_data/Figures/coh/sourcePowCoh/pow_ROI_grandavg_abs_ortho','.jpeg']);
% close all




   
