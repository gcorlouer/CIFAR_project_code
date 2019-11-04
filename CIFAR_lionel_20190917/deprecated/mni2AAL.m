function [label,number,index] = mni2AAL(mni)

% this function converts MNI coordinate to a description of brain structure
% in AAL.
%
%   mni: the coordinates (MNI) of some points, in mm.  It is Nx3 matrix
%   where each row is the coordinate for one point
%
%   Example:
%
%   [label,number,index] = mni2AAL([72 -34 -2; 50 22 0])
%
% Adapted from 'cuixuFindStructure.m', Xu Cui (2007): http://www.alivelearn.net/?p=14
%
% AALDB.mat from xjView: http://www.alivelearnspm12/toolbox/aal/aal2.nii.net/xjview/ file TDdatabase.mat
%
% Also check: spm12/toolbox/aal/aal2.nii

load('AALDB.mat'); % AALDB.mat must be on your PATH

N = size(mni,1);

% round the coordinates
mni = round(mni/2)*2;

T = [...
     2     0     0   -92
     0     2     0  -128
     0     0     2   -74
     0     0     0     1];

label  = cell(N,1);
number = nan(N,1);
index  = mni2cor(mni,T);

n = size(AAL.mnilist);

for i = 1:N

	if ...
		(index(i,1) < 1 || index(i,1) > n(1)) || ...
		(index(i,2) < 1 || index(i,2) > n(2)) || ...
		(index(i,3) < 1 || index(i,3) > n(3))
		fprintf(2,'channel %d - bad index: %s\n',i,num2str(index(i,:)));
		label{i} = 'offgrid';
		continue
	end

	graylevel = AAL.mnilist(index(i,1),index(i,2),index(i,3));
	if graylevel == 0
		label{i} = 'undefined';
	else
		label{i} = AAL.anatomy{graylevel};
	end
	number(i) = graylevel;
end

function coordinate = mni2cor(mni,T)

% function coordinate = mni2cor(mni, T)
% convert mni coordinate to matrix coordinate
%
% mni: a Nx3 matrix of mni coordinate
% T: (optional) transform matrix
% coordinate is the returned coordinate in matrix
%
% caution: if T is not specified, we use:
% T = ...
%     [-4     0     0   84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18

if isempty(mni)
    coordinate = [];
    return;
end

if nargin == 1
	T = ...
        [-4     0     0   84;...
         0     4     0  -116;...
         0     0     4   -56;...
         0     0     0     1];
end

coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*(inv(T))';
coordinate(:,4) = [];
coordinate = round(coordinate);

return;
