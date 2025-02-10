
% contains information foreach subject: used hand, dial channel, chosen
% LFP contacts for contralateral and ipsilateral hemispheres, dbs system,
% bad channels, location of the data 

% Subject 1

rev_info.s01.dbs_system = 'abbot_infinity';
rev_info.s01.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-01/ses-01/meg/200207/';
rev_info.s01.used_hand = 'right';
rev_info.s01.dial_channel = 'MISC013';
% contact selection with beta 
rev_info.s01.bestcontact_contra = 'LFP-left-1-2A';
rev_info.s01.bestcontact_ipsi ='LFP-right-2B-3B';
% contact selection with gamma 
% rev_info.s01.bestcontact_contra = 'LFP-left-2C-3C';
% rev_info.s01.bestcontact_ipsi = 'LFP-right-1-2C';

rev_info.s01.data = 1;

rev_info.s01.pred(1).file = 's01_predictable.fif';
rev_info.s01.pred(1).bad_meg = {'-MEG0413','-MEG0143','-MEG1532','-MEG1523','-MEG1712','-MEG1742','-MEG1233','-MEG1743','-MEG1333','-MEG1713','-MEG1933','-MEG2612','-MEG1533','-MEG2313','-MEG2613','-MEG0522','-MEG0732','-MEG0133','-MEG2642','-MEG1423','-MEG0113','-MEG2542','-MEG2512','-MEG0313'};
rev_info.s01.pred(1).bad_lfp = {'EEG003','EEG036','EEG037'}; %{'EEG003'}%,'EEG036','EEG037','EEG038','EEG039','EEG040'};

rev_info.s01.unpred(1).file = 's01_unpredictable.fif';
rev_info.s01.unpred(1).bad_meg = {'-MEG1532','-MEG1713','-MEG1742','-MEG1233','-MEG1743','-MEG1333','-MEG1933','-MEG2612','-MEG2313','-MEG0443','-MEG0522','-MEG0732','-MEG1523','-MEG2613','-MEG1413','-MEG2023','-MEG2412','-MEG2642','-MEG2412','-MEG2542','-MEG0132','-MEG2412','-MEG2512','-MEG1712','-MEG0822'};
rev_info.s01.unpred(1).bad_lfp = {'EEG003','EEG008','EEG037'};%{'EEG003'}%,'EEG036','EEG037','EEG038','EEG039','EEG040'};

% Very messy rest file (MEG, lfp)
rev_info.s01.rest(1).file = 's01_rest.fif';
rev_info.s01.rest(1).bad_meg = {'-MEG1523','-MEG1743','-MEG1233','-MEG1333','-MEG2612','-MEG2313','-MEG0443','-MEG0522','-MEG0732','-MEG2512','-MEG2542','-MEG2613','-MEG0132','-MEG0822'};
rev_info.s01.rest(1).bad_lfp = {'EEG003','EEG008','EEG037'};%{'EEG004'}%,'EEG003','EEG036','EEG037','EEG038','EEG039','EEG040','EEG035'};


% Subject 2 

rev_info.s02.dbs_system = 'abbot_infinity';
rev_info.s02.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-02/ses-01/meg/200514/';
rev_info.s02.used_hand = 'right';
rev_info.s02.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s02.bestcontact_contra = 'LFP-left-2B-3B';
rev_info.s02.bestcontact_ipsi = 'LFP-right-1-2B';
% contact selection with gamma 
% rev_info.s02.bestcontact_contra = 'LFP-left-2A-3A';
% rev_info.s02.bestcontact_ipsi = 'LFP-right-1-2C';
%trials to exclude: pred rev: 35

rev_info.s02.data = 1;

rev_info.s02.pred(1).file = 'rev02_predicatble.fif';
rev_info.s02.pred(1).bad_meg = {'-MEG1642','-MEG2542','-MEG2032','-MEG2513','-MEG1713','-MEG1933','-MEG0313','-MEG0112','-MEG0622','-MEG0732','-MEG1523','-MEG0222','-MEG0132','-MEG1233'};
rev_info.s02.pred(1).bad_lfp = {'EEG003','EEG033','EEG008'};

rev_info.s02.unpred(1).file = 'rev02_unpred.fif';
rev_info.s02.unpred(1).bad_meg = {'-MEG1642','-MEG2542','-MEG2032','-MEG2513','-MEG1713','-MEG1933','-MEG1823','-MEG0222','-MEG0313','-MEG0112','-MEG0732','-MEG1523','-MEG0132','-MEG0223','-MEG1543','-MEG1233','-MEG2613','-MEG0622','-MEG0323'};
rev_info.s02.unpred(1).bad_lfp = {'EEG003','EEG033','EEG008'};

rev_info.s02.rest(1).file = 'rev02_rest.fif';
rev_info.s02.rest(1).bad_meg = {'-MEG1642','-MEG2542','-MEG2032','-MEG2513','-MEG1933','-MEG1823','-MEG0222','-MEG0313','-MEG0323','-MEG1523','-MEG0732','-MEG0923','-MEG0922','-MEG0921','-MEG0132','-MEG112'};
rev_info.s02.rest(1).bad_lfp = {'EEG003','EEG033','EEG008'};

% Subject 3

rev_info.s03.dbs_system = 'abbot_infinity';
rev_info.s03.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-03/ses-01/meg/200521/';
rev_info.s03.used_hand = 'right';
rev_info.s03.dial_channel = 'MISC013';
rev_info.s03.data = 0;

rev_info.s03.rest(1).file = 'S03_rest.fif';
rev_info.s03.rest(1).bad_meg = {'-MEG1113','-MEG0332','-MEG1143','-MEG2513','-MEG2033','-MEG1823','-MEG0443','-MEG0223','-MEG1523','-MEG0732','-MEG2032'};
rev_info.s03.rest(1).bad_lfp = {'EEG033','EEG008'};

% Subject 4 

rev_info.s04.dbs_system = 'abbot_infinity';
rev_info.s04.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-04/ses-01/meg/200528/';
rev_info.s04.used_hand = 'right';
rev_info.s04.dial_channel = 'MISC016';
% contact selection with beta
rev_info.s04.bestcontact_contra = 'LFP-left-3B-4';
rev_info.s04.bestcontact_ipsi = 'LFP-right-3B-4';
% contact selection with gamma 
% rev_info.s04.bestcontact_contra = 'LFP-left-2B-3B';
% rev_info.s04.bestcontact_ipsi = 'LFP-right-3A-4';
rev_info.s04.data = 1;

rev_info.s04.pred(1).file = 'rev04_pred1.fif';
rev_info.s04.pred(1).bad_meg = {'-MEG1222','-MEG1232','-MEG2213','-MEG1542','-MEG2233','-MEG1523','-MEG1933','-MEG1212','-MEG1233','-MEG1333','-MEG0732','-MEG1113'};
rev_info.s04.pred(1).bad_lfp = {'EEG033','EEG008'};

