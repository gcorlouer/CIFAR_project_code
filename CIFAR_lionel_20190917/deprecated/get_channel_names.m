function channames = get_channel_names(subject,chans)

global cfsubdir
channames = [];
cnfile = fullfile(cfsubdir,subject,'Brain','channel_names.mat');
if exist(cnfile,'file') == 2
	load(cnfile);
class(channames)
size(channames)
size(chans)
	channames = channames(chans);
else
	fprintf(2,'WARNING: We don''t have channel names for this data; returning channel number as labels');
	channames = compose('%d',chans(:));
end
