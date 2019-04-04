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
import mne
import seaborn as sns
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
df.columns=chan_table['chan_idx']
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
sns.violinplot(data=df.iloc[pick_chan, pick_chan], scale='count', inner='quartile', palette="Set3", bw='scott')
# Finalize the figure
#ax.set(ylim=(-250, 250))
#sns.despine(left=True, bottom=True)
plt.title('Violin plot of chans in ROI %s' %ROIidx) 
#%%Box plot
plt.figure()
sns.boxplot(data = df.iloc[pick_chan, pick_chan])
plt.title('Box plot of chans in ROI %s' %ROIidx) 
