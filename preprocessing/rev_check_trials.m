
%exclude trials with bad meg signal and bad dial signal (tremor) 
%to remain flexible and go back and forth, script is not in loop-format

alignedto = 'movaligned';

path_data = ['/data/project/hirsch/reverse/analysis/intermediate_data/data/data_all_clean_tsss/',(alignedto),'/trialed/'];
load /data/project/hirsch/reverse/analysis/Info/rev_info

%%%select
subj = 's23';
current_condi = 'pred';
event = 'start';

%%%%%%%%%%%%%%%

file_oi = [path_data,'clean_meg_mov_',(subj),(current_condi),num2str(1),(event)];
load(file_oi)

%here only check trials for meg data (redundant for LFP data because of
%contact selection)
cfg = [];
cfg.method = 'summary';
cfg.keepchannel = 'yes';
cfg.channel = 'MEG*';
cfg.keeptrial = 'yes';
ft_rejectvisual(cfg,rev_trials);

%if bad trial(s) and want to look at it seperately, plug trial number in here
cfg = [];
cfg.trials = [55];
rev_tr = ft_selectdata(cfg,rev_trials);

%and plot a fraction of channels in that trial to see if it is really bad
meg_fraction = 10;
cfg = [];
cfg.channel = rev_tr.label(1:meg_fraction:end);
meg_sel = ft_selectdata(cfg,rev_tr);
cfg = [];
cfg.channel = 'MEG*';
cfg.viewmode = 'vertical';
cfg.blocksize = 10;
ft_databrowser(cfg,meg_sel);

%select dial
cfg = [];
cfg.channel = 'MISC*';
dial = ft_selectdata(cfg,rev_trials); 

cfg = [];
cfg.method = 'trial'; 
cfg.keepchannel = 'yes';
cfg.keeptrial = 'yes';
ft_rejectvisual(cfg,dial);

%plug in all trials to delete
del_tr = [60];

%exclude them
trials_to_keep = [1:numel(rev_trials.trial)];
to_delete = ones(1,numel(rev_trials.trial));
to_delete(del_tr) = 0;
trials_to_keep = trials_to_keep(to_delete==1);

cfg = [];
cfg.trials = trials_to_keep;
rev_trials = ft_selectdata(cfg,rev_trials); 

%save the updated preprocessed file
save([path_data,'clean_meg_mov_',(subj),(current_condi),(event),'.mat'],'rev_trials');

