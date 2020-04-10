tsdim = 10; morder =5; specrad = 0.98; nobs = 10000;
[tsdata,var_coef,corr_res] = var_sim(tsdim, morder,nobs, specrad);
cd(home_dir)
fpath = fullfile(home_dir, 'TimeSeries_analysis','tsdata.mat');
save(fpath)
X = load(fpath)