
%manually identify artifacts in tsss-cleaned data and LFPs. 
%Identify bad LFP channels and put in rev_info script 

path_data = '/data/project/hirsch/reverse/analysis/intermediate_data/data/tSSS/';
addpath '/data/project/hirsch/reverse/analysis/scripts/';
path_save = '/data/project/hirsch/reverse/analysis/Info/arfctdef/';

load /data/project/hirsch/reverse/analysis/Info/rev_info

%pick subject, condition and file
subj = 's04';
current_condi = 'pred';
k = 1;

%get field names from rev info structure
subjects = fieldnames(rev_info);

%file of interest
file = [path_data,subj,'_',current_condi,'_',num2str(k),'_tSSS.fif'];

%load data
cfg = [];
cfg.dataset = file;
data = ft_preprocessing(cfg);

%Downsample data
cfg = [];
cfg.resamplefs = 500;
data = ft_resampledata(cfg,data);

%first look at meg data
cfg = [];
cfg.channel = {'MEG***2','MEG***3'};
meg = ft_selectdata(cfg,data);

%apply hp filter
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 1;
cfg.hpfilttype = 'fir';
meg = ft_preprocessing(cfg,meg);

%select a fraction of meg channels to look at
meg_fraction = 10;
cfg = [];
cfg.channel = data.label(1:meg_fraction:end);
meg_sel = ft_selectdata(cfg,meg);

%mark artifacts in data browser
cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 10;
artifacts_tsss = ft_databrowser(cfg,meg_sel);

%save meg artifacts 
save([path_save,'artifacts_tsss_',subj,current_condi,num2str(k),'.mat'],'artifacts_tsss');

%get lfp data
cfg = [];
cfg.channel = 'EEG***';
lfp = ft_selectdata(cfg,data);

%mark artifacts and note bad channels in rev_info script
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 1;
cfg.hpfilttype = 'fir';
lfp = ft_preprocessing(cfg,lfp);

%mark artifacts in data browser
cfg = [];
cfg.channel = 'EEG***';
cfg.viewmode = 'vertical'; 
cfg.blocksize = 10; 
artifacts_eeg = ft_databrowser(cfg,lfp);

%save lfp artifacts
save([path_save,'artifacts_EEG_',subj,current_condi,num2str(k),'.mat'],'artifacts_eeg');
