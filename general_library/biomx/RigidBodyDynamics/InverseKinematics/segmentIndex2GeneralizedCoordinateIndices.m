function gc_ind = segmentIndex2GeneralizedCoordinateIndices(segind,gc)

if nargin == 1; gc = 'full'; end
if isempty(gc); gc = 'full'; end
if strcmpi(gc,'translation'); gc_ind = 7*segind-6:7*segind-4;
elseif strcmpi(gc,'rotation'); gc_ind = 7*segind-3:7*segind;
elseif strcmpi(gc,'full'); gc_ind = 7*segind-6:7*segind;
end

end