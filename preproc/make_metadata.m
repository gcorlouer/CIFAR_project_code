%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Information common to all CIFAR data and analysis pipelines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function make_metadata

global cfmetadata

lnfreq   = 60; % line-noise frequency
fbands   = {{'delta',[1 4]}; {'theta',[4 8]}; {'alpha',[8 15]}; {'beta',[15 30]}; {'lgamma',[30 50]}; {'hgamma',[50 100]}};
nfbands  = length(fbands);

fprintf('\nSaving data file ... ');
save(cfmetadata,'-v7.3');
fprintf('done\n');