rev_info.s04.pred(2).file = 'rev04_pred2.fif';
rev_info.s04.pred(2).bad_meg = {'-MEG2213','-MEG1523','-MEG1113','-MEG1933','-MEG1933','-MEG1212','-MEG1233','-MEG1333','-MEG0732','-MEG1222','-MEG2233'};
rev_info.s04.pred(2).bad_lfp = {'EEG033','EEG008'};

rev_info.s04.unpred(1).file = 'rev04_unpred1.fif';
rev_info.s04.unpred(1).bad_meg = {'-MEG2213','-MEG1523','-MEG1622','-MEG1933','-MEG1233','-MEG2233','-MEG0732','-MEG1333','-MEG1113'};
rev_info.s04.unpred(1).bad_lfp = {'EEG033','EEG008'};

rev_info.s04.unpred(2).file = 'rev04_unpred2.fif';
rev_info.s04.unpred(2).bad_meg = {'-MEG2042','-MEG2213','-MEG1523','-MEG1113','-MEG1933','-MEG1233','-MEG2233','-MEG0732','-MEG1333'};
rev_info.s04.unpred(2).bad_lfp = {'EEG033','EEG008'};

rev_info.s04.rest(1).file = 'rev04_rest.fif';
rev_info.s04.rest(1).bad_meg = {'-MEG2122','-MEG0533','-MEG0822','-MEG0342','-MEG1523','-MEG1622','-MEG1933','-MEG1233','-MEG1333','-MEG0732','-MEG2233','-MEG1823','-MEG2213'};
rev_info.s04.rest(1).bad_lfp = {'EEG033','EEG008','EEG004','EEG040'};


% Subject 5 

rev_info.s05.dbs_system = 'abbot_infinity';
rev_info.s05.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-05/ses-01/meg/200604/';
rev_info.s05.used_hand = 'left';
rev_info.s05.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s05.bestcontact_contra = 'LFP-right-3B-4';
rev_info.s05.bestcontact_ipsi = 'LFP-left-1-2B';
% contact selection with gamma 
% rev_info.s05.bestcontact_contra = 'LFP-right-1-2B';
% rev_info.s05.bestcontact_ipsi = 'LFP-left-1-2C';
%trials to exclude: unpred stop: 14

rev_info.s05.data = 1;

rev_info.s05.pred(1).file = 'revs05_pred1.fif'; 
rev_info.s05.pred(1).bad_meg = {'-MEG1523','-MEG0223','-MEG1823','-MEG0443','-MEG1113','-MEG2213','-MEG0732','-MEG1933','-MEG1233'};
rev_info.s05.pred(1).bad_lfp = {'EEG003','EEG008'}; 

rev_info.s05.pred(2).file = 'revs05_pred2.fif';
rev_info.s05.pred(2).bad_meg = {'-MEG1222','-MEG1523','-MEG0223','-MEG0443','-MEG0732','-MEG1933','-MEG1233','-MEG2213'};
rev_info.s05.pred(2).bad_lfp = {'EEG008'};

rev_info.s05.unpred(1).file = 'revs05_unpred1.fif'; 
rev_info.s05.unpred(1).bad_meg = {'-MEG1523','-MEG0223','-MEG0443''-MEG1823','-MEG1113','-MEG1143','-MEG2213','-MEG0732','-MEG1933','-MEG1233','-MEG0422'};
rev_info.s05.unpred(1).bad_lfp = {'EEG003','EEG008'};

rev_info.s05.unpred(2).file = 'revs05_unpred2.fif';
rev_info.s05.unpred(2).bad_meg = {'-MEG1523','-MEG0223','-MEG1823','-MEG0443','-MEG1113','-MEG1143','-MEG2213','-MEG0732','-MEG1933','-MEG1233'};
rev_info.s05.unpred(2).bad_lfp = {'EEG003','EEG008'};

rev_info.s05.rest(1).file = 'revs05_rest.fif';
rev_info.s05.rest(1).bad_meg = {'-MEG1523','-MEG0223','-MEG0443','-MEG1823','-MEG1113','-MEG1143','-MEG2213','-MEG0732','-MEG1933','-MEG1233','-MEG1032'};
rev_info.s05.rest(1).bad_lfp = {'EEG003','EEG008'};


% Subject 6 
% rauschen in linken lfps

rev_info.s06.dbs_system = 'abbot_infinity';
rev_info.s06.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-06/ses-01/meg/200716/';
rev_info.s06.used_hand = 'right';
rev_info.s06.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s06.bestcontact_contra = 'LFP-left-3A-4';
rev_info.s06.bestcontact_ipsi = 'LFP-right-3C-4';
% contact selection with gamma 
% rev_info.s06.bestcontact_contra = 'LFP-left-2A-3A';
% rev_info.s06.bestcontact_ipsi = 'LFP-right-1-2B';
%trials to exclude: unpred start: 6

rev_info.s06.data = 1;

rev_info.s06.pred(1).file = 'S_06_predictable_2.fif';
rev_info.s06.pred(1).bad_meg = {'-MEG2132','-MEG0212','-MEG0822','-MEG0613','-MEG2412','-MEG2443','-MEG0413','-MEG2513','-MEG2542','-MEG0812'};
rev_info.s06.pred(1).bad_lfp = {'EEG033'};

rev_info.s06.unpred(1).file = 'S_06_unpred_1.fif';
rev_info.s06.unpred(1).bad_meg = {'-MEG2513','-MEG2132','-MEG0212','-MEG0822','-MEG0613','-MEG2412','-MEG2443','-MEG2433','-MEG0413','-MEG2542','-MEG0812'};
rev_info.s06.unpred(1).bad_lfp = {'EEG033'};

rev_info.s06.rest(1).file = 's06_rest.fif';
rev_info.s06.rest(1).bad_meg = {'-MEG2513','-MEG2132','-MEG0212','-MEG0822','-MEG0613','-MEG0812','-MEG2542'};
rev_info.s06.rest(1).bad_lfp = {'EEG033'};


% subject 7

rev_info.s07.dbs_system = 'abbot_infinity';
rev_info.s07.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-07/ses-01/meg/200723/';
rev_info.s07.used_hand = 'right';
rev_info.s07.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s07.bestcontact_contra = 'LFP-left-3C-4';
rev_info.s07.bestcontact_ipsi = 'LFP-right-1-2A';
% contact selection with gamma 
% rev_info.s07.bestcontact_contra = 'LFP-left-3A-4';
% rev_info.s07.bestcontact_ipsi = 'LFP-right-1-2A';
%trials to exclude: pred rev: 58, unpred rev: 30

rev_info.s07.data = 1;

rev_info.s07.pred(1).file = 's07_pred1.fif';
rev_info.s07.pred(1).bad_meg = {'-MEG2412','-MEG0212','-MEG1432','-MEG2622','-MEG2623','-MEG2633','-MEG2443','-MEG2433','-MEG2132','-MEG0822','-MEG2542','-MEG0613'};
rev_info.s07.pred(1).bad_lfp = {'EEG008','EEG007','EEG006','EEG033','EEG034'};

