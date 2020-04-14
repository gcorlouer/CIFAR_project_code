import matlab.engine
from pathlib import Path, PurePath
import mne
sub = 'S01'
datatype = 'BP_montage'
task = 'rest'
run = 'run_1'
dpath = PurePath('data','subjects','S01','nopreproc')
dataset = 'AnRa_freerecall_rest_baseline_1_preprocessed_BP_montage.set'
fpath = dpath.joinpath(dataset)
raw = mne.io.read_raw_eeglab(fpath, preload=True)
raw.info 
raw.plot()
