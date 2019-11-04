function nouts = noutl(X,sdfac)

% Count outliers in each variable in matrix X (variables x observations x
% trials). Outliers are defined as less than (mean - sdfac*std) or greater
% than (mean + sdfac*std).

assert(sdfac > 0);

n = size(X,1);
X = X(:,:);

nouts = zeros(n,1);
for i = 1:n
    mi = mean(X(i,:));
    si = sdfac*std(X(i,:));
    nouts(i) = nnz((X(i,:) < mi-si) | (X(i,:) > mi+si));
end
