function [figfile,imfile] = save_fig(mfilename,filename,filepath,figsave)

if nargin < 4, figsave = false; end

if isscalar(figsave) && ~figsave % do nothing
	return
end

global cffigdir
figfile = fullfile(cffigdir,[mfilename '_' filename '_' lastpart(filepath) '.fig']);
fprintf('\nFigure file: ''%s''\n\n',figfile);
savefig(figfile);

if ischar(figsave)
	if figsave(end) == '*' % if ends in '*', view figure
		imfile = print_fig(figfile,figsave(1:end-1),true);
	else
		imfile = print_fig(figfile,figsave,false);
	end
else
	imfile = '';
end
