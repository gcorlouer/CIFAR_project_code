function [A, C, K, V, moaic, mosvc] = slide_ss(X, ts, fs, wind, tstamp, momax, moregmode)


[X, ~, nwin, nwobs, nsobs, tsw, wind] = sliding(X, ts, fs, wind, tstamp);

moaic = zeros(nwin,1); mosvc = zeros(nwin, 1);
A = zeros(nwin, 1); C = zeros(nwin, 1); 
K = zeros(nwin, 1); V = zeros(nwin, 1);

for w = 1:nwin
	o = (w-1)*nsobs;      % window offset
	W = X(:, o+1:o+nwobs); % the window\\
	[moaic(w), ~, ~, ~] = tsdata_to_varmo(W, momax, moregmode); % Choose AIC
    pf = 2*moaic(w);  % Bauer recommends 2 x VAR AIC model order
    [~, ~, ~, mosvc(w), ~, ~] = tsdata_to_ssmo(W, pf);
    %[mosvc(w),~] = tsdata_to_sssvc(X,pf);
    [A(w), C(w), K(w), V(w), ~, ~] = tsdata_to_ss(W, pf, mosvc(w));
end