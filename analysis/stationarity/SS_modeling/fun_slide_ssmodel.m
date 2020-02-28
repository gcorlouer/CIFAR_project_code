function [rhoa,rhob,mii,moest,mosvc]=fun_slide_ssmodel(X,ts,fig_filetail,fs,wind,HFB,fig_path_tail)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run state space model aliong sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6 fig_path_tail = '/figures/ssmodeling/' ; end
if nargin < 5 HFB           = 0 ;                      end
if nargin < 4 wind          = [10 0.1];                end
if nargin < 3 fs            = 500 ;                    end
%% Slice time series

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind);

%% VAR model order
moest=sliding_varmorder(X,ts,nwin,nsobs,nwobs,tsw);

if HFB==1
    fig_filename = ['envelope_varmorder_slide_',fig_filetail];
else
    fig_filename = ['varmorder_slide_',fig_filetail];
end
fig_filepath = [pwd, fig_path_tail]; %check that path is correct


saveas(gcf,[fig_filepath,fig_filename,'.fig']);
close all
%% State space model order

[mosvc,pf] = sliding_ssmorder(X,ts,nwin,nsobs,nwobs,tsw,moest)

if HFB==0
    fig_filename = ['ssmordel_slide_', fig_filetail];
else
    fig_filename = ['envelope_ssmordel_slide_', fig_filetail];
end
fig_filepath = [pwd, fig_path_tail]; %check that path is correct

saveas(gcf,[fig_filepath,fig_filename,'.fig']);
close all
%% SS model statistics

[rhoa,rhob,mii]= ss_mostat(X,ts,mosvc,pf,nwin,nsobs,nwobs,tsw);

if HFB==0
    fig_filename = ['ssmodel_slide_', fig_filetail];
else
    fig_filename = ['envelope_ssmodel_slide_', fig_filetail];
end
fig_filepath = [pwd, fig_path_tail]; %check that path is correct

saveas(gcf,[fig_filepath,fig_filename,'.fig']);
close all