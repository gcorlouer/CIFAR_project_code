function f = center_fig(fignum,xy)

global screenxy

f = figure(fignum);
clf;
set(gcf,'Position',[(screenxy-xy)/2 xy]); % set size (pixels) and center figure window