rev_info.s07.pred(2).file = 's07_pred2.fif';
rev_info.s07.pred(2).bad_meg = {'-MEG2412','-MEG0212','-MEG1432','-MEG2622','-MEG2623','-MEG2633','-MEG2443','-MEG2433','-MEG2132','-MEG0822','-MEG1123','-MEG1022','-MEG0812','-MEG2542'};
rev_info.s07.pred(2).bad_lfp = {'EEG003','EEG008','EEG007','EEG033','EEG034'};

rev_info.s07.unpred(1).file = 's07_unpred1.fif';
rev_info.s07.unpred(1).bad_meg = {'-MEG2412','-MEG0613','-MEG0212','-MEG2132','-MEG2523','-MEG2623','-MEG0822','-MEG0822'};
rev_info.s07.unpred(1).bad_lfp = {'EEG008','EEG007','EEG006','EEG033','EEG034'};

rev_info.s07.unpred(2).file = 's07_unpred2.fif';
rev_info.s07.unpred(2).bad_meg = {'-MEG2412','-MEG0212','-MEG1432','-MEG2622','-MEG2623','-MEG2433','-MEG2443','-MEG1123','-MEG2132','-MEG0822','-MEG1113','-MEG2542'};
rev_info.s07.unpred(2).bad_lfp = {'EEG003','EEG008','EEG007','EEG033','EEG034'};

rev_info.s07.rest(1).file = 's07_rest1.fif';
rev_info.s07.rest(1).bad_meg = {'-MEG1333','-MEG0212'};
rev_info.s07.rest(1).bad_lfp = {'EEG006','EEG008','EEG007','EEG033','EEG034'};

% Subject 8 

rev_info.s08.dbs_system = 'abbot_infinity';
rev_info.s08.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-08/ses-01/meg/200724/';
rev_info.s08.used_hand = 'right';
rev_info.s08.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s08.bestcontact_contra = 'LFP-left-3A-4';
rev_info.s08.bestcontact_ipsi = 'LFP-right-3A-4';
% contact selection with gamma 
% rev_info.s08.bestcontact_contra = 'LFP-left-3C-4';
% rev_info.s08.bestcontact_ipsi = 'LFP-right-3A-4';
rev_info.s08.data = 1;

rev_info.s08.pred(1).file = 's08_pred1.fif';
rev_info.s08.pred(1).bad_meg = {'-MEG1333','-MEG0212','-MEG1522','-MEG1512','-MEG1523','-MEG0132','-MEG0133','-MEG2622','-MEG2132','-MEG0822','-MEG1723','-MEG1722'};
%rev_info.s08.pred(1).bad_meg = {'-MEG0122','-MEG0113','-MEG0142','-MEG1043','-MEG1542','-MEG1522','-MEG1533','-MEG1543','-MEG1423','-MEG1433','-MEG1333','-MEG2622','-MEG2623','-MEG2633','-MEG2512','-MEG2323','-MEG2133','-MEG2543','-MEG2533','-MEG1213','-MEG0932','-MEG0343','-MEG0542','-MEG0313','-MEG0122','-MEG0123','-MEG0713','-MEG1822','-MEG0422','-MEG0412','-MEG0413','-MEG0432','-MEG0442','-MEG1422','-MEG1042','-MEG1043','-MEG1143','-MEG1142','-MEG0632','-MEG0633','-MEG1733','-MEG1723','-MEG1722','-MEG1713','-MEG1933','-MEG1932','-MEG2142','-MEG1742','-MEG1743','-MEG1712'};
rev_info.s08.pred(1).bad_lfp = {'EEG008','EEG034'};

rev_info.s08.pred(2).file = 's08_pred2.fif';
rev_info.s08.pred(2).bad_meg = {'-MEG1333','-MEG0212','-MEG1522','-MEG1512','-MEG1523','-MEG0123','-MEG2622','-MEG2132','-MEG0822','-MEG1723','-MEG1722','-MEG1413'};
rev_info.s08.pred(2).bad_lfp = {'EEG008','EEG034'};

rev_info.s08.unpred(1).file = 's08_unpred1.fif';
rev_info.s08.unpred(1).bad_meg = {'-MEG1333','-MEG0212','-MEG1522','-MEG1512','-MEG1523','-MEG0123','-MEG2622','-MEG1413','-MEG0822','-MEG1723','-MEG1722','-MEG1532','-MEG1533','-MEG2523','-MEG2522'};
rev_info.s08.unpred(1).bad_lfp = {'EEG008','EEG034'};

rev_info.s08.unpred(2).file = 's08_unpred2.fif';
rev_info.s08.unpred(2).bad_meg = {'-MEG1333','-MEG0212','-MEG1522','-MEG1512','-MEG1542','-MEG0123','-MEG2622','-MEG1413','-MEG0822','-MEG2132'};
rev_info.s08.unpred(2).bad_lfp = {'EEG008','EEG034'};
    
rev_info.s08.rest(1).file = 's08_rest.fif';
rev_info.s08.rest(1).bad_meg = {'-MEG1333','-MEG0212','-MEG1532','-MEG1523','-MEG0123','-MEG0822'};
rev_info.s08.rest(1).bad_lfp = {'EEG008','EEG034'};

% Subject 9

rev_info.s09.dbs_system = 'abbot_infinity';
rev_info.s09.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-09/201105/';
rev_info.s09.used_hand = 'left';
rev_info.s09.dial_channel = 'MISC016';
rev_info.s09.bestcontact_contra = 'LFP-right-3B-4';
% has no good ipsilateral contact 
rev_info.s09.data = 0;

rev_info.s09.pred(1).file = 'ms_rotate_regular_02.fif';
rev_info.s09.pred(1).bad_meg = {'-MEG0212','-MEG0132','-MEG2222','-MEG1113','-MEG0822','-MEG1823','-MEG1743','-MEG0513','-MEG0812','-MEG2132'};
rev_info.s09.pred(1).bad_lfp = {'EEG008','EEG033','EEG034'};

rev_info.s09.unpred(1).file = 'ms_unpred1.fif';
rev_info.s09.unpred(1).bad_meg = {'-MEG1423','-MEG2443','-MEG0212','-MEG0132','-MEG2222','-MEG0822','-MEG1823','-MEG1743','-MEG0513','-MEG0812','-MEG2132','-MEG1523','-MEG0613','-MEG2113','-MEG2542'};
rev_info.s09.unpred(1).bad_lfp = {'EEG008','EEG033','EEG034'};

rev_info.s09.rest(1).file = 'ms_rest_eo.fif';
rev_info.s09.rest(1).bad_meg = {'MEG2542','MEG2623','-MEG0212','-MEG0132','-MEG2222','-MEG0422','-MEG0822','-MEG1823','-MEG1743','-MEG0513','-MEG0812','-MEG2132','-MEG0613'};
rev_info.s09.rest(1).bad_lfp = {'EEG008','EEG033','EEG034'};

