
%creates virtual channels from ROIs_coh_pow

alignedto = 'movaligned'; %movaligned or trigaligned

path_sourcemodels = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/';
path_hdm = '/data/project/hirsch/reverse/analysis/intermediate_data/data/headmodels/';
path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'];
% path_data = ['/data/tmp/lucie/'];
addpath('/data/project/hirsch/reverse/analysis/scripts/Final_analysis/');

load /data/project/hirsch/reverse/analysis/Info/rev_info

subjects = fieldnames(rev_info);

%load standard template grid
load '/data/project/hirsch/reverse/analysis/intermediate_data/data/sourcemodels_mni/template_grid';

%load standard template mri
template_mri = ['/data/apps/fieldtrip/latest/template/anatomy/single_subj_T1.nii'];
template_mri = ft_read_mri(template_mri);

%experimental conditions
conditions = {'pred','unpred','rest'};
events = {'start','stop','reversals'};
lambda = 'ind_lambda';

%load coordinates for virtual channels
load /data/project/hirsch/reverse/analysis/intermediate_data/data/sources/coh/sourcePowCoh_movaligned/ROIs/coordis_coh_pow.mat;
        
for s = rev_info.all_subjects_in_use
    
    subj = subjects{s};
    hand = rev_info.(subj).used_hand; %which hand did they turn with
    %find chosen LFP contacts 
    STN_contra = rev_info.(subj).bestcontact_contra;
    STN_ipsi = rev_info.(subj).bestcontact_ipsi;
    
    % load subj headmodel 
    headmodel_oi = [path_hdm,'headmodel_',(subj),'.mat'];
    load(headmodel_oi);
    
    % load subj sourcemodel 
    sourcemodel_oi = [path_sourcemodels,'sourcemodel_',(subj),'.mat'];
    load(sourcemodel_oi);
    
    for j = 1:2 %go through conditions
        
        current_condi = conditions{j};
                        
        for f = 1:3 %go through events

            event = events{f};
            
            % load clean data
            if contains(alignedto,'trig')
                file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),(event)];
            else
                file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(event)];
            end
            
            load(file_oi)
            
            %select lfp contacts
            cfg = [];
            cfg.channel = {STN_contra,STN_ipsi};
            lfp_contacts = ft_selectdata(cfg,rev_trials);
            
            %rename them to ipsi and contra (to movement, i.e. used hand)
            if contains(hand,'left')
                if contains(lfp_contacts.label{1,1},'right')
                    lfp_contacts.label{1,1} = 'contra_STN';
                    lfp_contacts.label{2,1} = 'ipsi_STN';
                else
                    lfp_contacts.label{1,1} = 'ipsi_STN';
                    lfp_contacts.label{2,1} = 'contra_STN';
                end
            else
                if contains(lfp_contacts.label{1,1},'right')
                    lfp_contacts.label{1,1} = 'ipsi_STN';
                    lfp_contacts.label{2,1} = 'contra_STN';
                else
                    lfp_contacts.label{1,1} = 'contra_STN';
                    lfp_contacts.label{2,1} = 'ipsi_STN';
                end
            end
            
            % select gradiometers only
            cfg = [];
            cfg.channel = {'MEG***2','MEG***3'};
            data = ft_selectdata(cfg,rev_trials);
            
            % timelock analysis
            cfg = [];
            cfg.channel = 'MEG';
            cfg.covariance = 'yes';
            cfg.vartrllength = 2; 
            cfg.covariancewindow = 'all';
            cfg.trials = 'all';
            tlock = ft_timelockanalysis(cfg,data);           
            
            all_channels = cell(1,numel(coordis));
            %all locations and 7 neighboring locations each
            %first one original one, rest surrounding neighbors
            for c = 1:numel(all_channels) %go to the chan
                this_chan = coordis{c};
                for n = 1:7 %go through all positions incl neighbors and find position in mni template grid 
                    all_channels{c}{n} = find(ismember(template_grid.pos,round(this_chan{n}),'rows'));
                end
            end
            
            all_chans_beam = cell2mat([all_channels{1:numel(all_channels)}]);
            
            %find coordis to plot for individual subject
            for g = 1:numel(all_channels)
                this_coordi = all_channels{g};
                for co = 1:7
                    pos = this_coordi{co};
                    coordi_to_plot{g}{co} = sourcemodel.pos(pos,:);
                end
            end
            %
            figure
            hold on
            ft_plot_headmodel(headmodel,'facecolor','cortex','edgecolor','none');
            alpha 0.2 % make surface transparent
            view([0 90]);
            for g = 1:numel(all_channels)
                plotit = coordi_to_plot{g};
                for co = 1:7
                    point = plotit{co};
                    scatter3(point(1),point(2),point(3),40,'MarkerFaceColor','g');
                end
            end
            
            %for each subject individual lambda value
            eigval = eig(tlock.cov);
            lambda = max(eigval) * 0.001;
            
            %lcmv beamforming
            cfg = [];
            cfg.method = 'lcmv';
            cfg.headmodel = headmodel;
            cfg.sourcemodel = sourcemodel;
            cfg.sourcemodel.pos = sourcemodel.pos([all_chans_beam],:);
            cfg.sourcemodel.inside = true(numel(all_chans_beam),1);
            cfg.unit = sourcemodel.unit;
            cfg.lcmv.keepfilter = 'yes';
            cfg.lcmv.projectmom = 'yes';
            cfg.normalize = 'no';
            cfg.lcmv.lambda = lambda;
            source = ft_sourceanalysis(cfg,tlock);
           
            %create the virtual channels
            virtual_sensors = data;
            virtual_sensors = rmfield(virtual_sensors,'label');
            virtual_sensors = rmfield(virtual_sensors,'trial');
            virtual_sensors.trial = {};
            virtual_sensors.label = {};
            for i=1:size(source.pos,1)
                virtual_sensors.label = [virtual_sensors.label;['virtchan',num2str(i)]];
            end
            
            for tr = 1:numel(data.trial)
                virtual_sensors.trial{tr}=[];
                for i=1:size(source.pos,1)
                    filt_this_gridpoint= source.avg.filter{i};
                    data_this_gridpoint = reshape(filt_this_gridpoint,[1,size(data.trial{1},1)])* data.trial{tr};
                    virtual_sensors.trial{tr}=[virtual_sensors.trial{tr};data_this_gridpoint];
                end
            end
            
            %naming channels
            if contains(hand,'left')
                for virt = 1:7
                    virtual_sensors.label{virt,1} = ['ipsi_m1_',num2str(virt)];
                    virtual_sensors.label{virt+7,1} = ['contra_m1_',num2str(virt)];
                    virtual_sensors.label{virt+14,1} = ['ipsi_sma_',num2str(virt)];
                    virtual_sensors.label{virt+21,1} = ['contra_sma_',num2str(virt)];
                end
            else
                for virt = 1:7
                    virtual_sensors.label{virt,1} = ['contra_m1_',num2str(virt)];
                    virtual_sensors.label{virt+7,1} = ['ipsi_m1_',num2str(virt)];
                    virtual_sensors.label{virt+14,1} = ['contra_sma_',num2str(virt)];
                    virtual_sensors.label{virt+21,1} = ['ipsi_sma_',num2str(virt)];
                end
            end
            
            %put in one struct with LFPs for further analysis
            cfg = [];
            cfg.keepsampleinfo = 'no';
            all_data = ft_appenddata(cfg,virtual_sensors,lfp_contacts);
            
            if contains(alignedto,'trig')
                save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors_trigaligned/chans_neighbors_LFP_',(subj),(current_condi),(event),'.mat'],'all_data');
            else
                save(['/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors/chans_neighbors_LFP_',(subj),(current_condi),(event),'.mat'],'all_data');
            end
        end
    end
end
