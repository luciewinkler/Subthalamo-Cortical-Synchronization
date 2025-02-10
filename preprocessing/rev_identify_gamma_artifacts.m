
%for subject 23 artifacts in the gamma band were noted later on 
%this is to identify the trials that contain those artifacts 
%the script rev_timeresolved_coh_pow.m automatically has the information on
%those trials in there and rejects them 

%pick whether trigger-aligned or movement-aligned
alignedto = 'trigaligned';
%pick subject
i = 23; 
%pick condition
current_condi = 'pred'; 
%pick event
this_event = 'start';

%%%%%%%%
if contains(alignedto,'trig')
    datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors_trigaligned/';
else
    datadir = '/data/project/hirsch/reverse/analysis/intermediate_data/data/sources/lcmv_freq/chans/neighbors/';
end

load /data/project/hirsch/reverse/analysis/Info/rev_info
subjects = fieldnames(rev_info);
subj = subjects{i};
   
%load the data
file= [datadir,'chans_neighbors_LFP_',subj,current_condi,this_event,'beta.mat'];
load(file)

%pick the first 7 channels (these are the ones that were picked inititally
%rather than the neighboring channels 
cfg = [];
cfg.channel = all_data.label(1:7);
all_data = ft_selectdata(cfg,all_data);

%perform freq analysis and keep the individual trials
step_size = 0.05;
cfg = [];
cfg.method = 'mtmconvol';
cfg.tapsmofrq = 3;
cfg.otput = 'pow';
cfg.taper = 'dpss';
cfg.pad = 'nextpow2';
cfg.toi = all_data.time{1}(1)+0.5:step_size:all_data.time{1}(end)-0.5;
cfg.foi = 55:90;
cfg.t_ftimwin = 1*ones(1,length(cfg.foi));
cfg.keeptrials = 'yes';
freq = ft_freqanalysis(cfg,all_data);

%average over the channels 
cfg = [];
cfg.avgoverchan = 'yes';
freq = ft_selectdata(cfg,freq);
freq.label{1} = 'chan';

%baseline correction
cfg = [];
cfg.baseline = [-2 0];
cfg.baselinetype = 'absolute';
freq_bl = ft_freqbaseline(cfg,freq);
%numbers are very small 
freq_bl.powspctrm =  freq_bl.powspctrm*10000000000000000;

new_freq = freq_bl;
new_freq.powspctrm = squeeze(new_freq.powspctrm);

%go through the trials by clicking enter to check if any trials are bad 
for tr = 1:numel(all_data.trial)
    contourf(new_freq.time,new_freq.freq,squeeze(new_freq.powspctrm(tr,:,:)),200,'linecolor','none')
    a = colorbar;
    message = sprintf('this is trial number: %d', tr);
    disp(message)
    input('Press Enter to continue','s');
    pause
    close all
end