%10
rev_info.s10.dbs_system = 'abbot_infinity';
rev_info.s10.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-10/ses-01/meg/210812/';
rev_info.s10.used_hand = 'left';
rev_info.s10.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s10.bestcontact_contra = 'LFP-right-3A-4';
rev_info.s10.bestcontact_ipsi = 'LFP-left-3C-4';
% contact selection with gamma 
% rev_info.s10.bestcontact_contra = 'LFP-right-3A-4';
% rev_info.s10.bestcontact_ipsi = 'LFP-left-3B-4';
%trials to exclude: pred start: 8, unpred rev 45,37

rev_info.s10.data = 1;

rev_info.s10.pred(1).file = 's010_predictable1.fif';
rev_info.s10.pred(1).bad_meg = {'-MEG1633','-MEG0822','MEG2633','-MEG2412','-MEG1412'};
rev_info.s10.pred(1).bad_lfp = {'EEG008','EEG034'};

rev_info.s10.pred(2).file = 'S010_pred2.fif';
rev_info.s10.pred(2).bad_meg = {'-MEG0822','-MEG1443','MEG2633','-MEG2412'};
rev_info.s10.pred(2).bad_lfp = {'EEG008','EEG034'};

rev_info.s10.unpred(1).file = 'S010_unpred1.fif';
rev_info.s10.unpred(1).bad_meg = {'-MEG1533','MEG2633','-MEG1443','-MEG0413','-MEG0822','-MEG1113','-MEG2412','-MEG2522'};
rev_info.s10.unpred(1).bad_lfp = {'EEG008','EEG034'};

rev_info.s10.unpred(2).file = 'S010_unpred2.fif';
rev_info.s10.unpred(2).bad_meg = {'-MEG0822','MEG2633','-MEG0913','-MEG1412'};
rev_info.s10.unpred(2).bad_lfp = {'EEG008','EEG034'};

rev_info.s10.rest(1).file = 'S010_rest.fif';
rev_info.s10.rest(1).bad_meg = {'-MEG0822','MEG2633','-MEG1443','-MEG1533','-MEG1443'};
rev_info.s10.rest(1).bad_lfp = {'EEG008','EEG034'};

%11
rev_info.s11.dbs_system = 'abbot_infinity';
rev_info.s11.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-11/ses-01/meg/211007/';
rev_info.s11.used_hand = 'left';
rev_info.s11.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s11.bestcontact_contra = 'LFP-right-2A-3A';
rev_info.s11.bestcontact_ipsi = 'LFP-left-3B-4';
% contact selection with gamma 
% rev_info.s11.bestcontact_contra = 'LFP-right-2A-3A';
% rev_info.s11.bestcontact_ipsi = 'LFP-left-2C-3C';
%trials to exclude: unpred rev: 12, unpred stop 51

rev_info.s11.data = 1;

rev_info.s11.pred(1).file = 's11_pred1.fif';
rev_info.s11.pred(1).bad_meg = {'-MEG0822','-MEG2642','-MEG2242','-MEG1012','-MEG2412','-MEG2413'};
rev_info.s11.pred(1).bad_lfp = {'EEG008','EEG033','EEG034','EEG004'};

rev_info.s11.pred(2).file = 's11_pred2.fif';
rev_info.s11.pred(2).bad_meg = {'-MEG0822','-MEG0913','-MEG1612','-MEG2642','-MEG2412','-MEG2413','-MEG1012'};
rev_info.s11.pred(2).bad_lfp = {'EEG008','EEG033','EEG034','EEG004'};

rev_info.s11.unpred(1).file = 's11_unpred1.fif';
rev_info.s11.unpred(1).bad_meg = {'-MEG1612','-MEG2642','-MEG2412','-MEG2413','-MEG2143','-MEG2132','-MEG0822','-MEG0612'};
rev_info.s11.unpred(1).bad_lfp = {'EEG008','EEG033','EEG034','EEG004'};

rev_info.s11.unpred(2).file = 's11_unpred2.fif';
rev_info.s11.unpred(2).bad_meg = {'-MEG2642','-MEG0443','-MEG2412','-MEG2413','-MEG2132','-MEG0612','-MEG0822'};
rev_info.s11.unpred(2).bad_lfp = {'EEG008','EEG033','EEG004','EEG034'};

rev_info.s11.rest(1).file = 's11_rest.fif';
rev_info.s11.rest(1).bad_meg = {'-MEG0143','-MEG1513','-MEG1522','-MEG2642','-MEG1443','-MEG1423','-MEG0822'};
rev_info.s11.rest(1).bad_lfp = {'EEG008','EEG034','EEG033','EEG004'};


%12 %%%noisy meg data vor allem preds;weird during start(beta doesnt
%decrease)
rev_info.s12.dbs_system = 'medtronic';
rev_info.s12.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-12/211014/';
rev_info.s12.used_hand = 'right'; %????
rev_info.s12.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s12.bestcontact_contra = 'LFP-left-2C-3C';
rev_info.s12.bestcontact_ipsi = 'LFP-right-1-2A';
% contact selection with gamma 
% rev_info.s12.bestcontact_contra = 'LFP-left-2A-3A';
% rev_info.s12.bestcontact_ipsi = 'LFP-right-3B-4';

rev_info.s12.data = 1;

rev_info.s12.pred(1).file = 's12_pred1.fif'; %%%3 chans that are still bad after tsss
rev_info.s12.pred(1).bad_meg = {'-MEG0443','-MEG1633','-MEG0822','-MEG1823','-MEG0222','-MEG0113','-MEG1023','-MEG0613'};
rev_info.s12.pred(1).bad_lfp = {};%none but some are weird 

rev_info.s12.pred(2).file = 's12_pred2.fif';
rev_info.s12.pred(2).bad_meg = {'-MEG0443','-MEG0822','-MEG1823','-MEG1633'};
rev_info.s12.pred(2).bad_lfp = {};%none but some are weird 

rev_info.s12.unpred(1).file = 's12_unpred1.fif';
rev_info.s12.unpred(1).bad_meg = {'-MEG1633','-MEG0822','-MEG1823'};
rev_info.s12.unpred(1).bad_lfp = {};%none but some are weird 

rev_info.s12.unpred(2).file = 's12_unpred2.fif';
rev_info.s12.unpred(2).bad_meg = {'-MEG0822','-MEG1633'};
rev_info.s12.unpred(2).bad_lfp = {};%none but some are weird 

rev_info.s12.rest(1).file = 's12_rest.fif';
rev_info.s12.rest(1).bad_meg = {'-MEG0443','-MEG1823','-MEG1633','-MEG1333','-MEG2222','-MEG0822','-MEG1233'};
rev_info.s12.rest(1).bad_lfp = {}; %none but some are weird 

