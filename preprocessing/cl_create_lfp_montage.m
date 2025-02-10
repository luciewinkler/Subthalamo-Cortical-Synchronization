function montage =  cl_create_lfp_montage(chanlabels, refscheme,newlabels)
%returns a montage for lfp channel rereferencing to be used by ft_preprocessing

if size(refscheme,1)~=numel(newlabels)
    error('ref scheme and number of new labels does not match')
end
if size(refscheme,2)~=2
    error('bioloar ref scheme should have exactly two columns')
end
m = zeros(numel(newlabels),numel(chanlabels));
for cp = 1:size(refscheme,1)
    chpair = refscheme(cp,:);
    if numel(unique(chpair))==1
        error(['channel pair ', chpair, 'not unique'])
    end
    cpind1 = strcmp(chpair(1),chanlabels);
    if isempty(cpind1)
        error(['could not find channel ',chpair{1}])
    else
        m(cp,cpind1) = 1;
    end
    cpind2 = strcmp(chpair(2),chanlabels);
    if isempty(cpind2)
        error(['could not find channel ',chpair{2}])
    else
        m(cp,cpind2) = -1;
    end
end

montage.tra = m;
montage.labelold = chanlabels;
montage.labelnew = newlabels;
