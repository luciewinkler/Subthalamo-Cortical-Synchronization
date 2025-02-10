
% create headmodels and sourcemodels 

addpath(genpath('/data/project/hirsch/reverse/dacq/MRIs/'))

load /data/project/hirsch/reverse/analysis/Info/rev_info

subjects = fieldnames(rev_info);

for i = rev_info.all_subjects_in_use %go through subjects 
    
    subj = subjects{i}; 
    
    %load subject MRI
    mri_oi = ['/data/project/hirsch/reverse/dacq/MRIs/',(subj),'/MRI/t1/176/sets/',subj,'_winluc01_tal_lmk.fif'];
    mri = ft_read_mri(mri_oi);

    %segmentation of MRI 
    mri.coordsys = 'neuromag';
    cfg = [];
    cfg.write      = 'no'; 
    [segmentedmri] = ft_volumesegment(cfg, mri);
    
    %prepare single shell headmodel
    cfg = [];
    cfg.method = 'singleshell';
    headmodel = ft_prepare_headmodel(cfg, segmentedmri);
        
    %save headmodel
    save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/headmodels/headmodel_',(subj),'.mat'],'headmodel');
    
    %create MNI aligned grid 
                
    %create template grid based on a standard head model 
    [ftver,ftpath] = ft_version;
    load(fullfile(ftpath, 'template/headmodel/standard_singleshell.mat'));

    cfg = [];
    cfg.xgrid = -20:1:20;
    cfg.ygrid = -20:1:20;
    cfg.zgrid = -20:1:20;
    cfg.unit = 'cm';
    cfg.tight = 'yes';
    cfg.inwardshift = -1.5;
    cfg.headmodel = vol; 
    template_grid = ft_prepare_sourcemodel(cfg);

    template_grid = ft_convert_units(template_grid,'cm');

    %determine coordysys
    template_grid.coordsys = 'mni';

    figure
    hold on 
    ft_plot_mesh(template_grid.pos(template_grid.inside,:));
    ft_plot_headmodel(vol,'facecolor','cortex','edgecolor','none');
    ft_plot_axes(vol);
    alpha 0.5
    camlight

    %load an atlas
    atlas = ft_read_atlas(fullfile(ftpath,'template/atlas/aal/ROI_MNI_V4.nii'));

    atlas = ft_convert_units(atlas,'cm');

    %With that and grid create a binary 
    %mask of all locations in template grid that match atlas locations 
    cfg = [];
    cfg.atlas = atlas; 
    cfg.roi = atlas.tissuelabel;
    cfg.inputcoord = 'mni';
    mask = ft_volumelookup(cfg,template_grid);

    template_grid.inside = false(template_grid.dim);
    template_grid.inside(mask == 1) = true; 
    
    %save template grid
    save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid','.mat'],'template_grid');

    figure; 
    ft_plot_mesh(template_grid.pos(template_grid.inside,:));

    %prepare the sourcemodel with the template grid 
    cfg = [];
    cfg.warpmni = 'yes';
    cfg.template = template_grid; 
    cfg.nonlinear = 'yes';
    cfg.mri = mri; 
    sourcemodel = ft_prepare_sourcemodel(cfg);

    headmodel = ft_convert_units(headmodel,'m');
    sourcemodel = ft_convert_units(sourcemodel,'m');

    %check code 
    figure 
    hold on 
    ft_plot_headmodel(headmodel,'facecolor','cortex','edgecolor','none');
    ft_plot_axes(headmodel);
    alpha 0.4 % make surface transparent 
    ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:));
    view ([0 -90 0]);

    sourcemodel.inside = sourcemodel.inside(:);
    
    save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/sourcemodel_',(subj),'.mat'],'sourcemodel');

    close all
end 