%13 
% line noise (in LFP)
% cut out first second or so from meg 
rev_info.s13.dbs_system = 'abbot_infinity';
rev_info.s13.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-13/211111/';
rev_info.s13.used_hand = 'left'; %????
rev_info.s13.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s13.bestcontact_contra = 'LFP-right-2C-3C';
rev_info.s13.bestcontact_ipsi = 'LFP-left-1-2C';
% contact selection with gamma 
% rev_info.s13.bestcontact_contra = 'LFP-right-2C-3C';
% rev_info.s13.bestcontact_ipsi = 'LFP-left-3B-4';

rev_info.s13.data = 1;

rev_info.s13.pred(1).file = 's13_predictable1.fif';
rev_info.s13.pred(1).bad_meg = {'-MEG2612','-MEG0822','-MEG0412'};
rev_info.s13.pred(1).bad_lfp = {'EEG001','EEG002','EEG004','EEG040'};

rev_info.s13.pred(2).file = 's13_predictable2.fif';
rev_info.s13.pred(2).bad_meg = {'-MEG2612','-MEG0822','-MEG0412'};
rev_info.s13.pred(2).bad_lfp = {'EEG001','EEG002','EEG040'};

rev_info.s13.unpred(1).file = 's13_unpredictable1.fif';
rev_info.s13.unpred(1).bad_meg = {'MEG0613','-MEG1223','-MEG2612','-MEG0412','-MEG0822'}; %%%%%% rerun tsss
rev_info.s13.unpred(1).bad_lfp = {'EEG001','EEG002','EEG004','EEG040'};

rev_info.s13.unpred(2).file = 's13_unpredictable2.fif';
rev_info.s13.unpred(2).bad_meg = {'-MEG0412','-MEG2612','-MEG0822'};
rev_info.s13.unpred(2).bad_lfp = {'EEG001','EEG002','EEG004','EEG040'};

rev_info.s13.rest(1).file = 's13_rest.fif';
rev_info.s13.rest(1).bad_meg = {'-MEG2612','-MEG0822','-MEG1643'};
rev_info.s13.rest(1).bad_lfp = {'EEG001','EEG002','EEG004','EEG040'};

%14
rev_info.s14.dbs_system = 'abbot_infinity';
rev_info.s14.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-14/211204/';
rev_info.s14.used_hand = 'left'; %????
rev_info.s14.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s14.bestcontact_contra = 'LFP-right-3B-4';
rev_info.s14.bestcontact_ipsi = 'LFP-left-3C-4';
% contact selection with gamma 
% rev_info.s14.bestcontact_contra = 'LFP-right-2C-3C';
% rev_info.s14.bestcontact_ipsi = 'LFP-left-1-2A';
rev_info.s14.data = 1;

rev_info.s14.pred(1).file = 's14_predictable1.fif';
rev_info.s14.pred(1).bad_meg = {'-MEG2633','-MEG1633','-MEG0822'};
rev_info.s14.pred(1).bad_lfp = {'EEG036'};

rev_info.s14.pred(2).file = 's14_predictable2.fif';
rev_info.s14.pred(2).bad_meg = {'-MEG2633','-MEG0822'};
rev_info.s14.pred(2).bad_lfp = {'EEG036'};

rev_info.s14.unpred(1).file = 's14_unpredictable1.fif';
rev_info.s14.unpred(1).bad_meg = {'-MEG2633','-MEG0822'};
rev_info.s14.unpred(1).bad_lfp = {'EEG036'};

rev_info.s14.unpred(2).file = 's14_unpredictable2.fif';
rev_info.s14.unpred(2).bad_meg = {'-MEG0822','-MEG2633'};
rev_info.s14.unpred(2).bad_lfp = {'EEG036'};

rev_info.s14.rest(1).file = 's14_rest.fif';
rev_info.s14.rest(1).bad_meg = {'-MEG2633','-MEG0822','-MEG1823'};
rev_info.s14.rest(1).bad_lfp = {'EEG036'}; 

%15 
% LFP data katastrophic; 
% heart beat everywhere
% MEG has insane spikes all over (didnt mark as artifacts, or else
% nothing left)
rev_info.s15.dbs_system = 'abbot_infinity';
rev_info.s15.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-15/220127/';
rev_info.s15.used_hand = 'right'; 
rev_info.s15.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s15.bestcontact_contra = 'LFP-left-3C-4';
rev_info.s15.bestcontact_ipsi = 'LFP-right-3C-4';
% contact selection with gamma 
% rev_info.s15.bestcontact_contra = 'LFP-left-1-2B';
% rev_info.s15.bestcontact_ipsi = 'LFP-right-3A-4';
rev_info.s15.data = 0;

rev_info.s15.pred(1).file = 's15_pred1.fif';
rev_info.s15.pred(1).bad_meg = {'-MEG1333','-MEG0443','-MEG1133','-MEG1643','-MEG0822','-MEG1412','-MEG2122','-MEG1423', '-MEG1433', '-MEG2642', '-MEG2623', '-MEG2633', '-MEG1442', '-MEG0113', '-MEG0143', '-MEG1543', '-MEG1533', '-MEG0132', '-MEG1532', '-MEG1425', '-MEG1712', '-MEG1713', '-MEG2142', '-MEG1742', '-MEG1743'};
rev_info.s15.pred(1).bad_lfp =  {};

rev_info.s15.pred(2).file = 's15_pred2.fif';
rev_info.s15.pred(2).bad_meg = {'-MEG1333','-MEG0413','-MEG0822','-MEG0113','-MEG0143','-MEG1543','-MEG1532','-MEG1533','-MEG0132','-MEG1433','-MEG1423','-MEG2623','-MEG2142','-MEG1742','-MEG1743','-MEG1712','-MEG1713','-MEG1412','-MEG1633'};
rev_info.s15.pred(2).bad_lfp = {};

rev_info.s15.unpred(1).file = 's15_unpred1.fif';
rev_info.s15.unpred(1).bad_meg = {'-MEG1333','-MEG0413','-MEG0822','-MEG1333','-MEG0413','-MEG0822','-MEG0113','-MEG0143','-MEG1543','-MEG1532','-MEG1533','-MEG0132','-MEG1433','-MEG1423','-MEG2623','-MEG2142','-MEG1742','-MEG1743','-MEG1712','-MEG1713','-MEG1412','-MEG1633'};
rev_info.s15.unpred(1).bad_lfp = {};

rev_info.s15.unpred(2).file = 's15_unpred2.fif';
rev_info.s15.unpred(2).bad_meg = {'-MEG1333','-MEG0413','-MEG0822','-MEG1333','-MEG0413','-MEG0822','-MEG0113','-MEG0143','-MEG1543','-MEG1532','-MEG1533','-MEG0132','-MEG1433','-MEG1423','-MEG2623','-MEG2142','-MEG1742','-MEG1743','-MEG1712','-MEG1713','-MEG1412','-MEG1633'};
rev_info.s15.unpred(2).bad_lfp = {};

