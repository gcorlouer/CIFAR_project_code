%% Descriptive statistics of some data
X=X_pp; 
av_X=mean(X');
var_X=var(X');
min_X=min(abs(X),[],2);
max_X=max(abs(X),[],2);
ax1=subplot(4,1,1);
bar(av_X)
title('Sample mean')
ax2=subplot(4,1,2);
bar(var_X)
title('Variance')
ax3=subplot(4,1,3);
bar(min_X)
title('Absolute minimium')
ax4=subplot(4,1,4);
bar(max_X)
title('Absolute maximum')