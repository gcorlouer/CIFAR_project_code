#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 12 14:44:02 2019

@author: gc349
"""
#%%
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import mne
from mne import io, read_proj, read_selection
from mne.datasets import sample
from mne.time_frequency import psd_multitaper
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
chan_table_ROI=chan_table.sort_values('ROIidx') #sort index per ascending ROI
#%% List of name and index of bad channels
bad_ch=chan_table.index[chan_table['ROIidx']==23].tolist();
bad_ch_name=chan_table['chan_name'].iloc[bad_ch].tolist();
bad_ch_idx=chan_table['chan_idx'].iloc[bad_ch].tolist();
#%% Channel selection
raw.info['bads'] += bad_ch_name
#%% Plot psd
#plt.figure()
raw.plot_psd(area_mode='range', tmin=5, tmax=15, fmax=200, dB=True, estimate='power', show=False)
ax = plt.axes()
ax.set_title('psd_AnRa_resting_state_200sec_window')
#%% With filtering
raw.load_data()
plt.figure()
ax = plt.axes()
raw.notch_filter(60, n_jobs=1, fir_design='firwin')
ax.set_title('AnRa_resting_state_200sec_window')
raw.plot_psd(area_mode='range', tmin=0, tmax=200, fmax=200, dB=True, estimate='power', show=False)