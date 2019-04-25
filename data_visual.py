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
rep2plot='/its/home/gc349/CIFAR_guillaume/Plots/AnRa/descriptive_stat/'
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
##Draw heatmap of correlation between all channels
mask = np.zeros_like(corr, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True
plt.figure()
sns.heatmap(corr, vmin=-1, cmap= 'coolwarm', annot=False, mask=mask)
plt.title('Pearson correlation between all channels ') 
#%% Select ROI
#for j in range(max(chan_table['ROIidx'])-1): 
ROIidx=6
#Retrieve channels belonging in selected ROI
pick_chanidx=chan_table[chan_table['ROIidx']==ROIidx]['chan_idx'].tolist()
pick_chan=[]
pick_chan[:]=[i-1 for i in pick_chanidx] #adapt indexing to python
##Correlation between channels in ROIidx
corr_ROI=corr.iloc[pick_chan, pick_chan]
fig_name='corr_ROI%s.png'%ROIidx
path2plot=rep2plot+fig_name
##Draw heatmap of correlation of rgion of interest
mask = np.zeros_like(corr_ROI, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True
plt.figure()
sns.heatmap(corr_ROI, vmin=-1, cmap= 'coolwarm', annot=True, annot_kws={"size": 8}, mask=mask)
plt.title('Pearson correlation between channels in ROI %s' %ROIidx) 
plt.savefig(path2plot)
## Violins
# Set up the matplotlib figure
fig_name='violin_ROI%s.png'%ROIidx
path2plot=rep2plot+fig_name
f, ax = plt.subplots(figsize=(11, 6))
# Draw a violinplot with a narrower bandwidth than the default bw=.0.3, cut=1, linewidth=1
sns.violinplot(data=df.loc[:, pick_chanidx], scale='count', inner='quartile', palette="Set3", bw=0.3)
plt.title('Violin plot of chans distributions in ROI %s' %ROIidx)
plt.savefig(path2plot)
##Box plot
fig_name='boxp_ROI%s.png'%ROIidx
path2plot=rep2plot+fig_name
plt.figure()
sns.boxplot(data = df.loc[:, pick_chanidx])
plt.title('Box plot of chans distributions in ROI %s' %ROIidx)
plt.savefig(path2plot)
## Cross spectral power density
fig_name='psd_ROI%s.png'%ROIidx
path2plot=rep2plot+fig_name
raw = mne.io.read_raw_eeglab(path, eog=(), montage=None,
                             stim_channel=False, preload=True)
chan_name_pick=chan_table.iloc[pick_chanidx]['chan_name'].tolist()
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
plt.savefig(path2plot)
##Histogram and normal fitting
fig_name='hist_ROI%s.png'%ROIidx
path2plot=rep2plot+fig_name
df_ROI=pd.melt(df,value_vars=pick_chanidx)
g=sns.FacetGrid(df_ROI,col='chan_idx', col_wrap=4)
g.map(sns.distplot, "value", fit=norm, bins=200, kde=False)
g.add_legend(title='Histograms of ROI %s fitted by normal dist'%ROIidx)
plt.savefig(path2plot)