rev_info.s15.rest(1).file = 's15_rest.fif';
rev_info.s15.rest(1).bad_meg = {'-MEG1333','-MEG0413','-MEG0822','-MEG1333','-MEG0413','-MEG0822','-MEG0113','-MEG0143','-MEG1543','-MEG1532','-MEG1533','-MEG0132','-MEG1433','-MEG1423','-MEG2623','-MEG2142','-MEG1742','-MEG1743','-MEG1712','-MEG1713','-MEG1412','-MEG1633'};
rev_info.s15.rest(1).bad_lfp = {}; 

%16
rev_info.s16.dbs_system = 'abbot_infinity';
rev_info.s16.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-16/220203/';
rev_info.s16.used_hand = 'left'; %????
rev_info.s16.dial_channel = 'MISC016';
% rev_info.s16.bestcontact_contra = '';
% rev_info.s16.bestcontact_ipsi = '';
rev_info.s16.data = 0;

rev_info.s16.rest(1).file = 's16_rest.fif';
rev_info.s16.rest(1).bad_meg = {'-MEG1633','-MEG0822'};
rev_info.s16.rest(1).bad_lfp = {'EEG008','EEG033'};

rev_info.s16.rest(2).file = 's16_rest2.fif';
rev_info.s16.rest(2).bad_meg = {'-MEG1633','-MEG0822','-MEG0413'};
rev_info.s16.rest(2).bad_lfp = {'EEG008','EEG033'};

%17
%left 2a-3a und left 2b-3b auch schlecht (left 3a-4,3b-4)
rev_info.s17.dbs_system = 'abbot_infinity';
rev_info.s17.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-17/220210/';
rev_info.s17.used_hand = 'left';
rev_info.s17.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s17.bestcontact_contra = 'LFP-right-2B-3B';
rev_info.s17.bestcontact_ipsi = 'LFP-left-2C-3C';
% contact selection with gamma 
% rev_info.s17.bestcontact_contra = 'LFP-left-2A-3A';
% rev_info.s17.bestcontact_ipsi = 'LFP-right-2A-3A';
rev_info.s17.data = 1;

rev_info.s17.rest(1).file = 'rest_s17.fif';
rev_info.s17.rest(1).bad_meg = {'-MEG1533','-MEG0443','-MEG1633','-MEG1113','-MEG2133','-MEG0822'};
rev_info.s17.rest(1).bad_lfp = {'EEG008','EEG033'};

%turns with left hand 
rev_info.s17.pred(1).file = 's17_pred1part1.fif';
rev_info.s17.pred(1).bad_meg = {'-MEG1622','-MEG0443','-MEG1633','-MEG0822'};
rev_info.s17.pred(1).bad_lfp = {'EEG008','EEG033'};

%turns with left hand 
rev_info.s17.pred(2).file = 's17_pred1_part2.fif';
rev_info.s17.pred(2).bad_meg = {'-MEG1622','-MEG0443','-MEG1633','-MEG0822','-MEG0722'};
rev_info.s17.pred(2).bad_lfp = {'EEG008','EEG033'};

%changes hand somewhere here
rev_info.s17.pred(3).file = 's17_predictable2.fif';
rev_info.s17.pred(3).bad_meg = {'-MEG0443','-MEG1633','-MEG0822'};
rev_info.s17.pred(3).bad_lfp = {'EEG008','EEG033'};

%turns with right hand 
rev_info.s17.unpred(1).file = 's17_unpred1.fif';
rev_info.s17.unpred(1).bad_meg = {'-MEG0443','-MEG1633','-MEG0822'};
rev_info.s17.unpred(1).bad_lfp = {'EEG008','EEG033'};

%turns with left hand 
rev_info.s17.unpred(2).file = 's17_unpred2.fif';
rev_info.s17.unpred(2).bad_meg = {'-MEG0443','-MEG1633','-MEG0822'};
rev_info.s17.unpred(2).bad_lfp = {'EEG008','EEG033'};

%18
rev_info.s18.dbs_system = 'abbot_infinity';
rev_info.s18.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-18/220224/';
rev_info.s18.used_hand = 'right'; 
rev_info.s18.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s18.bestcontact_contra = 'LFP-left-3B-4';
rev_info.s18.bestcontact_ipsi = 'LFP-right-1-2A';
% contact selection with gamma 
% rev_info.s18.bestcontact_contra = 'LFP-left-3B-4';
% rev_info.s18.bestcontact_ipsi = 'LFP-right-1-2C';
rev_info.s18.data = 1;
%espeically 0113 still bad after tsss but cannot take all these chans out (should not have an impact, not part of ROIs)
%delete trial unpred start trial 19

%just changed numbers to make it easier in LFP scripts, k == 1 always bad
rev_info.s18.rest(1).file = 'sub18_rest.fif';
rev_info.s18.rest(1).bad_meg = {'-MEG0822','-MEG1633'};
rev_info.s18.rest(1).bad_lfp = {'EEG008','EEG033'};

rev_info.s18.pred(2).file = 'sub18_pred1.fif';
rev_info.s18.pred(2).bad_meg = {'-MEG0113','-MEG0223','-MEG1522','-MEG2223','-MEG1722','-MEG2313','-MEG0342','-MEG0822','-MEG0532','-MEG0543','-MEG1233','-MEG1633','-MEG0742'};
rev_info.s18.pred(2).bad_lfp = {'EEG008','EEG033'};

rev_info.s18.pred(1).file = 'sub18_pred2.fif';
rev_info.s18.pred(1).bad_meg = {'-MEG0223','-MEG243','-MEG1522','-MEG2612','-MEG1823','-MEG0742','-MEG1633','-MEG1722','-MEG2313','-MEG0342','-MEG0822','-MEG0532','-MEG0823'};
rev_info.s18.pred(1).bad_lfp = {'EEG008','EEG033'};

rev_info.s18.unpred(2).file = 'sub18_unpred1.fif';
rev_info.s18.unpred(2).bad_meg = {'-MEG1633','-MEG0822'};
rev_info.s18.unpred(2).bad_lfp = {'EEG008','EEG033'};

rev_info.s18.unpred(1).file = 'sub18_unpred2.fif';
rev_info.s18.unpred(1).bad_meg = {'-MEG0223','-MEG243','-MEG1522','-MEG1633','-MEG1823','-MEG0742','-MEG0743','-MEG1923','-MEG1722','-MEG2313','-MEG2543','-MEG0342','-MEG0822','-MEG0532','-MEG0322'};
rev_info.s18.unpred(1).bad_lfp = {'EEG008','EEG033'};

