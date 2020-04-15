# %% Import modules
import matlab.engine
import os
import mne_bids
from pathlib import Path, PurePath
import mne
import matplotlib.pyplot as plt
import pandas as pd

# Enable the table_schema option in pandas,
# data-explorer makes this snippet available with the `dx` prefix:
pd.options.display.html.table_schema = True
pd.options.display.max_rows = None

# %% import data
%matplotlib auto
wdir = PurePath('/home', 'guime', 'projects', 'CIFAR')
os.chdir(wdir)
sub = 'S01'
datatype = 'BP_montage'
task = 'rest'
run = 'run_1'
dataset = 'AnRa_freerecall_rest_baseline_1_preprocessed_BP_montage.set'
fpath = dpath.joinpath(dataset)
dpath = PurePath('data', 'subjects', 'S01', 'nopreproc')
raw = mne.io.read_raw_eeglab(fpath, preload=True)
raw.info  # does not give npts
# %% Drop bad channels
# ToDo plot cpsd
badchan_dpath = PurePath('data', 'subjects', 'S01', 'prep_badchans')
badchan_fname = 'sub-01_freerecall_rest_run_1_BP_badchan'
badchan_fpath = badchan_dpath.joinpath(badchan_fname)
# visualise data and identify bad channels
raw.plot(duration=200, n_channels=30, scalings=5e-4, color='b')
raw.info['bads']
raw.save(badchan_fpath)
# %% detrend
