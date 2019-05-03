function [Y,nouts] = routl(X,sdfac,repmean)

% Replace outliers in each variable in matrix X (variables x observations x
% trials), by a random non-outlier, or mean if repmean is set. Outliers are
% defined as less than (mean - sdfac*sd) or greater than (mean + sdfac*sd) where
% sd is the standard deviation of X.

if sdfac == 0 % do nothing
    Y = X;
    nouts = 0;
    return;
end

[n,m,N] = size(X);
X = X(:,:);

Y = X;
nouts = zeros(n,1);

for i = 1:n
    xmean      = mean(X(i,:));
    xsdev      = std(X(i,:));
    outs       = X(i,:) < xmean - sdfac*xsdev | X(i,:) > xmean + sdfac*xsdev; % logical idx of outliers
    nouts(i)   = nnz(outs);  % number of outliers
    Z          = X(i,~outs); % non-outliers
    if repmean
        Y(i,outs)  = mean(Z)*ones(1,nouts(i));         % replace with mean of non-outliers
    else
        Y(i,outs)  = Z(randi(length(Z),[1 nouts(i)])); % replace with random non-outlier
    end
end

if N > 1 % multi-trial
    Y = reshape(Y,[n m N]);
end