%19
%Turns very slownly, reversals slow 
rev_info.s19.dbs_system = 'medtronic';
rev_info.s19.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-19/220303/';
rev_info.s19.used_hand = 'right';
rev_info.s19.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s19.bestcontact_contra = 'LFP-left-2B-3B';
rev_info.s19.bestcontact_ipsi = 'LFP-right-2C-3C';
% contact selection with gamma 
% rev_info.s19.bestcontact_contra = 'LFP-left-2A-3A';
% rev_info.s19.bestcontact_ipsi = 'LFP-right-2C-3C';
rev_info.s19.data = 1;

rev_info.s19.rest(1).file = 'sub19_rest.fif';
rev_info.s19.rest(1).bad_meg = {'-MEG0413','-MEG2013','-MEG0822','-MEG0542'};
rev_info.s19.rest(1).bad_lfp = {'EEG008','EEG033','EEG040'};

rev_info.s19.pred(1).file = 'sub19_pred1.fif';
rev_info.s19.pred(1).bad_meg = {'-MEG0413','-MEG2013','-MEG1633','-MEG0312','-MEG0342','-MEG0822','-MEG0542','-MEG0323','-MEG1243'};
rev_info.s19.pred(1).bad_lfp = {'EEG008','EEG033','EEG040'};

rev_info.s19.pred(2).file = 'sub19_pred2.fif';
rev_info.s19.pred(2).bad_meg = {'-MEG0413','-MEG2013','-MEG2142','-MEG0312','-MEG0342','-MEG0822','-MEG0542','-MEG0323','-MEG1243'};
rev_info.s19.pred(2).bad_lfp = {'EEG008','EEG033','EEG040'};

rev_info.s19.unpred(1).file = 'sub19_unpred1.fif';
rev_info.s19.unpred(1).bad_meg = {'-MEG0413','-MEG2013','-MEG1633','-MEG2142','-MEG0822','-MEG0542','-MEG1243'};
rev_info.s19.unpred(1).bad_lfp = {'EEG008','EEG033','EEG040'};

rev_info.s19.unpred(2).file = 'sub19_unpred2.fif';
rev_info.s19.unpred(2).bad_meg = {'-MEG0413','-MEG2013','-MEG1633','-MEG0822','-MEG0542','-MEG1243'};
rev_info.s19.unpred(2).bad_lfp = {'EEG008','EEG033','EEG040'};

%20
rev_info.s20.dbs_system = 'abbot_infinity';
rev_info.s20.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-20/220317/';
rev_info.s20.used_hand = 'right'; 
rev_info.s20.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s20.bestcontact_contra = 'LFP-left-2C-3C';
rev_info.s20.bestcontact_ipsi = 'LFP-right-3A-4';
% contact selection with gamma 
% rev_info.s20.bestcontact_contra = 'LFP-left-3A-4';
% rev_info.s20.bestcontact_ipsi = 'LFP-right-3B-4';
rev_info.s20.data = 0;
%unpred rev 11; pred reversal, trial 11,55,68 deleted cuz not a real reversal;
%not deleted but bad: unpred stop has tremor but didnt delete trials because would be too many, unpred start:44 is the worst
%here 

rev_info.s20.rest(1).file = 'sub20_rest.fif';
rev_info.s20.rest(1).bad_meg = {'-MEG1333','-MEG1633','-MEG1822','-MEG0822'};
rev_info.s20.rest(1).bad_lfp = {'EEG033'};

rev_info.s20.pred(1).file = 'sub20_pred1.fif';
rev_info.s20.pred(1).bad_meg = {'-MEG1633','-MEG1822','-MEG0822'};
rev_info.s20.pred(1).bad_lfp = {'EEG033'};

rev_info.s20.pred(2).file = 'sub20_pred2.fif';
rev_info.s20.pred(2).bad_meg = {'-MEG1633','-MEG1822','-MEG0822','-MEG2543','-MEG2542','-MEG2532'};
rev_info.s20.pred(2).bad_lfp = {'EEG033'};

rev_info.s20.unpred(1).file = 'sub20_unpred.fif';
rev_info.s20.unpred(1).bad_meg = {'-MEG1633','-MEG1822','-MEG0822','-MEG2543','-MEG2542','-MEG2532'};
rev_info.s20.unpred(1).bad_lfp = {'EEG033'};

rev_info.s20.unpred(2).file = 'sub20_unpred2.fif';
rev_info.s20.unpred(2).bad_meg = {'-MEG1633','-MEG1822','-MEG0822','-MEG2543','-MEG2542','-MEG2532','-MEG0223'};
rev_info.s20.unpred(2).bad_lfp = {'EEG033'};

%21
rev_info.s21.dbs_system = 'abbot_infinity';
rev_info.s21.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-21/220428/';
rev_info.s21.used_hand = 'right'; 
rev_info.s21.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s21.bestcontact_contra = 'LFP-left-2A-3A';
rev_info.s21.bestcontact_ipsi = 'LFP-right-2B-3B';
% contact selection with gamma 
% rev_info.s21.bestcontact_contra = '';
% rev_info.s21.bestcontact_ipsi = '';
rev_info.s21.data = 0;
%1412 channel bad
%trl 66 unpred stop tremor but didnt delete 

rev_info.s21.rest(1).file = 'sub21_rest.fif';
rev_info.s21.rest(1).bad_meg = {'-MEG1713','-MEG1633','-MEG2533','-MEG0822','-MEG0542'};
rev_info.s21.rest(1).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s21.pred(1).file = 'sub21_pred1.fif';
rev_info.s21.pred(1).bad_meg = {'-MEG1633','-MEG2612','-MEG2632','-MEG2642','-MEG2613','-MEG1713','-MEG2522','-MEG0822','-MEG0542'};
rev_info.s21.pred(1).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s21.pred(2).file = 'sub21_pred2.fif';
rev_info.s21.pred(2).bad_meg = {'-MEG1633','-MEG2642','-MEG0822','-MEG1713','-MEG2522'};
rev_info.s21.pred(2).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s21.unpred(1).file = 'sub21_unpred1.fif';
rev_info.s21.unpred(1).bad_meg = {'-MEG1633','-MEG2612','-MEG0822','-MEG2632','-MEG2613','-MEG1713','-MEG2522'};
rev_info.s21.unpred(1).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s21.unpred(2).file = 'sub21_unpred2.fif';
rev_info.s21.unpred(2).bad_meg = {'-MEG1633','-MEG2612','-MEG0822','-MEG2632','-MEG2642','-MEG1713','-MEG2522'};
rev_info.s21.unpred(2).bad_lfp = {'EEG003','EEG008','EEG033'};

%22
%need to reject artifacts still
rev_info.s22.dbs_system = 'abbot_infinity';
rev_info.s22.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-22/';
rev_info.s22.used_hand = 'right'; 
rev_info.s22.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s22.bestcontact_contra = 'LFP-left-2C-3C';
rev_info.s22.bestcontact_ipsi = 'LFP-right-2A-3A';
% contact selection with gamma 
% rev_info.s22.bestcontact_contra = '';
% rev_info.s22.bestcontact_ipsi = '';
rev_info.s22.data = 0;

