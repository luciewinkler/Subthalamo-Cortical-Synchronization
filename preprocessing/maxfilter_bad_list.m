function bad_list=maxfilter_bad_list(badchans)

bad_list=' ';

for i=1:numel(badchans)
    chan=badchans{i};
    if strncmp('-MEG',chan,4)
        bad_list=strcat([bad_list,' ',chan(5:end),' ']);
    end
end
