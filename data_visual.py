#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr  3 16:11:15 2019

@author: gc349
"""
#%%
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
from scipy.stats import norm
import mne
import seaborn as sns
import statsmodels.graphics.api as smg
import pandas as pd
#%% Load data frame
fpath='/its/home/gc349/CIFAR_guillaume/CIFAR_data/CIFAR/iEEG_10/subjects/AnRa/EEGLAB_datasets/raw_signal/AnRa_freerecall_awake_raw/'
fname='AnRa_freerecall_rest_baseline_1_preprocessed.set'
path=fpath+fname
raw = mne.io.read_raw_eeglab(path, eog=(), montage=None,
                             stim_channel=False)
df=raw.to_data_frame()
#%% Load chan_table
fpath_subject='/its/home/gc349/CIFAR_guillaume/CIFAR_data/CIFAR/iEEG_10/subjects/AnRa/'
fname_chan_table='ch_table_AnRa.csv'
path_chan_table=fpath_subject+fname_chan_table
chan_table=pd.read_csv(path_chan_table)
chan_table=chan_table.dropna(axis=1,how='all') #drop NaN
#%% Correlation between all  channels
df.columns=chan_table['chan_idx'] #change name of df columns to chidx
corr = df.corr('pearson')
#%% Select ROI 
ROIidx=6 #using arcparse will allow more flexibility
#Retrieve channels belonging in selected ROI
pick_chanidx=chan_table[chan_table['ROIidx']==ROIidx]['chan_idx'].tolist()
pick_chan=[]
pick_chan[:]=[i-1 for i in pick_chanidx] #adapt indexing to python
#%% Correlation between channels in ROIidx
corr_ROI=corr.iloc[pick_chan, pick_chan]
#Draw heatmap of correlation of rgion of interest
mask = np.zeros_like(corr_ROI, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True
plt.figure()
sns.heatmap(corr_ROI, vmin=-1, cmap= 'coolwarm', annot=True, annot_kws={"size": 10}, mask=mask)
plt.title('Pearson correlation between channels in ROI %s' %ROIidx) 
#%% Violins
# Set up the matplotlib figure
f, ax = plt.subplots(figsize=(11, 6))
# Draw a violinplot with a narrower bandwidth than the default bw=.2, cut=1, linewidth=1
sns.violinplot(data=df.loc[:, pick_chan], scale='count', inner='quartile', palette="Set3", bw=0.3)
# Finalize the figure
#ax.set(ylim=(-250, 250))
#sns.despine(left=True, bottom=True)
plt.title('Violin plot of chans distributions in ROI %s' %ROIidx) 
#%%Box plot
plt.figure()
sns.boxplot(data = df.loc[:, pick_chan])
plt.title('Box plot of chans distributions in ROI %s' %ROIidx) 
#%% correlogram
#plt.figure()
#sns.pairplot(df.loc[:, pick_chan], diag_kind="kde", kind="reg")##markers="+"
#plt.title('Correlogram of chans in ROI %s' %ROIidx) 
#sns.plt.show
#%% Cross spectral power density
raw = mne.io.read_raw_eeglab(path, eog=(), montage=None,
                             stim_channel=False, preload=True)
chan_name_pick=chan_table.iloc[pick_chan]['chan_name'].tolist()
raw_ROI=raw.copy().pick_channels(chan_name_pick)
tmin, tmax = 0, 200
fmin, fmax = 1, 250  # look at frequencies between 2 and 300Hz
n_fft = 2048  # the FFT size (n_fft). Ideally a power of 2
plt.figure()
ax = plt.axes()
raw_ROI.plot_psd(tmin=tmin, tmax=tmax, fmin=fmin, fmax=fmax, n_fft=n_fft,
             n_jobs=1, proj=False, ax=ax, color=(0, 0, 1),
             show=False, average=True)
plt.title('PSD of chans in ROI %s' %ROIidx)
#%% Bivariate density
#g=g.map_upper(plt.scatter)
#g=g.map_lower(sns.kdeplot, cmap="Blues_d")
#g = g.map_diag(sns.kdeplot, lw=3, legend=False)
#%% Check histogram
path2save_plot='/its/home/gc349/CIFAR_guillaume/Plots/AnRa/descriptive_stat/'
for i in pick_chan :
  sns.distplot(df.loc[:, i], fit=norm, bins=200, kde=False)
# Get the fitted parameters used by sns
  (mu, sigma) = norm.fit(df.loc[:, i])
# Legend and labels 
  plt.legend(["normal dist. fit ($\mu=${0:.2g}, $\sigma=${1:.2f})".format(mu, sigma)])
  plt.ylabel('Frequency')
  plt.title('Histogram of chan %s in ROI %s' %(i, ROIidx))
  plot_name='hist_ROI%s_chan_%s.png'%(i,ROIidx)
  plt.savefig(path2save_plot+plot_name)
#%%Histogram other way
df_ROI=pd.melt(df,value_vars=pick_chan)
g=sns.FacetGrid(df_ROI,col='chan_idx', col_wrap=4)
g.map(sns.distplot, "value", fit=norm, bins=200, kde=False)
g.add_legend(title='Histograms of ROI %s fitted by normal dist'%ROIidx)