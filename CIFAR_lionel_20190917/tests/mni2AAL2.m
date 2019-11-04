function [label,number,index] = mni2AAL2(mni)

% this function converts MNI coordinate to a description of brain structure
% in AAL.
%
%   mni: the coordinates (MNI) of some points, in mm.  It is Nx3 matrix
%   where each row is the coordinate for one point
%
%   Example:
%
%   [label,number,index] = mni2AAL2([72 -34 -2; 50 22 0])
%
% Adapted from 'cuixuFindStructure.m', Xu Cui (2007): http://www.alivelearn.net/?p=14
%
% AALDB.mat from xjView: http://www.alivelearnspm12/toolbox/aal/aal2.nii.net/xjview/ file TDdatabase.mat
%
% Also check: spm12/toolbox/aal/aal2.nii

niifile = '~/software/matlab/spm12/toolbox/aal/aal2.nii';
info = niftiinfo(niifile);
T = inv(info.Transform.T)
AAL  = niftiread(niifile);
load('~/software/matlab/spm12/toolbox/aal/ROI_MNI_V5_List.mat');

N = size(mni,1);

% round the coordinates
mni = round(mni/2)*2;

label  = cell(N,1);
number = zeros(N,1);
mni
index  = mni2cor(mni,T)

for i = 1:N
	graylevel = AAL(index(i,1),index(i,2),index(i,3))

	if graylevel == 0
		label{i} = 'undefined';
	else
		label{i} = ROI(graylevel).Nom_L;
	end

	number(i) = graylevel;
end

function coordinate = mni2cor(mni,T)

if isempty(mni)
    coordinate = [];
    return;
end

coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*T;
coordinate(:,4) = [];
coordinate = round(coordinate);

return;
