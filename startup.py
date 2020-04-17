import matlab.engine
from pathlib import Path, PosixPath
import os
# %% Create relevant Path

eng = matlab.engine.start_matlab()
wdir = PosixPath('~', 'projects', 'CIFAR').expanduser()
homedir = PosixPath('~').expanduser()
mvgcdir = eng.fullfile('~', 'toolboxes', 'mvgc')
noisetooldir = eng.fullfile('~', 'toolboxes', 'NoiseTools')
os.chdir(wdir)
eng.cd(eng.fullfile('~', 'projects', 'CIFAR'))
Path.cwd()
eng.pwd()

# %% Add relevant matlab path

eng.addpath(eng.genpath('code/'))
eng.addpath(eng.genpath(mvgcdir))
eng.addpath(eng.genpath(noisetooldir))
eng.rmpath(eng.fullfile(noisetooldir, 'COMPAT'))
