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
from mayavi import mlab
import mne
from mne.viz import plot_alignment, snapshot_brain_montage
import seaborn as sns
import pandas as pd
#%%
fpath='/its/home/gc349/CIFAR_guillaume/CIFAR_data/CIFAR/iEEG_10/subjects/AnRa/EEGLAB_datasets/raw_signal/AnRa_freerecall_awake_raw/'
fname='AnRa_freerecall_rest_baseline_1_preprocessed.set'
path=fpath+fname
raw = mne.io.read_raw_eeglab(path, eog=(), montage=None,
                             stim_channel=False)
df=raw.to_data_frame()
#%% Correlation
corr = df.corr('pearson')
corr_ROI=corr.iloc[1:5,1:5]
#Draw heatmap of correlation of rgion of interest
plt.figure()
sns.heatmap(corr_ROI, annot=True, annot_kws={"size": 10})
plt.ylabel('Channels')
plt.title('Correlation between channels in ROI') 
#%% Violin
# Set up the matplotlib figure
f, ax = plt.subplots(figsize=(11, 6))
# Draw a violinplot with a narrower bandwidth than the default
sns.violinplot(data=df.iloc[:,1:5], palette="Set3", bw=.2, cut=1, linewidth=1)
# Finalize the figure
ax.set(ylim=(-1000, 1000))
sns.despine(left=True, bottom=True)