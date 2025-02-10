function montage =  rev_abbot_montage_wo_badchans(bad_chans)
%returns a montage for lfp channel rereferencing to be used by ft_preprocessing


% %standard montage for LFP-MEG measurements with Abbott Infinity system
% %assuming the following channel config:
lfp_labels = {
 'EEG001'; %R1   
 'EEG002'; %R2A 
 'EEG003'; %R3A
 'EEG004'; %R2B
 'EEG005'; %R4
 'EEG006'; %R3B
 'EEG007'; %R2C
 'EEG008'; %R3C
 'EEG033'; %L1
 'EEG034'; %L2A
 'EEG035'; %L3A
 'EEG036'; %L2B
 'EEG037'; %L4
 'EEG038'; %L3B
 'EEG039'; %L2C
 'EEG040'; %L3C
  };    

standard_inf.ref_scheme = {
    'EEG001','EEG002';
    'EEG001','EEG004'; %1-3
    'EEG001','EEG007';
    'EEG002','EEG003';
    'EEG004','EEG006';
    'EEG007','EEG008';
    'EEG003','EEG005';
    'EEG006','EEG005';
    'EEG008','EEG005';
    
    'EEG033','EEG034';
    'EEG033','EEG036';
    'EEG033','EEG039';
    'EEG034','EEG035';
    'EEG036','EEG038';
    'EEG039','EEG040';
    'EEG035','EEG037';
    'EEG038','EEG037';
    'EEG040','EEG037'};

standard_inf.new_lfp_labels = {
    'LFP-right-1-2A';
    'LFP-right-1-2B';
    'LFP-right-1-2C';
    'LFP-right-2A-3A';
    'LFP-right-2B-3B';
    'LFP-right-2C-3C';
    'LFP-right-3A-4';
    'LFP-right-3B-4';
    'LFP-right-3C-4';
        
    'LFP-left-1-2A';
    'LFP-left-1-2B';
    'LFP-left-1-2C';
    'LFP-left-2A-3A';
    'LFP-left-2B-3B';
    'LFP-left-2C-3C';
    'LFP-left-3A-4';
    'LFP-left-3B-4';
    'LFP-left-3C-4'};
 
good_inds = ~or(contains(standard_inf.ref_scheme(:,1),bad_chans),contains(standard_inf.ref_scheme(:,2),bad_chans));
ref_scheme = standard_inf.ref_scheme(good_inds,:);
new_labels = standard_inf.new_lfp_labels(good_inds);
montage = cl_create_lfp_montage(lfp_labels,ref_scheme,new_labels);