rev_info.s22.rest(1).file = 'S22_rest.fif';
rev_info.s22.rest(1).bad_meg = {'-MEG0422','-MEG0432','-MEG0342','-MEG0822'};
rev_info.s22.rest(1).bad_lfp = {'EEG006','EEG008','EEG033''EEG034'};

rev_info.s22.pred(1).file = 's22_pred1.fif';
rev_info.s22.pred(1).bad_meg = {'-MEG0422','-MEG2132','-MEG0822'};
rev_info.s22.pred(1).bad_lfp = {'EEG006','EEG008','EEG033''EEG034'};

rev_info.s22.pred(2).file = 's22_pred2.fif';
rev_info.s22.pred(2).bad_meg = {'-MEG0422','-MEG0432','-MEG0822'};
rev_info.s22.pred(2).bad_lfp = {'EEG006','EEG008','EEG033''EEG034'};

rev_info.s22.unpred(1).file = 's22_unpred1.fif';
rev_info.s22.unpred(1).bad_meg = {'-MEG0422','-MEG0432','-MEG0342','-MEG0822'};
rev_info.s22.unpred(1).bad_lfp = {'EEG006','EEG008','EEG033''EEG034'};

rev_info.s22.unpred(2).file = 's22_unpred2.fif';
rev_info.s22.unpred(2).bad_meg = {'-MEG0422','-MEG0432','-MEG2132','-MEG0822'};
rev_info.s22.unpred(2).bad_lfp = {'EEG006','EEG008','EEG033''EEG034'};


%23
%need to reject artifacts still
rev_info.s23.dbs_system = 'abbot_infinity';
rev_info.s23.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-23/221110/';
rev_info.s23.used_hand = 'right'; 
rev_info.s23.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s23.bestcontact_contra = 'LFP-left-3C-4';
% rev_info.s23.bestcontact_ipsi = 'LFP-right-3B-4';
rev_info.s23.bestcontact_ipsi = 'LFP-right-1-2C';
% contact selection with gamma 
% rev_info.s23.bestcontact_contra = '';
% rev_info.s23.bestcontact_ipsi = '';
rev_info.s23.data = 0;
%when looking at summary of trials, variance for pred = 1 changes
%drastically from first to second half on all events, but when going
%through trials in data browser there doesnt seem to be a problem
%tr 60 unpred rev raus cuz not ral rev

rev_info.s23.rest(1).file = 's23_rest.fif';
rev_info.s23.rest(1).bad_meg = {'-MEG1612','-MEG1323','-MEG2613','-MEG2422','-MEG1833','-MEG2243','-MEG2143','-MEG2132','-MEG0612'};
rev_info.s23.rest(1).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s23.pred(1).file = 's23_pred1.fif';
rev_info.s23.pred(1).bad_meg = {'-MEG2613','-MEG1323','-MEG2412','-MEG2132'};
rev_info.s23.pred(1).bad_lfp = {'EEG003','EEG008','EEG033'};
%in art detectionneet to cut out first few seconds!

rev_info.s23.pred(2).file = 's23_pred2.fif';
rev_info.s23.pred(2).bad_meg = {'-MEG2132','-MEG1323'};
rev_info.s23.pred(2).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s23.unpred(1).file = 's23_unpred1.fif';
rev_info.s23.unpred(1).bad_meg = {'-MEG2132','-MEG1612','-MEG1323','-MEG2422','-MEG1833','-MEG2243','-MEG2143','-MEG1643','-MEG0612','-MEG1012'};
rev_info.s23.unpred(1).bad_lfp = {'EEG003','EEG008','EEG033'};

rev_info.s23.unpred(2).file = 's23_unpred2.fif';
rev_info.s23.unpred(2).bad_meg = {'-MEG1612','-MEG1323','-MEG2422','-MEG1833','-MEG2243','-MEG2143','-MEG2132','-MEG0612','-MEG1012'};
rev_info.s23.unpred(2).bad_lfp = {'EEG003','EEG008','EEG033'};

%24
%need to reject artifacts still
rev_info.s24.dbs_system = 'medtronic';
rev_info.s24.raw_dir = '/data/project/hirsch/reverse/dacq/raw/sub-24/221208/';
rev_info.s24.used_hand = 'right'; 
rev_info.s24.dial_channel = 'MISC016';
% contact selection with beta 
rev_info.s24.bestcontact_contra = 'LFP-left-2B-3B';
rev_info.s24.bestcontact_ipsi = 'LFP-right-1-2C';
% contact selection with gamma 
% rev_info.s24.bestcontact_contra = '';
% rev_info.s24.bestcontact_ipsi = '';
rev_info.s24.data = 0;

rev_info.s24.rest(1).file = 's24_rest.fif';
rev_info.s24.rest(1).bad_meg = {'-MEG0443','-MEG0442','-MEG1243'};
rev_info.s24.rest(1).bad_lfp = {'EEG008','EEG036','EEG033'};

rev_info.s24.pred(1).file = 's24_pred1.fif';
rev_info.s24.pred(1).bad_meg = {'-MEG1532','-MEG1533','-MEG1333','-MEG0422','-MEG0443','-MEG1733','-MEG1732','-MEG1723','-MEG1722','-MEG2132','-MEG1742','-MEG1712','-MEG1713','-MEG1243'};
rev_info.s24.pred(1).bad_lfp = {'EEG036','EEG033'};
%in art detectionneet to cut out first few seconds!

rev_info.s24.pred(2).file = 's24_pred2.fif';
rev_info.s24.pred(2).bad_meg = {'-MEG1333','-MEG0422','-MEG0443','-MEG2132','-MEG1243','-MEG0822'};
rev_info.s24.pred(2).bad_lfp = {'EEG036','EEG033'};

rev_info.s24.unpred(1).file = 's24_unpred1.fif';
rev_info.s24.unpred(1).bad_meg = {'-MEG1532','-MEG1533','-MEG0422','-MEG0443','-MEG1733','-MEG1732','-MEG1723','-MEG1722','-MEG2132','-MEG1742','-MEG1712','-MEG1713','-MEG1243'};
rev_info.s24.unpred(1).bad_lfp = {'EEG036','EEG033'};

rev_info.s24.unpred(2).file = 's24_unpred2.fif';
rev_info.s24.unpred(2).bad_meg = {'-MEG2412','-MEG1333','-MEG0422','-MEG0443','-MEG1733','-MEG1732','-MEG1723','-MEG1722','-MEG2132','-MEG1742','-MEG1712','-MEG1713','-MEG1243'};
rev_info.s24.unpred(2).bad_lfp = {'EEG036','EEG033'};

rev_info.all_subjects_in_use = [1 2 4 5 6 7 8 10 11 12 13 14 17 18 19 20 21 22 23 24];


save /data/project/hirsch/reverse/analysis/Info/rev_info rev_info
    