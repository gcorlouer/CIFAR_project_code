
nchans = length(EEG.chanlocs);

chanlocs = zeros(nchans,3);
for i = 1:nchans
	chanlocs(i,1) = EEG.chanlocs(i).X;
	chanlocs(i,2) = EEG.chanlocs(i).Y;
	chanlocs(i,3) = EEG.chanlocs(i).Z;
end

save('/tmp/chanlocs.mat','chanlocs','-v6')
