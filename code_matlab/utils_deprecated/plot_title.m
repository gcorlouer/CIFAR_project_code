%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a nice informative title for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tstr = plot_title(filename,ppdir,chanstr,idstr,fs,wind);

if nargin < 6 || isempty(wind)
	tstr = sprintf('%s (%s)\n%s\n%s : sample rate = %gHz\n',filename,ppdir,chanstr,idstr,fs);
else
	tstr = sprintf('%s (%s)\n%s\n%s : sample rate = %gHz, window = %gs, slide = %gs\n',filename,ppdir,chanstr,idstr,fs,wind(1),wind(2));
end
