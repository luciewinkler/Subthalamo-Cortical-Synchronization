function montage =  rev_abbot_montage_wo_badchans(bad_chans)
%returns a montage for lfp channel rereferencing to be used by ft_preprocessing


% %standard montage for LFP-MEG measurements with medtronic Infinity system
% %assuming the following channel config:
lfp_labels = {
 'EEG001'; %R1   
 'EEG002'; %R2A 
 'EEG003'; %R2B
 'EEG004'; %R2C
 'EEG005'; %R3A
 'EEG006'; %R3B
 'EEG007'; %R3C
 'EEG008'; %R4
 'EEG033'; %L1
 'EEG034'; %L2A
 'EEG035'; %L2B
 'EEG036'; %L2C
 'EEG037'; %L3A
 'EEG038'; %L3B
 'EEG039'; %L3C
 'EEG040'; %L4
  };    

standard_inf.ref_scheme = {
    'EEG001','EEG002';
    'EEG001','EEG003'; %1-3
    'EEG001','EEG004';
    'EEG002','EEG005';
    'EEG003','EEG006';
    'EEG004','EEG007';
    'EEG005','EEG008';
    'EEG006','EEG008';
    'EEG007','EEG008';
    
    'EEG033','EEG034';
    'EEG033','EEG035';
    'EEG033','EEG036';
    'EEG034','EEG037';
    'EEG035','EEG038';
    'EEG036','EEG039';
    'EEG037','EEG040';
    'EEG038','EEG040';
    'EEG039','EEG040'};

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



