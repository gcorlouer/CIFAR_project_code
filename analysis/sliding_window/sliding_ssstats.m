%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate AR model stats over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run 'sliding_ssmo' first

if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rhoa = zeros(nwin,1);
rhob = zeros(nwin,1);
mii  = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	[A,C,K,V] = tsdata_to_ss(W,pf(w),mosvc(w));
	info = ss_info(A,C,K,V,0);
	rhoa(w) = info.rhoA;
	rhob(w) = info.rhoB;
	mii(w)  = info.mii;
	fprintf('AR rho = %6.4f, MA rho = %6.4f, mii = %6.4f\n',rhoa(w),rhob(w),mii(w));
end

if ~isempty(fignum)

	center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	figure(fignum); clf;
	yyaxis left
	plot(tsw,-log(1-[rhoa rhob]));
	ylabel('-log(1-specrad)');
	yyaxis right
	plot(tsw,mii);
	xlim([ts(1) ts(end)]);
	ylabel('residuals multi-information');
	xlabel('time (secs)');
	legend({'AR','MA','MII'});

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
