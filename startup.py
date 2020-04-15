import matlab.engine
from pathlib import Path, PurePath, PosixPath
import os
eng = matlab.engine.start_matlab()
wdir = PosixPath('~', 'projects', 'CIFAR')
wdir.expanduser()
os.chdir(wdir)
Path.cwd()
# Add matlab code path
eng.addpath(eng.genpath('code/'))
rootdir = eng.getenv('USERPROFILE')
mvgc_root = eng.fullfile(rootdir, 'toolboxes', 'mvgc')
noisetool_root = eng.fullfile(rootdir, 'toolboxes', 'NoiseTools')
eng.addpath(eng.genpath('code/'))
eng.addpath(mvgc_root)
eng.addpath(noisetool_root)
eng.startup_mat(nargout=0)
