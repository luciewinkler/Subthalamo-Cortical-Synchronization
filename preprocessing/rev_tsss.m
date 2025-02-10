
%runs tsss for cleaning meg data

load /data/project/hirsch/reverse/analysis/Info/rev_info
addpath '/data/project/hirsch/reverse/analysis/scripts/';

%get field names from rev info structure
subjects = fieldnames(rev_info);

%experimental conditions
conditions = {'pred','unpred','rest'};

for i = rev_info.all_subjects_in_use
    
    %select current subject
    subj = subjects{i};
    
    %subject directory with all conditions
    rawdir = rev_info.(subj).raw_dir;
    
    %loop through all conditions of current subject
    for j = 1:numel(conditions)
        
        %select current condition j
        current_condi = conditions{j};
        
        if isfield(rev_info.(subj),current_condi)
            
            %chek how many datasets there are for this condition
            files = {rev_info.(subj).(current_condi).file};
            badChans = {rev_info.(subj).(current_condi).bad_meg};
            
            % go through all files 
            for k = 1:length(files)
                
                %get relevant file of current condition
                rawfile = files{k};
                
                %load bad channels from info
                badChan = badChans{k};
                
                badchans=maxfilter_bad_list(badChan);
                
                %save
                logfile=strcat(['/data/project/hirsch/reverse/analysis/intermediate_data/data/tSSS/log/',subj,'_',current_condi,'_',num2str(k),'_log.txt ']);
                %tsss
                output_file= ['/data/project/hirsch/reverse/analysis/intermediate_data/data/tSSS/',subj,'_',current_condi,'_',num2str(k),'_tSSS.fif'];
                
                %tsss
                eval(strcat(['!','ssh hermes /neuro/bin/util/maxfilter-2.2 -f ',[rawdir,rawfile],...
                    ' -o ',output_file,' -autobad off -bad ',badchans,' -ctc /neuro/databases/ctc/ct_sparse.fif',...
                    ' -st -format short -cal /neuro/databases/sss/sss_cal.dat ','-list | tee ',logfile]));
                
            end
        end
    end
end




