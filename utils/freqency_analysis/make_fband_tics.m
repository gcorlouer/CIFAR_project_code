function [ticstr,nfbands] = make_fband_tics(fbands,gpterm)

if nargin < 2, gpterm = []; end

nfbands = length(fbands);
tics = cell(nfbands,1);
for i = 1:nfbands-1
	fpos = (fbands{i}{2}(1)+fbands{i}{2}(2))/2;
	tics{i} = ['"' fband_format(fbands{i}{1},gpterm,false) '" ' num2str(fpos) ','];
end
i = nfbands;
fpos = (fbands{i}{2}(1)+fbands{i}{2}(2))/2;
tics{i} = ['"' fband_format(fbands{i}{1},gpterm,false) '" ' num2str(fpos)];
ticstr = sprintf('%s',tics{:});
